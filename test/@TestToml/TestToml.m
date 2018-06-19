classdef TestToml < matlab.unittest.TestCase

  methods (Test)

    function testDeserialize(testCase)
      toml_str = '\n# this is a comment\n';
      testCase.assertEmpty(toml.parse(toml_str), ...
        'Improper interpretation of a comment')
    end

    function testKeyValueForm(testCase)
      toml_str = 'key = #';
      testCase.assertError(@() toml.parse(toml_str), ...
        'toml:UnspecifiedValue', 'Did not fail for unspecified value')
    end

  end

end