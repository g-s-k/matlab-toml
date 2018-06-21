function key = parsekey(str)
  % split on dots, if not inside quotes
  indices = [];
  depth_q = [0 0];
  for ch = 1:length(str)
    switch str(ch)
      case ''''
        depth_q(1) = depth_q(1) + 1;
      case '"'
        depth_q(2) = depth_q(2) + 1;
      case '.'
        if ~any(mod(depth_q, 2))
          indices = [indices, ch];
        end
    end
  end
  str(indices) = char(0);
  key_seq = strsplit(str, char(0));

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