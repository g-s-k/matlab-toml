function out = trimstart(s, allow_newline)
  if nargin < 2
    allow_newline = false;
  end
  
  for idx = 1:numel(s)
    if isspace(s(idx))
      if s(idx) == newline && ~allow_newline
        error('toml:UnexpectedLineBreak', ...
          "Encountered a newline where it wasn't expected.");
      end
    else
      out = s(idx:end);
      return
    end
  end

  out = '';
end
