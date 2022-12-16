# matlab-toml

An implementation of [TOML](https://github.com/toml-lang/toml) in MATLAB.

Supports TOML 1.0.0.

# Testing

This package comes with a test suite that can run using MATLAB's builtin testing facilities.

It also includes a shim for testing with [`toml-test`](https://github.com/BurntSushi/toml-test)
located at `ci.bash`. Pass this as the "command" argument like so: `toml-test -- ./ci.bash`.

Both of the above are included in a GitHub Actions workflow that runs on each push.
