function str = expect_line_break_or_comment_or_eof(str)
  for idx = 1:numel(str)
    c = str(idx);
    if c == "\n" || c == "\r" || ~isspace(c)
      str = str(idx:end);
      break
    end
  end

  if isempty(str)
    % cool
  elseif startsWith(str, '#')
    str = consume_comment(str);
  elseif startsWith(str, "\n")
    str = str(2:end);
  elseif startsWith(str, "\r\n")
    str = str(3:end);
  else
    error('toml:ExpectedLineBreak', ...
      'Expected newline (LF or CRLF) but did not find one.');
  end
end
