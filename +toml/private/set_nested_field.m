function obj = set_nested_field(obj, indx, val)
  struct_indx = cellfun(@ischar, indx);
  if isempty(struct_indx)
    obj = val;
  elseif all(struct_indx)
    obj = setfield(obj, indx{:}, val);
  elseif ~struct_indx(1)
    if length(obj) >= indx{1}
      obj{indx{1}} = set_nested_field(obj{indx{1}}, indx(2:end), val);
    else
      obj{indx{1}} = set_nested_field({}, indx(2:end), val);
    end
  else
    first_cell_indx = find(~struct_indx, 1);
    orig_sub = getfield(obj, indx{1:first_cell_indx-1});
    mod_sub = set_nested_field(orig_sub, indx(first_cell_indx:end), val);
    obj = setfield(obj, indx{1:first_cell_indx-1}, mod_sub);
  end
end