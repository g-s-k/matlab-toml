function obj_out = parse(toml_str)
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
  cleaner = @matlab.lang.makeValidName;

  while current_line <= length(toml_nonempty)
    % recognize a section and store it semantically
    section_regexp = '^\[(\w+?\.?)+\]$';
    section_name = regexp(toml_nonempty{current_line}, section_regexp, ...
                          'tokens');
    if ~isempty(section_name)
      location_stack = cellfun(cleaner, strsplit(section_name{:}{:}, '.'), ...
                               'uniformoutput', false);
      current_line = current_line + 1;
      continue
    end

    % recognize key-value pairs and add them to the struct
    [key, value] = strtok(toml_nonempty{current_line}, '=');
    key_seq = cellfun(cleaner, strsplit(key, '.'), 'uniformoutput', false);
    % ensure we have a complete value
    while true
      value_fix = parsevalue(value);
      if isempty(value_fix) && current_line < length(toml_nonempty)
        current_line = current_line + 1;
        value = sprintf('%s\n%s', value, toml_nonempty{current_line});
      else
        break
      end
    end
    obj_out = setfield(obj_out, location_stack{:}, key_seq{:}, value_fix);
    current_line = current_line + 1;
  end
end