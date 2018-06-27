# matlab-toml
An implementation of [TOML](https://github.com/toml-lang/toml) in MATLAB.

Supports the standard as of commit [1b26808](https://github.com/toml-lang/toml/tree/1b26808a8190f6d7d65bf31091c1f8561e1a6feb).

## Todo
* Assess code for removal
  * Will [this line](https://github.com/g-s-k/matlab-toml/blob/master/%2Btoml/private/adjust_key_stack.m#L26) ever run on valid TOML?
  * Will [this line](https://github.com/g-s-k/matlab-toml/blob/master/%2Btoml/private/get_nested_field.m#L15) ever run on valid TOML?
  * Will [this line](https://github.com/g-s-k/matlab-toml/blob/master/%2Btoml/private/set_nested_field.m#L51) ever run on valid TOML?
  * Will [this line](https://github.com/g-s-k/matlab-toml/blob/master/%2Btoml/private/set_nested_field.m#L63) ever run on valid TOML?
* New features
  * Type coercion in `toml.encode`
