% ENCODE serialize MATLAB data as a TOML string
%
%   ENCODE(some_struct) returns the TOML representation of the data in
%   `some_struct`.
%
%   See also TOML.DECODE, TOML.WRITE

function toml_str = encode(m_strct)
  toml_str = repr(m_strct);
end