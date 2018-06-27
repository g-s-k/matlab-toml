% SPLITBY split a string while respecting grouping
%
%   SPLITBY(str, '.', {'"', '[]'}) splits `str` on each period which is
%   not enclosed in square brackets or double quotes.

function parsed = splitby(str, to_split_by, to_respect)
  % make convenient structure out of delimiter arguments
  delims = cellfun(@delim_data, to_respect);
  % walk through the string char by char
  for ch = 1:length(str)
    % check each delimiter (set) for matches
    for delim = 1:length(delims)
      if delims(delim).match_begin(str(ch))
        delims(delim).depth = delims(delim).depth + 1;
        continue
      elseif delims(delim).match_end(str(ch))
        delims(delim).depth = delims(delim).depth - 1;
        continue
      end
    end

    % check for splittability
    if str(ch) == to_split_by
      % check each delimiter (set) for lexical closure
      not_ready = zeros(size(delims));
      for delim = 1:length(delims)
        not_ready(delim) = delims(delim).check_in(delims(delim).depth);
      end

      % if no one complains, mark as splittable
      if ~any(not_ready)
        str(ch) = char(0);
      end
    end
  end

  % actually split the thing
  parsed = strsplit(str, char(0));
end

function dd = delim_data(delim)
  % there is always at least one delimiter
  dd.match_begin = @(c) c == delim(1);
  % start at zero immersion
  dd.depth = 0;
  switch length(delim)
    case 1
      % no intuitive meaning to 'end'
      dd.match_end = @(c) false;
      % as long as there are an even number, we're good
      dd.check_in = @(x) mod(x, 2);
    case 2
      % simple enough
      dd.match_end = @(c) c == delim(2);
      % we want no levels of immersion
      dd.check_in = @(x) min(1, x);
  end
end