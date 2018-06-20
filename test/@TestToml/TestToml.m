classdef TestToml < matlab.unittest.TestCase

  methods (Test)

    function testComment(testCase)
      toml_str = '\n# this is a comment\n';
      testCase.assertEmpty(toml.parse(toml_str), ...
        'Improper interpretation of a comment')
    end

    function testKeyValueForm(testCase)
      toml_str = 'key = #';
      testCase.assertError(@() toml.parse(toml_str), ...
        'toml:UnspecifiedValue', 'Did not fail for unspecified value')
    end

    function testEmptyBareKey(testCase)
      toml_str = '\nkey = "value"\n= "value2"';
      testCase.assertError(@() toml.parse(toml_str), ...
        'toml:EmptyBareKey', 'Did not fail for unspecified value')
    end

    function testAllowedCharsBareKey(testCase)
      toml_str1 = 'key_text = "value"';
      toml_str2 = 'key-text = "value"';
      toml_str3 = 'key123 = "value"';
      toml_str4 = 'KEY = "value"';
      toml_str5 = '1234 = "value"';
      testCase.verifyEqual(toml.parse(toml_str1), ...
        struct('key_text', 'value'), ...
        'Did not accept a bare key with an underscore.')
      testCase.verifyEqual(toml.parse(toml_str2), ...
        struct('key_text', 'value'), ...
        'Did not accept a bare key with a dash.')
      testCase.verifyEqual(toml.parse(toml_str3), ...
        struct('key123', 'value'), ...
        'Did not accept a bare key with digits.')
      testCase.verifyEqual(toml.parse(toml_str4), ...
        struct('KEY', 'value'), ...
        'Did not accept a bare key with uppercase ASCII.')
      testCase.verifyEqual(toml.parse(toml_str5), ...
        struct('x1234', 'value'), ...
        'Did not accept a bare key with only ASCII digits.')
    end

  end

end