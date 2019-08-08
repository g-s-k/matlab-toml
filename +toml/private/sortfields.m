% SORTFIELDS sorts fields in a struct so nesting is correct
%
%   SORTFIELDS(struct_in) returns a field-sorted struct

function struct_out = sortfields(struct_in)
  % convert to cell
  tmp = struct2cell(struct_in);
  % find which cells are structs
  sub_structs = find(cellfun(@isstruct, tmp));
  % build function to eval if a cell is a cell of all structs
  cell_of_struct = @(cell_in) iscell(cell_in) && all(cellfun(@isstruct, cell_in));
  % get index of above evaluation
  sub_cellstructs = find(cellfun(cell_of_struct, tmp));
  % list index of struct locations
  sub_structs = [sub_structs; sub_cellstructs];
  % list index order
  new_order = [setdiff(1:numel(tmp), sub_structs), sub_structs.'];
  % set new order
  struct_out = orderfields(struct_in, new_order);
end