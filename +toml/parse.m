function obj_out = parse(toml_str)
%% pre-emptive checking
  % split on newlines
  toml_lines = strsplit(toml_str, {'\\n', '\\r'});
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
    section_regexp = '^\[(\w+?\.?)+\]$';
    section_name = regexp(toml_nonempty{current_line}, section_regexp, ...
                          'tokens');
    if ~isempty(section_name)
      location_stack = strsplit(section_name{:}{:}, '.');
      current_line = current_line + 1;
      continue
    end

    % recognize key-value pairs and add them to the struct
    [key, value] = strtok(toml_nonempty{current_line}, '=');
    value_fix = value(2:end);
    obj_out = setfield(obj_out, location_stack{:}, key, value_fix);
    current_line = current_line + 1;
  end
end