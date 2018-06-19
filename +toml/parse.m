function obj = parse(toml_str)
  % split on newlines
  toml_lines = strsplit(toml_str, {'\\n', '\\r'});
  % throw out comments
  de_commenter = @(elem) strtrim(decomment(elem));
  toml_decommented = cellfun(de_commenter, toml_lines, ...
                             'UniformOutput', false);
  % output
  obj = toml_decommented;
  obj(cellfun(@isempty, obj)) = [];
end