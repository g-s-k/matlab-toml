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
      if isfield(obj, indx{:})
        switch class(obj.(indx{:}))
          case 'struct'
            if ~isstruct(val) || isempty(fieldnames(val))
              error('toml:RedefinedTable', ...
                    'Tables cannot be redefined.')
            end
          case 'cell'
            if iscell(val) && ...
              ( ...
                isempty(val) || ...
                ( ...
                  isempty(val{1}) || ( ...
                    isstruct(val{1}) && isempty(fieldnames(val{1})) ...
                  ) || ( ...
                    iscell(val{1}) && (isempty(val{1}{1}) || ( ...
                      isstruct(val{1}{1}) && isempty(fieldnames(val{1}{1})) ...
                    )) ...
                  ) ...
                ) ...
              )
              error('toml:RedefinedArray', ...
                    'Arrays cannot be redefined.')
            elseif isstruct(val)
              error('toml:NameCollision', ...
                    'Table definitions cannot override existing arrays.')
            end
          otherwise
            if isstruct(val)
              error('toml:RedefinedTable', ...
                    'Tables cannot be redefined.')
            end
            error('toml:RedefinedKey', ...
                  'Keys cannot be redefined.')
        end
      end
      obj.(indx{1}) = val;
    elseif iscell(obj)
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