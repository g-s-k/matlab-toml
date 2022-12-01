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
      elseif startsWith(str, "\r\n")
        str = str(3:end);
      else
        break
      end
    end
    [val, str] = terminate_string(str, '"""');
    val = unescape(strrep(val, "\\\n", ""));

  elseif startsWith(str, '"')
    [val, str] = terminate_string(str(2:end), '"');
    val = unescape(val);
  end
end

function [content, rest] = terminate_string(str, delim)
  escaping = false;
  for idx = 1:numel(str)
    c = str(idx);

    if ~escaping && startsWith(str(idx:end), delim)
      content = str(1:idx-1);
      rest = str(idx+numel(delim):end);
      return

    elseif c == 9
      % tab is okay
    elseif c == 10 && numel(delim) > 1
      % line feeds are ok in multiline strings
    elseif c <= 31 || c == 127
      error('toml:ControlCharInString', ...
        sprintf('Encountered control character %d in string.', c));

    elseif c == '\'
      escaping = ~escaping;
    else
      escaping = false;
    end
  end

  error('toml:UnterminatedString', ...
    ['Encountered a string without a closing quote: ', str]);
end

function str = unescape(str)
  str = strrep(str, '\b', "\b");
  str = strrep(str, '\t', "\t");
  str = strrep(str, '\n', "\n");
  str = strrep(str, '\f', "\f");
  str = strrep(str, '\r', "\r");
  str = strrep(str, '\"', '"');
  str = strrep(str, '\/', '/');
  str = strrep(str, '\\', '\');
end
