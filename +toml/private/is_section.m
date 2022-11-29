function n_brackets = is_section(str)
  str = strtrim(str);

  n_brackets = 0;
  if str(1) ~= '['
    return
  elseif str(end) ~= ']'
    error('toml:IncompleteSectionHeader', ...
      'Line must not begin with "[" unless it is a section header.')
  elseif startsWith(str, '[[[') || endsWith(str, ']]]')
    error('toml:TripleBracket', ...
      'Section headers can only have one (table) or two (array) brackets.');
  end

  if str([2 end-1]) == '[]'
    n_brackets = 2;
  else
    n_brackets = 1;
  end

end