% DECOMMENT remove comment from a single line
%
%   DECOMMENT('# this is a comment') returns ''.
%
%   DECOMMENT('key = "value" # comment') returns 'key = "value"'.

function out = decomment(in)
  if isempty(in) || in(1) == '#'
    out = '';
  else
    out = strtok(in, '#');
  end
end