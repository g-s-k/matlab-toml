function obj = parse(toml_str)
  % split on newlines
  toml_lines = strsplit(toml_str, {'\\n', '\\r'});
  % throw out comments
  toml_decommented = cellfun(@decomment, toml_lines, ...
                             'UniformOutput', false);
  % output
  obj = toml_decommented;
  obj(cellfun(@isempty, obj)) = [];
end