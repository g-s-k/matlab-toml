function val = parsevalue(str)
  % default behavior is direct passthrough
  val = str;

  % remove leading equals sign
  if val(1) == '='
    val = val(2:end);
  end

  % trim space on each side
  trimmed_val = strtrim(val);

%% check for numeric types

  % utils for integers
  is_int = @(t, s, c) all(ismember(t, [s, '_'])) && isequal(t(1:2), ['0', c]);
  descore = @(t) strrep(t(3:end), '_', '');
  specs.bin = 'b01';
  specs.oct = 'o01234567';
  specs.dec = '_+-0123456789.eE';
  specs.hex = 'x0123456789abcdefABCDEF';
  % binary
  if is_int(trimmed_val, specs.bin, 'b')
    val = bin2dec(descore(trimmed_val));
  % octal
  elseif is_int(trimmed_val, specs.oct, 'o')
    val = base2dec(descore(trimmed_val), 8);
  % hexadecimal
  elseif is_int(trimmed_val, specs.hex, 'x')
    val = hex2dec(descore(trimmed_val));
  % decimal (including floats)
  elseif all(ismember(trimmed_val, specs.dec))
    val = str2double(strrep(val, '_', ''));
  end

  % special values of float
  if any(strcmp(trimmed_val, {'inf', '+inf', '-inf', 'nan', '+nan', '-nan'}))
    val = str2double(val);
  end

%% booleans
  if any(strcmp(trimmed_val, {'true', 'false'}))
    val = str2num(trimmed_val);
  end

%% strings
  % basic strings
  if trimmed_val(1) == '"' && trimmed_val(end) == '"'
    val = trimmed_val(2:end-1);
  end

end