% CHECKLINE check a line of TOML data for validity
%
%   CHECKLINE(toml_line) tests that line for invalid forms, and raises
%   an exception if one of them is applicable.

function checkline(in)
  % check for unspecified value
  if in(end) == '='
    error('toml:UnspecifiedValue', ...
          'TOML keys must have a corresponding value.')
  end

  % check for empty (bare) key
  if in(1) == '='
    error('toml:EmptyBareKey', ...
          'TOML bare keys must not be empty.')
  end
end