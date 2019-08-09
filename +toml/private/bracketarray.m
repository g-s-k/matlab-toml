function out = bracketarray(in)
  in_size = size(in);
  in_dims = ndims(in);
  if in_dims > 3
    error('Only 3 dimensional arrays currently supported.')
  end

  % if array has only 2 dimensions, create the string
  if in_dims == 2
    for jj = 1:in_size(1)
      storage{jj} = strcat('[', strjoin(split(num2str(in(jj, :)))', ','), ']');
    end
    out = {strcat('[', strjoin(storage, ','), ']')};
    return
  % if array has more than 2 dimensions, recursively send planes of 2 dimensions for encoding
  else
    for ii = 1:in_size(end) %<--- this doesn't track dimensions or counts of them
      out(ii) = bracketarray(in(:,:,ii)); %<--- this is limited to 3 dimensions atm. and out(indexing) need help
    end
  end
  % bracket the final bit together
  out = {strcat('[', strjoin(out, ','), ']')};
end