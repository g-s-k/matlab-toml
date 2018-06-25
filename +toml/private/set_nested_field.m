% SET_NESTED_FIELD set a value somewhere in a struct
%
%   SET_NESTED_FIELD(obj, indx, val) sets the location denoted by `indx`
%   (a pointer sequence into `obj`) in `obj` equal to `val`, and returns
%   a modified copy of `obj`.
%
%   See also GET_NESTED_FIELD

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
      orig = get_nested_field(obj, indx(1));
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