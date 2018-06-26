% READ parse TOML data from a file
%
%   READ('file.toml') loads the contents of `file.toml` and parses
%   that data into a MATLAB struct.
%
%   See also FILEREAD, TOML.DECODE

function toml_data = read(filename)
  raw_text = fileread(filename);
  toml_data = toml.decode(raw_text);
end