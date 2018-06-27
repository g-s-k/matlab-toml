% DECODE convert TOML to native MATLAB datatypes
%
%   DECODE(toml_str) returns the MATLAB representation of the
%   TOML-formatted data in `toml_str`. If it is invalid TOML, an
%   appropriate exception will be raised.
%
%   See also TOML.READ

function obj_out = decode(toml_str)
%% pre-emptive checking
  % split on newlines
  toml_lines = strsplit(toml_str, {'\n', '\r'});
  % throw out comments
  de_commenter = @(elem) deblank(decomment(elem));
  toml_decommented = cellfun(de_commenter, toml_lines, ...
                             'UniformOutput', false);
  % strip out empty lines
  toml_nonempty = toml_decommented(~cellfun(@isempty, toml_decommented));
  % check for invalid lines
  cellfun(@checkline, toml_nonempty);

%% parsing
  obj_out = struct();
  current_line = 1;
  location_stack = {};

  while current_line <= length(toml_nonempty)
    % recognize a section and store it semantically
    n_brackets = is_section(toml_nonempty{current_line});
    if n_brackets
      section_name = strtrim(toml_nonempty{current_line});
      section_name = section_name(n_brackets+1:end-n_brackets);
      location_stack = parsekey(section_name);
      location_stack = adjust_key_stack(obj_out, location_stack);
      % is it a table or an array of tables?
      if n_brackets == 1
        obj_out = set_nested_field(obj_out, location_stack, struct());
      else
        % if it already exists, append
        try
          existing_val = get_nested_field(obj_out, location_stack);
          location_stack{end + 1} = length(existing_val) + 1;
          obj_out = set_nested_field(obj_out, location_stack, struct());
        % if not, pre-populate
        catch
          obj_out = set_nested_field(obj_out, location_stack, {struct()});
          location_stack{end + 1} = 1;
        end
      end
      current_line = current_line + 1;
      continue
    end

    % recognize key-value pairs and add them to the struct
    [key, value] = strtok(toml_nonempty{current_line}, '=');
    key_seq = parsekey(key);
    % ensure we have a complete value
    force = false;
    while true
      value_fix = parsevalue(value, force);
      if isempty(value_fix) && ~iscell(value_fix)
        if current_line < length(toml_nonempty)
          current_line = current_line + 1;
          value = sprintf('%s\n%s', value, toml_nonempty{current_line});
        else
          force = true;
        end
      else
        break
      end
    end
    obj_out = set_nested_field(obj_out, [location_stack, key_seq], value_fix);
    current_line = current_line + 1;
  end
end