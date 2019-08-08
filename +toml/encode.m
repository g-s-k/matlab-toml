% ENCODE serialize MATLAB data as a TOML string
%
%   ENCODE(some_struct) returns the TOML representation of the data in
%   `some_struct`.
%
%   See also TOML.DECODE, TOML.WRITE

function toml_str = encode(m_strct)
  if isstruct(m_strct)
    if isscalar(m_strct)
      % serialize it recursively
      toml_str = strtrim(repr(m_strct));
    else
      error('toml:NonScalarStruct', ...
            'TOML base table must be scalar.')
    end
  else
    error('toml:InvalidBaseType', ...
          'TOML base variable must be a struct.')
  end
end