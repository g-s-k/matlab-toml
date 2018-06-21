function val = parsevalue(str)
%% check for noncompletion
  if isempty(str)
    val = '';
    return
  end

%% default fixes
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
  if trimmed_val(1) == '"'
    % is it multiline and complete?
    if isequal(trimmed_val(1:3), '"""') && ...
       numel(trimmed_val) > 3 && ...
       isequal(trimmed_val(end-2:end), '"""')
      % remove quotes
      val = trimmed_val(4:end-3);
      % remove leading newline
      if val(1) == sprintf('\n')
        val = val(2:end);
      end
      % trim whitespace for backslashes
      val = regexprep(val, '\\\n\s+', '');

    % is it complete but not multiline?
    elseif trimmed_val(2) ~= '"' && trimmed_val(end) == '"'
      % remove quotes
      val = trimmed_val(2:end-1);

    % newline in string, tell caller the value is incomplete
    else
      val = '';
      return
    end

    % common post-processing
    % escaped quotes
    val = strrep(val, '\"', '"');
    % unicode points
    ucode_match = '\\(u[A-Fa-f0-9]{4}|U[A-Fa-f0-9]{8})';
    ucode_replace = '${char(hex2dec($1(2:end)))}';
    val = regexprep(val, ucode_match, ucode_replace);
  end

end