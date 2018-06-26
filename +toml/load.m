% LOAD parse TOML data from a file
%
%   LOAD('file.toml') loads the contents of `file.toml` and parses
%   that data into a MATLAB struct.
%
%   See also FILEREAD, TOML.PARSE

function toml_data = load(filename)
  raw_text = fileread(filename);
  toml_data = toml.parse(raw_text);
end