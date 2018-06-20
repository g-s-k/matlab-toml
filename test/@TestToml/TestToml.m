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

  end

end