# matlab-toml
An implementation of [TOML](https://github.com/toml-lang/toml) in MATLAB.

Supports the standard as of commit [1b26808](https://github.com/toml-lang/toml/tree/1b26808a8190f6d7d65bf31091c1f8561e1a6feb).

## Todo
* Better testing
  * More exhaustive testing of `toml.encode`
    * 2D char arrays
    * Cell arrays of structs (table-list format in TOML)
    * Validation of non-serializable types
  * Test coverage for `toml.write`
  * Test type validation in `toml.decode`
* New features
  * Type coercion in `toml.encode`
