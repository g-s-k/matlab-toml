function out = consume_comment(in)
  out = trimstart(in, true);

  if startsWith(out, '#')
    out = out(2:end);

    if ~isempty(out)
      comment_end = numel(out);
      for idx = 1:comment_end
        c = out(idx);
        if c == newline
          comment_end = idx;
          break
        elseif c == 9
          % tabs are okay
        elseif c <= 31 || c == 127
          error('toml:ControlCharInComment', ...
            sprintf('Encountered control character %d in comment.', c));
        end
      end

      out = trimstart(out(comment_end:end), true);
    end
  end
end