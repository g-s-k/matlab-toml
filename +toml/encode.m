% ENCODE serialize MATLAB data as a TOML string
%
%   ENCODE(some_struct) returns the TOML representation of the data in
%   `some_struct`.
%
%   See also TOML.DECODE, TOML.WRITE

function toml_str = encode(m_strct)
  if isstruct(m_strct)
    if isscalar(m_strct)
      % order fields so nothing gets nested wrong
      tmp = struct2cell(m_strct);
      sub_structs = find(cellfun(@isstruct, tmp));
      cell_of_struct = @(cell_in) iscell(cell_in) && all(cellfun(@isstruct, cell_in));
      sub_cellstructs = find(cellfun(cell_of_struct, tmp));
      sub_structs = [sub_structs; sub_cellstructs];
      new_order = [setdiff(1:numel(tmp), sub_structs), sub_structs.'];
      m_strct = orderfields(m_strct, new_order);
      % serialize it recursively
      toml_str = repr(m_strct);
    else
      error('toml:NonScalarStruct', ...
            'TOML base table must be scalar.')
    end
  else
    error('toml:InvalidBaseType', ...
          'TOML base variable must be a struct.')
  end
end