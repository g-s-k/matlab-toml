function is_it = is_key_char(c)
  is_it = (c >= 'A' && c <= 'Z') || ...
    (c >= 'a' && c <= 'z') || ...
    (c >= '0' && c <= '9') || ...
    c == '-' || c == '_';
end
