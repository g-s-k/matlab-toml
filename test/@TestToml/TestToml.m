classdef TestToml < matlab.unittest.TestCase

  methods (Test)

    function testDeserialize(testCase)
      toml_str = '\n# this is a comment\n';
      testCase.assertEmpty(toml.parse(toml_str), ...
        'Improper interpretation of a comment')
    end

  end

end