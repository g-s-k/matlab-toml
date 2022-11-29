% GET_LINE split off the first line from a TOML string
%
%   GET_LINE(str) returns the next line that is not
%   either blank or a comment. The second return value
%   is the remainder of the string after the line break.

function [this_line, str] = get_line(str)
  this_line = "";
  while isempty(this_line) && ~isempty(str)
    [this_line, str] = strtok(str, "\r\n");
    this_line = strtrim(decomment(this_line));
    str = strtrim(str);
  end

  % check for invalid lines
  checkline(this_line);
end