function [val, str] = consume_literal_string(str, allow_multiline)
  if nargin < 2
    allow_multiline = false;
  end

  val = [];
  if allow_multiline && startsWith(str, "'''")
    str = str(4:end);
    while startsWith(str, newline)
      str = str(2:end);
    end
    [val, str] = terminate_string(str, "'''");

  elseif startsWith(str, "'")
    str = str(2:end);
    [val, str] = terminate_string(str, "'");
  end
end

function [content, rest] = terminate_string(str, delim)
  for idx = 1:numel(str)
    c = str(idx);

    if startsWith(str(idx:end), delim)
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
    end
  end

  error('toml:UnterminatedString', ...
    ['Encountered a string without a closing quote: ', str]);
end
