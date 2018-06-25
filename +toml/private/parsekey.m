% PARSEKEY convert a string into a struct pointer
%
%   PARSEKEY(str) splits a string semantically on dots (while respecting
%   quotes), then converts each segment of the resulting pointer into a
%   valid field name with a predictable structure.
%
%   See also PARSEVALUE, SPLITBY

function key = parsekey(str)
  % split on dots, if not inside quotes
  key_seq = splitby(str, '.', {'''', '"'});

  % utility for the following
  uo = {'UniformOutput', false};

  % remove quotes
  dequote = @(elem) regexprep(elem, '["'']+', '');
  key_unquoted = cellfun(dequote, key_seq, uo{:});

  % trim leading and trailing space
  key_trimmed = cellfun(@strtrim, key_unquoted, uo{:});

  % sub underscores for spaces
  despace = @(elem) strrep(elem, ' ', '_');
  key_despaced = cellfun(despace, key_trimmed, uo{:});

  % make it a valid name
  fixname = @(elem) matlab.lang.makeValidName(elem, 'prefix', 'f');
  key = cellfun(fixname, key_despaced, uo{:});

end