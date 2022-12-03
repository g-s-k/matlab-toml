function [val, str] = consume_basic_string(str, allow_multiline)
  if nargin < 2
    allow_multiline = false;
  end

  val = [];
  if allow_multiline && startsWith(str, '"""')
    str = str(4:end);
    while true
      if startsWith(str, newline)
        str = str(2:end);
      elseif startsWith(str, [char(0xD) newline])
        str = str(3:end);
      else
        break
      end
    end
    [val, str] = terminate_string(str, true);

  elseif startsWith(str, '"')
    [val, str] = terminate_string(str(2:end), false);
  end
end

function [content, str] = terminate_string(str, is_multiline)
  pieces = {};
  while true
    if isempty(str)
      error('toml:EndOfInput', 'Did not expect input to end.');

    elseif startsWith(str, '\')
      str = str(2:end);
      if isempty(str)
        error('toml:EndOfInput', 'Did not expect input to end.');

      elseif is_multiline && ~any_non_whitespace_chars_before_newline(str)
        while isspace(str(1))
          str = str(2:end);
          if isempty(str)
            error('toml:EndOfInput', 'Did not expect input to end.');
          end
        end

      else
        c = str(1);
        str = str(2:end);
        switch c
          case { '\', '"' }
            pieces{end+1} = c;
          case { 'b', 't', 'r', 'f', 'n' }
            pieces{end+1} = sprintf(['\' c]);
          case 'u'
            [code_point, str] = get_hex_digits(str, 4);
            pieces{end+1} = char(hex2dec(code_point));
          case 'U'
            [code_point, str] = get_hex_digits(str, 8);
            pieces{end+1} = char(hex2dec(code_point));
          otherwise
            error('toml:ReservedEscapeSequence', ...
              ['Encountered reserved escape sequence `\\', c, '` in string.']);
        end
      end
    elseif is_multiline && startsWith(str, '"""')
      if startsWith(str, '"""""')
        pieces{end+1} = '""';
        str = str(6:end);
      elseif startsWith(str, '""""')
        pieces{end+1} = '"';
        str = str(5:end);
      else
        str = str(4:end);
      end
      break
    elseif ~is_multiline && startsWith(str, '"')
      str = str(2:end);
      break
    elseif ~is_multiline && startsWith(str, newline)
      error('toml:LineBreakInBasicString', ...
        'Encountered a line break in a single-line string.');
    elseif str(1) <= 8 || (str(1) >= 11 && str(1) <= 31) || str(1) == 127
      error('toml:ControlCharInBasicString', ...
        sprintf('Encountered control character `%d` in a string.', str(1)));
    else
      pieces{end+1} = str(1);
      str = str(2:end);
    end
  end
  
  content = strjoin(pieces, '');
end

function are_there = any_non_whitespace_chars_before_newline(str)
  are_there = false;
  for idx = 1:numel(str)
    if str(idx) == newline || startsWith(str(idx:end), [char(0xD) newline])
      return
    elseif ~isspace(str(idx))
      are_there = true;
      return
    end
  end
end

function [digits, str] = get_hex_digits(str, count)
  digits = '';
  for idx = 1:numel(str)
    c = str(idx);
    if ~((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')) || idx == count+1
      digits = str(1:idx-1);
      str = str(idx:end);
      break
    end
  end

  if numel(digits) ~= count
    error('toml:InvalidUnicode', ...
      sprintf('Expected %d hex digits for escape, got %d', count, numel(digits)));
  end
end
