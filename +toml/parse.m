function obj = parse(toml_str)
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
  % output
  obj = toml_nonempty;
end