% DECODE convert TOML to native MATLAB datatypes
%
%   DECODE(toml_str) returns the MATLAB representation of the
%   TOML-formatted data in `toml_str`. If it is invalid TOML, an
%   appropriate exception will be raised.
%
%   See also TOML.READ

function obj_out = decode(toml_str)
  obj_out = struct();
  location_stack = {};

  while ~isempty(toml_str)
    toml_str = trimstart(toml_str);

    if startsWith(toml_str, '[[') % array
      toml_str = toml_str(3:end);
      [location_stack, toml_str] = get_keys(toml_str, ']]');
      location_stack = adjust_key_stack(obj_out, location_stack);
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

    elseif startsWith(toml_str, '[') % table
      toml_str = toml_str(2:end);
      [location_stack, toml_str] = get_keys(toml_str, ']');
      location_stack = adjust_key_stack(obj_out, location_stack);
      obj_out = set_nested_field(obj_out, location_stack, struct());

    elseif startsWith(toml_str, '#') % comment
      newlines = strfind(toml_str, newline);
      if isempty(newlines)
        toml_str = '';
      else
        toml_str = toml_str(newlines(1)+1:end)
      end

    else % key / value pair
      [key_seq, toml_str] = get_keys(toml_str, '=');

      [value, toml_str] = get_line(toml_str);
      value_fix = parsevalue(value, false);
      while isempty(value_fix) && ~iscell(value_fix)
        [next_line, toml_str] = get_line(toml_str);
        value = [value, next_line];
        value_fix = parsevalue(value, isempty(next_line));
      end

      obj_out = set_nested_field(obj_out, [location_stack, key_seq], value_fix);
    end
  end
end

function [keys, str] = get_keys(str, next_token)
  keys = {};
  while true
    [key, str] = get_key(str, next_token);
    str = trimstart(str);
    if startsWith(str, '.')
      str = trimstart(str(2:end));
    end

    if isempty(key)
      break
    end

    keys{end+1} = key;
    if startsWith(str, next_token)
      break
    end
  end

  str = expect(str, next_token);
end

function [key, rest] = get_key(str, next_token)
  str = trimstart(str);
  if startsWith(str, '"')
    closing_quote = 2;
    while closing_quote <= numel(str) && (str(closing_quote) ~= '"' || str(closing_quote - 1) == '\')
      closing_quote = closing_quote + 1;
    end
    if closing_quote > numel(str)
      error('toml:UnterminatedString', ...
        'Encountered a string without a closing quote.');
    end
    key = str(2:closing_quote-1);
    rest = str(closing_quote+1:end);

  elseif startsWith(str, "'")
    str = str(2:end);
    single_quotes = strfind(str, "'");
    if isempty(single_quotes)
      error('toml:UnterminatedString', ...
        'Encountered a string without a closing quote.');
    end
    closing_quote = single_quotes(1);
    key = str(1:closing_quote-1);
    rest = str(closing_quote+1:end);

  else
    key_end = 1;
    while key_end <= numel(str) && ...
      (isstrprop(str(key_end), 'alphanum') || str(key_end) == '-' || str(key_end) == '_')
      key_end = key_end + 1;
    end
    key = str(1:key_end-1);
    rest = str(key_end:end);
  end
end

function str = expect(str, token)
  if ~startsWith(str, token)
    error('toml:MissingToken', ...
      ['Expected token `', token, '` but did not find it.']);
  end
  str = str(numel(token)+1:end);
end

function s = trimstart(s)
  while ~isempty(s) && isspace(s(1))
    s = s(2:end);
  end
end
