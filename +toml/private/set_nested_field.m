function obj = set_nested_field(obj, indx, val)
  if length(indx) == 1
    if isstruct(obj)
      obj.(indx{1}) = val;
    else
      if ischar(indx{1})
        obj{end}.(indx{1}) = val;
      else
        obj{indx{1}} = val;
      end
    end
  else
    try
      if isstruct(obj)
        orig = obj.(indx{1});
      else
        orig = obj{indx{1}};
      end
    catch
      if ischar(indx{2})
        orig = struct();
      else
        orig = {};
      end
    end
    new = set_nested_field(orig, indx(2:end), val);
    obj = set_nested_field(obj, indx(1), new);
  end
end