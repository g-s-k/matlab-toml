% READ parse TOML data from a file
%
%   READ('file.toml') loads the contents of `file.toml` and parses
%   that data into a MATLAB Map.
%
%   See also FILEREAD, TOML.DECODE

function toml_data = read(filename)
  if is_octave()
    raw_text = read_utf8(filename);
  else
    fid = fopen(filename, 'r', 'n', 'UTF-8');
    raw_text = fread(fid, [1 inf], '*char');
  end

  toml_data = toml.decode(raw_text);
end

function raw_text = read_utf8(filename)
  raw_text = '';
  fid = fopen(filename, 'r');
  while ~feof(fid)
    c = fread(fid, 1);
    if c < 128
      raw_text = [raw_text, char(c)];
      multi = [];
    elseif c < 192
      error('toml:InvalidUTF8', ...
        ['Bad UTF-8 in file ' filename]);
    else
      raw_text = [raw_text, char(c), char(get_continuation_byte(fid))];
      if c >= 224
        raw_text = [raw_text, char(get_continuation_byte(fid))];
      end
    end
  end
end

function b = get_continuation_byte(fid)
  b = fread(fid, 1);

  if b < 127
    error("toml:InvalidUTF8", ...
      ['Expected continuation byte, found ASCII character ' char(b)]);
  elseif b > 191
    error("toml:InvalidUTF8", ...
      ['Expected continuation byte, found leading byte `' sprintf('%d', b) '`']);
  end
end