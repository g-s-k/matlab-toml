% MAP_TO_STRUCT convert a (possibly nested containers.Map object) to a struct
%
%   MAP_TO_STRUCT(my_map) returns a struct with the same keys and corresponding
%   values as `my_map`, recursively converting Map values likewise. Any keys
%   that are not already valid MATLAB identifiers will be converted via the
%   default behavior of `matlab.lang.makeValidName`.
%
%   MAP_TO_STRUCT(my_map, ...varargin) will pass any remaining arguments
%   directly to `matlab.lang.makeValidName`.
%
%   See also MATLAB.LANG.MAKEVALIDNAME, CONTAINERS.MAP, STRUCT

function s = map_to_struct(map, varargin)
  s = struct();
  for key = map.keys()
    value = map(key{:});
    if isa(value, 'containers.Map')
      value = toml.map_to_struct(value, varargin{:});
    end

    key = matlab.lang.makeValidName(key{:}, varargin{:});
    s.(key) = value;
  end
end
