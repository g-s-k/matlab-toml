classdef TestTomlDecode < matlab.unittest.TestCase

  methods (Access = private)

    % Simple way to run tests repeatedly
    function runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
      if ischar(error_msg)
        error_msg = repmat({error_msg}, size(toml_str));
      end

      for indx = 1:length(toml_str)
        testCase.verifyEqual(toml.decode(toml_str{indx}), ...
                             matlab_strct{indx}, error_msg{indx})
      end
    end

  end

  methods (Test)

    function testComment(testCase)
      toml_str = sprintf('\n# this is a comment\n');
      testCase.verifyEmpty(fieldnames(toml.decode(toml_str)), ...
        'Improper interpretation of a comment')
    end

    function testKeyValueForm(testCase)
      toml_str = 'key = #';
      testCase.verifyError(@() toml.decode(toml_str), ...
        'toml:UnspecifiedValue', 'Did not fail for unspecified value')
    end

    function testEmptyBareKey(testCase)
      toml_str = sprintf('\nkey = "value"\n= "value2"');
      testCase.verifyError(@() toml.decode(toml_str), ...
        'toml:EmptyBareKey', 'Did not fail for unspecified value')
    end

    function testAllowedCharsBareKey(testCase)
      toml_str = { ...
          'key_text = "value"' ...
        , 'key-text = "value"' ...
        , 'key123 = "value"' ...
        , 'KEY = "value"' ...
        , '1234 = "value"' ...
                 };

      matlab_strct = { ...
          struct('key_text', 'value') ...
        , struct('key_text', 'value') ...
        , struct('key123', 'value') ...
        , struct('KEY', 'value') ...
        , struct('f1234', 'value') ...
                     };

      error_msg = { ...
          'Did not accept a bare key with an underscore.' ...
        , 'Did not accept a bare key with a dash.' ...
        , 'Did not accept a bare key with digits.' ...
        , 'Did not accept a bare key with uppercase ASCII.' ...
        , 'Did not accept a bare key with only ASCII digits.' ...
                  };

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testQuotedKeys(testCase)
      toml_str = { ...
          '"127.0.0.1" = "value"' ...
        , '"character encoding" = "value"' ...
        , '''key2'' = "value"' ...
        , '''quoted "value"'' = "value"' ...
        , '"" = "value"' ...
                 };

      matlab_strct = { ...
          struct('f127_0_0_1', 'value') ...
        , struct('character_encoding', 'value') ...
        , struct('key2', 'value') ...
        , struct('quoted_value', 'value') ...
        , struct('f', 'value') ...
                     };

      error_msg = { ...
          'Did not handle quoted key with invalid format correctly.' ...
        , 'Did not handle quoted key with space correctly.' ...
        , 'Did not handle single-quoted key correctly.' ...
        , 'Did not handle nested quoting in key correctly.' ...
        , 'Did not handle empty quoted key correctly.' ...
                  };

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testDottedKeys(testCase)
      toml_str = { ...
          'abc.def.ghi = "value"' ...
        , 'abc."def".ghi = "value"' ...
        , 'abc."quoted ''value''".ghi = "value"' ...
                 };

      matlab_strct = { ...
          struct('abc', struct('def', struct('ghi', 'value'))) ...
        , struct('abc', struct('def', struct('ghi', 'value'))) ...
        , struct('abc', struct('quoted_value', struct('ghi', 'value'))) ...
                     };

      error_msg = { ...
          'Did not handle dotted key correctly.' ...
        , 'Did not handle dotted and quoted key correctly.' ...
        , 'Did not handle nested quoting in dotted key correctly.' ...
                  };

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testSpecialFloats(testCase)
      % test cases
      toml_str = { ...
          'key = inf' ...
        , 'key = -inf' ...
        , 'key = INF' ...
        , 'key = nan' ...
        , 'key = -nan' ...
        , 'key = NaN' ...
                 };

      % test each case appropriately
      testCase.verifyEqual(toml.decode(toml_str{1}), struct('key', inf), ...
        'Did not parse infinity correctly')
      testCase.verifyEqual(toml.decode(toml_str{2}), struct('key', -inf), ...
        'Did not parse negative infinity correctly')
      testCase.verifyError(@() toml.decode(toml_str{3}), ...
       'toml:UppercaseSpecialFloat', ...
       'Did not raise an error for uppercase special float values.')
      testCase.verifyEqual(toml.decode(toml_str{4}), struct('key', NaN), ...
        'Did not parse infinity correctly')
      testCase.verifyEqual(toml.decode(toml_str{5}), struct('key', -NaN), ...
        'Did not parse negative infinity correctly')
      testCase.verifyError(@() toml.decode(toml_str{6}), ...
       'toml:UppercaseSpecialFloat', ...
       'Did not raise an error for uppercase special float values.')
    end

    function testUppercaseBoolean(testCase)
      toml_str = { ...
          'key = True' ...
        , 'key = FALSE' ...
                 };

      for indx = 1:length(toml_str)
        testCase.verifyError(@() toml.decode(toml_str{indx}), ...
         'toml:UppercaseBoolean', ...
         'Did not raise an error for uppercase Boolean values.')
      end
    end

    function testIntegerLeadingZeros(testCase)
      toml_str = { ...
          'key = 01' ...
        , 'key = 000123' ...
                 };

      for indx = 1:length(toml_str)
        testCase.verifyError(@() toml.decode(toml_str{indx}), ...
         'toml:DecIntLeadingZeros', ...
         'Did not raise an error for leading zeros on a decimal integer.')
      end
    end

    function testBasicString(testCase)
      toml_str = { ...
          'key = "value"' ...
        , sprintf('key = "line 1\nline 2"') ...
        , 'key = "disappearing A\b"' ...
        , 'key = "escaped \"quote\" marks"' ...
        , 'key = "inline \u0075nicode"' ...
        , 'key = "inline \U00000055nicode"' ...
        , 'key = "escaped\ttab"' ...
                 };

      matlab_strct = { ...
          struct('key', 'value') ...
        , struct('key', sprintf('line 1\nline 2')) ...
        , struct('key', sprintf('disappearing A\b')) ...
        , struct('key', 'escaped "quote" marks') ...
        , struct('key', 'inline unicode') ...
        , struct('key', 'inline Unicode') ...
        , struct('key', sprintf('escaped\ttab')) ...
                     };

      error_msg = { ...
          'Did not parse a basic string successfully.' ...
        , 'Did not parse a basic string with a newline successfully.' ...
        , 'Did not parse a basic string with a backspace successfully.' ...
        , 'Did not parse a basic string with escaped quotes successfully.' ...
        , 'Did not parse a basic string with short Unicode successfully.' ...
        , 'Did not parse a basic string with long Unicode successfully.' ...
        , 'Did not parse a basic string with an escaped tab successfully.' ...
                  };

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testReservedEscapes(testCase)
      valid_esc = 'btnfr"\uU';
      all_glyphs = char(33:126);
      invalid_esc = setdiff(all_glyphs, valid_esc);

      for ch = invalid_esc
        str_to_parse = sprintf('key = "\\%s"', ch);
        testCase.verifyError(@() toml.decode(str_to_parse), ...
         'toml:InvalidEscapeSequence', ...
         ['Did not reject a reserved escape sequence: "\', ch, '"'])
      end
    end

    function testMultilineBasicString(testCase)
      toml_str1 = sprintf('key = """\nabcd"""');
      toml_str2 = sprintf('key = """line 1\n    line 2"""');
      toml_str3 = sprintf('key = """on the \\\n    same line"""');
      testCase.verifyEqual(toml.decode(toml_str1), ...
        struct('key', 'abcd'), ...
        'Did not parse a multiline basic string successfully.')
      testCase.verifyEqual(toml.decode(toml_str2), ...
        struct('key', sprintf('line 1\n    line 2')), ...
        'Did not parse a multiline basic string with indentation successfully.')
      testCase.verifyEqual(toml.decode(toml_str3), ...
        struct('key', sprintf('on the same line')), ...
        'Did not parse a multiline basic string with a LEB successfully.')
    end

    function testLiteralString(testCase)
      toml_str1 = 'key = ''C:\Users\example.txt''';
      toml_str2 = sprintf('key = ''''''\nNo leading newline here.''''''');
      testCase.verifyEqual(toml.decode(toml_str1), ...
       struct('key', 'C:\Users\example.txt'), ...
       'Did not parse a literal string with backslashes successfully.')
      testCase.verifyEqual(toml.decode(toml_str2), ...
       struct('key', 'No leading newline here.'), ...
       'Did not parse a literal string with a leading newline successfully.')
    end

    function testOffsetDateTime(testCase)
      % TOML version
      toml_str = { ...
          'odt = 1979-05-27T07:32:00Z' ...
        , 'odt = 1979-05-27T07:32:00-07:00' ...
        , 'odt = 1979-05-27T07:32:00.999999-07:00' ...
        , 'odt = 1979-05-27 07:32:00Z'...
                 };

      % matlab versions, respectively
      matl_obj = { ...
          datetime('1979-05-27 07:32:00', 'TimeZone', 'UTC') ...
        , datetime('1979-05-27 07:32:00-07:00', 'InputFormat', ...
                   'yyyy-MM-dd HH:mm:ssZ', 'TimeZone', 'UTC') ...
        , datetime('1979-05-27 07:32:00.999999-07:00', 'InputFormat', ...
                   'yyyy-MM-dd HH:mm:ss.SSSSSSSSSZ', 'TimeZone', 'UTC') ...
        , datetime('1979-05-27 07:32:00', 'TimeZone', 'UTC') ...
                 };

      % in structs for even easier reference
      matlab_strct = cellfun(@(a) struct('odt', a), matl_obj, ...
                             'uniformoutput', false);

      error_msg = 'Did not parse a fully qualified datetime successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testLocalDateTime(testCase)
      % TOML version
      toml_str = { ...
          'odt = 1979-05-27T07:32:00' ...
        , 'odt = 1979-05-27T07:32:00.999999' ...
        , 'odt = 1979-05-27 07:32:00'...
                 };

      % matlab versions, respectively
      matl_obj = { ...
          datetime('1979-05-27 07:32:00') ...
        , datetime('1979-05-27 07:32:00.999999', 'InputFormat', ...
                   'yyyy-MM-dd HH:mm:ss.SSSSSSSSS') ...
        , datetime('1979-05-27 07:32:00') ...
                 };

      % in structs for even easier reference
      matlab_strct = cellfun(@(a) struct('odt', a), matl_obj, ...
                             'uniformoutput', false);

      error_msg = 'Did not parse a local datetime successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testLocalDate(testCase)
      % TOML version
      toml_str = { ...
          'odt = 1979-05-27' ...
                 };

      % matlab versions, respectively
      matl_obj = { ...
          datetime('1979-05-27') ...
                 };

      % in structs for even easier reference
      matlab_strct = cellfun(@(a) struct('odt', a), matl_obj, ...
                             'uniformoutput', false);

      error_msg = 'Did not parse a local date successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testLocalTime(testCase)
      % TOML version
      toml_str = { ...
          'odt = 07:32:00' ...
        , 'odt = 07:32:00.999999' ...
                 };

      % matlab versions, respectively
      matl_obj = { ...
          datetime('07:32:00') ...
        , datetime('07:32:00.999999', 'InputFormat', ...
                   'HH:mm:ss.SSSSSSSSS') ...
                 };

      % in structs for even easier reference
      matlab_strct = cellfun(@(a) struct('odt', a), matl_obj, ...
                             'uniformoutput', false);

      error_msg = 'Did not parse a local time successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testArrays(testCase)
      % TOML version
      toml_str = { ...
          'key = [1, 2, 3]' ...
        , 'key = ["a", "b", "c"]' ...
        , 'key = [[1, 2], [''a'', "b"]]' ...
        , 'key = ["abcd", "comma, separated, values"]' ...
        , sprintf('key = [\n1, 2, 3\n]') ...
        , sprintf('key = [\n1,\n2,\n]') ...
                 };

      % matlab versions, respectively
      matlab_strct = { ...
          struct('key', [1, 2, 3]) ...
        , struct('key', {{'a', 'b', 'c'}}) ...
        , struct('key', {{[1, 2], {'a', 'b'}}}) ...
        , struct('key', {{'abcd', 'comma, separated, values'}}) ...
        , struct('key', [1, 2, 3]) ...
        , struct('key', [1, 2]) ...
                     };

      error_msg = 'Did not parse an array successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testHeterogeneousArrays(testCase)
      testCase.assertError(@() toml.decode('key = [1, "abc"]'), ...
        'toml:HeterogeneousArray', ...
        'Did not reject a heterogeneous array.')
    end

    function testInlineTables(testCase)
      % TOML version
      toml_str = { ...
          'tbl = {}' ...
        , 'tbl = {first = "John", last = "Doe"}' ...
        , 'tbl = { x = 1, y = ["a", "b"] }' ...
        , 'tbl = { type.name = "cool type" }' ...
        , 'tbl = { thing = { wow = "very cool thing" } }' ...
                 };

      % matlab versions, respectively
      matl_obj = { ...
          struct() ...
        , struct('first', 'John', 'last', 'Doe') ...
        , struct('x', 1, 'y', {{'a', 'b'}}) ...
        , struct('type', struct('name', 'cool type')) ...
        , struct('thing', struct('wow', 'very cool thing')) ...
                 };

      % in structs for even easier reference
      matlab_strct = cellfun(@(a) struct('tbl', a), matl_obj, ...
                             'uniformoutput', false);

      error_msg = 'Did not parse an inline table successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testFullTables(testCase)
      % TOML version
      toml_str = { ...
          sprintf('[table 1]\nkey1 = "some string"\nkey2 = 123') ...
        , sprintf('[table-1.table-2]\nkey1 = "some string"\nkey2 = 123') ...
        , sprintf(['[table 1]\nkey1 = "some string"\nkey2 = 123\n\n', ...
                   '[table 2]\nkey1 = "another string"\nkey2 = 456']) ...
        , sprintf('[dog."tater.man"]\ntype.name = "pug"') ...
        , sprintf('[x.y.z.w]') ...
        , sprintf('[ a.b.c ]') ...
        , sprintf('[ a . b . c ]') ...
                 };

      % matlab versions, respectively
      matlab_strct = { ...
          struct('table_1', struct('key1', 'some string', 'key2', 123)) ...
        , struct('table_1', struct('table_2', struct('key1', 'some string', ...
                                                     'key2', 123))) ...
        , struct('table_1', struct('key1', 'some string', 'key2', 123), ...
                 'table_2', struct('key1', 'another string', 'key2', 456)) ...
        , struct('dog', struct('tater_man', struct('type', struct('name', 'pug')))) ...
        , struct('x', struct('y', struct('z', struct('w', struct())))) ...
        , struct('a', struct('b', struct('c', struct()))) ...
        , struct('a', struct('b', struct('c', struct()))) ...
                 };

      error_msg = 'Did not parse a table successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testArrayedTables(testCase)
      % TOML version
      toml_str = { ...
          sprintf(['[[products]]\nname = "Hammer"\nsku = 738594937\n\n', ...
                   '[[products]]\n\n' ...
                   '[[products]]\nname = "Nail"\nsku = 28475893\ncolor = "gray"']) ...
        , sprintf(['[[fruit]]\nname = "apple"\n\n[fruit.physical]\n', ...
                   'color = "red"\nshape = "round"\n\n[[fruit.variety]]\n', ...
                   'name = "red delicious"\n\n[[fruit.variety]]\n', ...
                   'name = "granny smith"\n\n[[fruit]]\nname = "banana"\n\n', ...
                   '[[fruit.variety]]\nname = "plantain"']) ...
                 };

      % matlab versions, respectively
      matlab_strct = { ...
          struct('products', {{struct('name', 'Hammer', 'sku', 738594937), ...
                          struct(), struct('name', 'Nail', 'sku', ...
                                           28475893, 'color', 'gray')}}) ...
        , struct('fruit', {{ ...
            struct('name', 'apple', 'physical', ...
                   struct('color', 'red', 'shape', 'round'), ...
                   'variety', {{ ...
                       struct('name', 'red delicious') ...
                     , struct('name', 'granny smith') ...
                   }}), ...
            struct('name', 'banana', 'variety', {{ ...
                struct('name', 'plantain') ...
                   }}) ...
                   }})
                 };

      error_msg = 'Did not parse an array of tables successfully.';

      runStructuredTest(testCase, toml_str, matlab_strct, error_msg)
    end

    function testRedefinedKeys(testCase)
      toml_str = { ...
          sprintf('name = "Tom"\nname = "Pradyun"') ...
        , sprintf('a.b.c = 1\na.d = 2') ...
        , sprintf('a.b = 1\na.b.c = 2') ...
                 };

      testCase.verifyError(@() toml.decode(toml_str{1}), ...
       'toml:RedefinedKey', ...
       'Did not reject a redefined key.')
      testCase.verifyEqual(toml.decode(toml_str{2}), ...
        struct('a', struct('b', struct('c', 1), 'd', 2)), ...
        'Did not accept a valid nesting definition.')
      testCase.verifyError(@() toml.decode(toml_str{3}), ...
       'toml:RedefinedKey', ...
       'Did not reject a redefined key.')
    end

    function testRedefinedTables(testCase)
      toml_str = { ...
          sprintf('[a]\nb = 1\n\n[a]\nc = 2') ...
        , sprintf('[a]\nb = 1\n\n[a.b]\nc = 2') ...
                 };

      for str = toml_str
        testCase.verifyError(@() toml.decode(str{:}), ...
        'toml:RedefinedTable', ...
        'Did not reject a redefined table.')
      end
    end

    function testRedefinedArrays(testCase)
      toml_str = { ...
          sprintf('fruit = []\n[[fruit]]') ...
                 };

      for str = toml_str
        testCase.verifyError(@() toml.decode(str{:}), ...
        'toml:RedefinedArray', ...
        'Did not reject a redefined array.')
      end
    end

    function testNameCollision(testCase)
      toml_str = { ...
          sprintf(['[[fruit]]\nname = "apple"\n\n' ...
                   '[[fruit.variety]]\nname = "red delicious"\n\n' ...
                   '[fruit.variety]\nname = "granny smith"']) ...
                 };

      for str = toml_str
        testCase.verifyError(@() toml.decode(str{:}), ...
        'toml:NameCollision', ...
        'Did not reject a name collision between an array and a table.')
      end
    end

  end

end