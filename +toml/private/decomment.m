% DECOMMENT remove comment from a single line
%
%   DECOMMENT('# this is a comment') returns ''.
%
%   DECOMMENT('key = "value" # comment') returns 'key = "value"'.

function out = decomment(in)
  all_parts = splitby(in, '#', {'"', ''''});
  out = all_parts{1};
end