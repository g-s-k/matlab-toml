function n_brackets = is_section(str)
  section_regexp = '^\s*\[{1,2}(.+?\.?)+\]{1,2}$';
  section_name = regexp(str, section_regexp, 'ONCE');

  if ~isempty(section_name)
    if str(2) == '['
      n_brackets = 2;
    else
      n_brackets = 1;
    end
  else
    n_brackets = 0;
  end

end