classdef TestTomlDecode < matlab.unittest.TestCase

  properties (TestParameter)
    validInput = struct( ...
        'comment_fullLine', {{ ...
            sprintf('\n# this is a comment\n') ...
          , containers.Map() ...
          , 'Improper interpretation of a comment' ...
                   }} ...
      , 'bareKey_underscore', {{ ...
            'key_text = "value"' ...
          , containers.Map('key_text', 'value', 'UniformValues', false) ...
          , 'Did not accept a bare key with an underscore.' ...
                   }} ...
      , 'bareKey_hyphen', {{ ...
          'key-text = "value"' ...
        , containers.Map('key-text', 'value', 'UniformValues', false) ...
        , 'Did not accept a bare key with a dash.' ...
                   }} ...
      , 'bareKey_asciiDigit', {{ ...
          'key123 = "value"' ...
        , containers.Map('key123', 'value', 'UniformValues', false) ...
        , 'Did not accept a bare key with digits.' ...
                   }} ...
      , 'bareKey_uppercase', {{ ...
          'KEY = "value"' ...
        , containers.Map('KEY', 'value', 'UniformValues', false) ...
        , 'Did not accept a bare key with uppercase ASCII.' ...
                   }} ...
      , 'bareKey_allDigits', {{ ...
          '1234 = "value"' ...
        , containers.Map('1234', 'value', 'UniformValues', false) ...
        , 'Did not accept a bare key with only ASCII digits.' ...
                   }} ...
      , 'quotedKey_dotted', {{ ...
          '"127.0.0.1" = "value"' ...
        , containers.Map('127.0.0.1', 'value', 'UniformValues', false) ...
        , 'Did not handle quoted key with invalid format correctly.' ...
                   }} ...
      , 'quotedKey_spaced', {{ ...
          '"character encoding" = "value"' ...
        , containers.Map('character encoding', 'value', 'UniformValues', false) ...
        , 'Did not handle quoted key with space correctly.' ...
                   }} ...
      , 'quotedKey_single', {{ ...
          '''key2'' = "value"' ...
        , containers.Map('key2', 'value', 'UniformValues', false) ...
        , 'Did not handle single-quoted key correctly.' ...
                   }} ...
      , 'quotedKey_nested', {{ ...
          '''quoted "value"'' = "value"' ...
        , containers.Map('quoted "value"', 'value', 'UniformValues', false) ...
        , 'Did not handle nested quoting in key correctly.' ...
                   }} ...
      , 'quotedKey_empty', {{ ...
          '"" = "value"' ...
        , containers.Map('', 'value', 'UniformValues', false) ...
        , 'Did not handle empty quoted key correctly.' ...
                   }} ...
      , 'dottedKey_basic', {{ ...
          'abc.def.ghi = "value"' ...
        , containers.Map('abc', containers.Map('def', containers.Map('ghi', 'value', 'UniformValues', false))) ...
        , 'Did not handle dotted key correctly.' ...
                   }} ...
      , 'dottedKey_quoted', {{ ...
          'abc."def".ghi = "value"' ...
        , containers.Map('abc', containers.Map('def', containers.Map('ghi', 'value', 'UniformValues', false))) ...
        , 'Did not handle dotted and quoted key correctly.' ...
                   }} ...
      , 'dottedKey_nestedQuoting', {{ ...
          'abc."quoted ''value''".ghi = "value"' ...
        , containers.Map('abc', containers.Map('quoted ''value''', containers.Map('ghi', 'value', 'UniformValues', false))) ...
        , 'Did not handle nested quoting in dotted key correctly.' ...
                   }} ...
      , 'integer_decimal', {{ ...
          'key = 123' ...
        , containers.Map('key', int64(123), 'UniformValues', false) ...
        , 'Did not parse a decimal integer correctly.' ...
                   }} ...
      , 'integer_negative', {{ ...
          'key = -10' ...
        , containers.Map('key', int64(-10), 'UniformValues', false) ...
        , 'Did not parse a negative decimal integer correctly.' ...
                   }} ...
      , 'integer_positive', {{ ...
          'key = +10' ...
        , containers.Map('key', int64(10), 'UniformValues', false) ...
        , 'Did not parse a positive decimal integer correctly.' ...
                   }} ...
      , 'integer_binary', {{ ...
          'key = 0b101' ...
        , containers.Map('key', uint64(5), 'UniformValues', false) ...
        , 'Did not parse a binary integer correctly.' ...
                   }} ...
      , 'integer_octal', {{ ...
          'key = 0o1234567' ...
        , containers.Map('key', uint64(342391), 'UniformValues', false) ...
        , 'Did not parse an octal integer correctly.' ...
                   }} ...
      , 'integer_hexadecimal', {{ ...
          'key = 0xdecaf' ...
        , containers.Map('key', uint64(912559), 'UniformValues', false) ...
        , 'Did not parse a hexadecimal integer correctly.' ...
                   }} ...
      , 'integer_zero', {{ ...
          'key = 0' ...
        , containers.Map('key', int64(0), 'UniformValues', false) ...
        , 'Did not parse integer zero correctly.' ...
                   }} ...
      , 'float_positive', {{ ...
          'key = +1.0' ...
        , containers.Map('key', 1, 'UniformValues', false) ...
        , 'Did not parse a positive float correctly.' ...
              }} ...
      , 'float_pi', {{ ...
          'key = 3.1415' ...
        , containers.Map('key', 3.1415, 'UniformValues', false) ...
        , 'Did not parse a float correctly.' ...
                     }} ...
      , 'float_negative', {{ ...
          'key = -0.01' ...
        , containers.Map('key', -0.01, 'UniformValues', false) ...
        , 'Did not parse a negative float correctly.' ...
                          }} ...
      , 'float_positiveExponent', {{ ...
          'key = 5e+22' ...
        , containers.Map('key', 5e22, 'UniformValues', false) ...
        , 'Did not parse an exponentiated float correctly.' ...
                   }} ...
      , 'float_unsignedExponent', {{ ...
          'key = 1e6' ...
        , containers.Map('key', 1e6, 'UniformValues', false) ...
        , 'Did not parse an exponentiated float correctly.' ...
                   }} ...
      , 'float_negativeExponent', {{ ...
          'key = -2E-2' ...
        , containers.Map('key', -2e-2, 'UniformValues', false) ...
        , 'Did not parse an exponentiated float correctly.' ...
                   }} ...
      , 'float_compound', {{ ...
          'key = 6.626e-34' ...
        , containers.Map('key', 6.626e-34, 'UniformValues', false) ...
        , 'Did not parse a float with integral, fractional, and exponential parts correctly.' ...
                          }} ...
      , 'specialFloat_Inf', {{ ...
          'key = inf' ...
        , containers.Map('key', inf, 'UniformValues', false) ...
        , 'Did not parse infinity correctly' ...
                   }} ...
      , 'specialFloat_negativeInf', {{ ...
          'key = -inf' ...
        , containers.Map('key', -inf, 'UniformValues', false) ...
        , 'Did not parse negative infinity correctly' ...
                   }} ...
      , 'specialFloat_NaN', {{ ...
          'key = nan' ...
        , containers.Map('key', NaN, 'UniformValues', false) ...
        , 'Did not parse not-a-number correctly' ...
                   }} ...
      , 'specialFloat_negativeNaN', {{ ...
          'key = -nan' ...
        , containers.Map('key', -NaN, 'UniformValues', false) ...
        , 'Did not parse negative not-a-number correctly' ...
                   }} ...
      , 'string_basic', {{ ...
          'key = "value"' ...
        , containers.Map('key', 'value', 'UniformValues', false) ...
        , 'Did not parse a basic string successfully.' ...
                   }} ...
      , 'string_escapedNewline', {{ ...
          'key = "line 1\nline 2"' ...
        , containers.Map('key', sprintf('line 1\nline 2'), 'UniformValues', false) ...
        , 'Did not parse a basic string with a newline successfully.' ...
                   }} ...
      , 'string_escapedBackspace', {{ ...
          'key = "disappearing A\b"' ...
        , containers.Map('key', char(sprintf('disappearing A\b')), 'UniformValues', false) ...
        , 'Did not parse a basic string with a backspace successfully.' ...
                   }} ...
      , 'string_escapedQuotes', {{ ...
          'key = "escaped \"quote\" marks"' ...
        , containers.Map('key', 'escaped "quote" marks', 'UniformValues', false) ...
        , 'Did not parse a basic string with escaped quotes successfully.' ...
                   }} ...
      , 'string_escapedUnicodeShort', {{ ...
          'key = "inline \u0075nicode"' ...
        , containers.Map('key', 'inline unicode', 'UniformValues', false) ...
        , 'Did not parse a basic string with short Unicode successfully.' ...
                   }} ...
      , 'string_escapedUnicodeLong', {{ ...
          'key = "inline \U00000055nicode"' ...
        , containers.Map('key', 'inline Unicode', 'UniformValues', false) ...
        , 'Did not parse a basic string with long Unicode successfully.' ...
                   }} ...
      , 'string_escapedTab', {{ ...
          'key = "escaped\ttab"' ...
        , containers.Map('key', char(sprintf('escaped\ttab')), 'UniformValues', false) ...
        , 'Did not parse a basic string with an escaped tab successfully.' ...
                   }} ...
      , 'multilineString_basic', {{ ...
          sprintf('key = """\nabcd"""') ...
        , containers.Map('key', 'abcd', 'UniformValues', false) ...
        , 'Did not parse a multiline basic string successfully.' ...
                   }} ...
      , 'multilineString_indent', {{ ...
          sprintf('key = """line 1\n    line 2"""') ...
        , containers.Map('key', char(sprintf('line 1\n    line 2')), 'UniformValues', false) ...
        , 'Did not parse a multiline basic string with indentation successfully.' ...
                   }} ...
      , 'multilineString_backslash', {{ ...
          sprintf('key = """on the \\\n    same line"""') ...
        , containers.Map('key', 'on the same line', 'UniformValues', false) ...
        , 'Did not parse a multiline basic string with a LEB successfully.' ...
                   }} ...
      , 'literalString_backslash', {{ ...
          'key = ''C:\Users\example.txt''' ...
        , containers.Map('key', 'C:\Users\example.txt', 'UniformValues', false) ...
        , 'Did not parse a literal string with backslashes successfully.' ...
                   }} ...
      , 'literalString_newline', {{ ...
          sprintf('key = ''''''\nNo leading newline here.''''''') ...
        , containers.Map('key', 'No leading newline here.', 'UniformValues', false) ...
        , 'Did not parse a literal string with a leading newline successfully.' ...
                   }} ...
      , 'dateTime_fullZ', {{ ...
          'odt = 1979-05-27T07:32:00Z' ...
        , containers.Map('odt', '1979-05-27T07:32:00Z', 'UniformValues', false) ...
        , 'Did not parse a fully qualified datetime successfully.' ...
                   }} ...
      , 'dateTime_fullOffset', {{ ...
          'odt = 1979-05-27T07:32:00-07:00' ...
        , containers.Map('odt', '1979-05-27T07:32:00-07:00', 'UniformValues', false) ...
        , 'Did not parse a fully qualified datetime successfully.' ...
                   }} ...
      , 'dateTime_fullFracSeconds', {{ ...
          'odt = 1979-05-27T07:32:00.999999-07:00' ...
        , containers.Map('odt', '1979-05-27T07:32:00.999999-07:00', 'UniformValues', false) ...
        , 'Did not parse a fully qualified datetime successfully.' ...
                   }} ...
      , 'dateTime_fullNoT', {{ ...
          'odt = 1979-05-27 07:32:00Z'...
        , containers.Map('odt', '1979-05-27T07:32:00Z', 'UniformValues', false) ...
        , 'Did not parse a fully qualified datetime successfully.' ...
                   }} ...
      , 'dateTime_local', {{ ...
          'odt = 1979-05-27T07:32:00' ...
        , containers.Map('odt', '1979-05-27T07:32:00', 'UniformValues', false) ...
        , 'Did not parse a local datetime successfully.' ...
                   }} ...
      , 'dateTime_localFracSec', {{ ...
          'odt = 1979-05-27T07:32:00.999999' ...
        , containers.Map('odt', '1979-05-27T07:32:00.999999', 'UniformValues', false) ...
        , 'Did not parse a local datetime successfully.' ...
                   }} ...
      , 'dateTime_localNoT', {{ ...
          'odt = 1979-05-27 07:32:00'...
        , containers.Map('odt', '1979-05-27T07:32:00', 'UniformValues', false) ...
        , 'Did not parse a local datetime successfully.' ...
                   }} ...
      , 'date_local', {{ ...
          'odt = 1979-05-27' ...
        , containers.Map('odt', '1979-05-27', 'UniformValues', false) ...
        , 'Did not parse a local date successfully.' ...
                   }} ...
      , 'time_local', {{ ...
          'odt = 07:32:00' ...
        , containers.Map('odt', '07:32:00', 'UniformValues', false) ...
        , 'Did not parse a local time successfully.' ...
                   }} ...
      , 'time_localFracSec', {{ ...
          'odt = 07:32:00.999999' ...
        , containers.Map('odt', '07:32:00.999999', 'UniformValues', false) ...
        , 'Did not parse a local time successfully.' ...
                   }} ...
      , 'array_int', {{ ...
          'key = [1, 2, 3]' ...
        , containers.Map('key', int64([1, 2, 3])) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'array_char', {{ ...
          'key = ["a", "b", "c"]' ...
        , containers.Map({'key'}, {{'a', 'b', 'c'}}) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'array_nested', {{ ...
          'key = [[1, 2], [''a'', "b"]]' ...
        , containers.Map('key', {int64([1, 2]), {'a', 'b'}}) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'array_strings', {{ ...
          'key = ["abcd", "comma, separated, values"]' ...
        , containers.Map({'key'}, {{'abcd', 'comma, separated, values'}}) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'array_newlines', {{ ...
          sprintf('key = [\n1, 2, 3\n]') ...
        , containers.Map('key', int64([1, 2, 3])) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'array_moreNewlines', {{ ...
          sprintf('key = [\n1,\n2,\n]') ...
        , containers.Map('key', int64([1, 2])) ...
        , 'Did not parse an array successfully.' ...
                   }} ...
      , 'inlineTable_empty', {{ ...
          'tbl = {}' ...
        , containers.Map('tbl', containers.Map()) ...
        , 'Did not parse an inline table successfully.' ...
                   }} ...
      , 'inlineTable_basic', {{ ...
          'tbl = {first = "John", last = "Doe"}' ...
        , containers.Map('tbl', containers.Map({'first', 'last'}, {'John', 'Doe'}, 'UniformValues', false)) ...
        , 'Did not parse an inline table successfully.' ...
                   }} ...
      , 'inlineTable_array', {{ ...
          'tbl = { x = 1, y = ["a", "b"] }' ...
        , containers.Map('tbl', containers.Map({'x', 'y'}, {int64(1), {'a', 'b'}})) ...
        , 'Did not parse an inline table successfully.' ...
                   }} ...
      , 'inlineTable_nested', {{ ...
          'tbl = { type.name = "cool type" }' ...
        , containers.Map('tbl', containers.Map('type', containers.Map('name', 'cool type', 'UniformValues', false))) ...
        , 'Did not parse an inline table successfully.' ...
                   }} ...
      , 'inlineTable_deepNested', {{ ...
          'tbl = { thing = { wow = "very cool thing" } }' ...
        , containers.Map('tbl', containers.Map('thing', containers.Map('wow', 'very cool thing', 'UniformValues', false))) ...
        , 'Did not parse an inline table successfully.' ...
                   }} ...
      , 'table_basic', {{ ...
          sprintf('[table_1]\nkey1 = "some string"\nkey2 = 123') ...
        , containers.Map('table_1', containers.Map({'key1', 'key2'}, {'some string', int64(123)})) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_dotted', {{ ...
          sprintf('[table_1.table_2]\nkey1 = "some string"\nkey2 = 123') ...
        , containers.Map('table_1', containers.Map('table_2', containers.Map({'key1', 'key2'}, {'some string', int64(123)}))) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_multiple', {{ ...
          ['[table_1]' 0xA 'key1 = "some string"' 0xA 'key2 = 123' 0xA 0xA ...
              '[table_2]' 0xA 'key1 = "another string"' 0xA 'key2 = 456'] ...
        , containers.Map( ...
            {'table_1', 'table_2'}, ...
            { ...
              containers.Map({'key1', 'key2'}, {'some string', int64(123)}), ...
              containers.Map({'key1', 'key2'}, {'another string', int64(456)}) ...
            } ...
          ) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_quotedDotted', {{ ...
          ['[dog."tater.man"]' 0xA 'type.name = "pug"'] ...
        , containers.Map('dog', containers.Map('tater.man', containers.Map('type', containers.Map('name', 'pug', 'UniformValues', false)))) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_nestedDotted', {{ ...
          sprintf('[x.y.z.w]') ...
        , containers.Map('x', containers.Map('y', containers.Map('z', containers.Map('w', containers.Map())))) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_spacedKey', {{ ...
          sprintf('[ a.b.c ]') ...
        , containers.Map('a', containers.Map('b', containers.Map('c', containers.Map()))) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'table_multiSpacedKey', {{ ...
          sprintf('[ a . b . c ]') ...
        , containers.Map('a', containers.Map('b', containers.Map('c', containers.Map()))) ...
        , 'Did not parse a table successfully.' ...
                   }} ...
      , 'arrayedTable_basic', {{ ...
          ['[[products]]' 0xA 'name = "Hammer"' 0xA 'sku = 738594937' 0xA 0xA ...
            '[[products]]' 0xA 0xA ...
            '[[products]]' 0xA 'name = "Nail"' 0xA 'sku = 28475893' 0xA 'color = "gray"'] ...
          , containers.Map('products', { ...
              containers.Map({'name', 'sku'}, {'Hammer', int64(738594937)}), ...
              containers.Map(), ...
              containers.Map({'name', 'sku', 'color'}, {'Nail', int64(28475893), 'gray'}) ...
            }) ...
        , 'Did not parse an array of tables successfully.' ...
                   }} ...
      , 'arrayedTable_nested', {{ ...
          ['[[fruit]]' 0xA 'name = "apple"' 0xA 0xA '[fruit.physical]' 0xA ...
            'color = "red"' 0xA 'shape = "round"' 0xA 0xA '[[fruit.variety]]' 0xA ...
            'name = "red delicious"' 0xA 0xA '[[fruit.variety]]' 0xA ...
            'name = "granny smith"' 0xA 0xA '[[fruit]]' 0xA 'name = "banana"' 0xA 0xA ...
            '[[fruit.variety]]' 0xA 'name = "plantain"'] ...
        , containers.Map('fruit', { ...
            containers.Map({'name', 'physical', 'variety'}, ...
              { ...
                'apple', ...
                 containers.Map({'color', 'shape'}, {'red', 'round'}, 'UniformValues', false), ...
                 {containers.Map('name', 'red delicious', 'UniformValues', false), containers.Map('name', 'granny smith', 'UniformValues', false)} ...
              } ...
            ), ...
            containers.Map({'name', 'variety'}, {'banana', {containers.Map('name', 'plantain', 'UniformValues', false)}}) ...
          }) ...
        , 'Did not parse an array of tables successfully.' ...
                   }} ...
      , 'redefinedKey_CorrectNested', {{ ...
          ['a.b.c = 1' 0xA 'a.d = 2'] ...
        , containers.Map('a', containers.Map({'b', 'd'}, {containers.Map('c', int64(1), 'UniformValues', false), int64(2)})) ...
        , 'Did not accept a valid nesting definition.' ...
                   }}, ...
        'iso8601_string_filename_issue18', {{
          'data_files = ["2022-05-12_rx_t2s001", "2022-05-12_rx_t1s001"]', ...
          containers.Map({'data_files'}, {{'2022-05-12_rx_t2s001', '2022-05-12_rx_t1s001'}}), ...
          'Did not parse strings containing dates as normal strings' ...
                   }},
        'multiline_array_issue9', {{
          ['a3r3csplit = [' 0xA '    [' 0xA '    5, 6, 8' '    ],' ...
           0xA '    [' 0xA '    1, 2, 3' '    ],' 0xA '    [' 0xA '    10, 12, 14' '    ]' 0xA ']'], ...
          containers.Map({'a3r3csplit'}, {{[5 6 8], [1 2 3], [10 12 14]}}), ...
          'Did not parse array with newlines inside correctly' ...
                   }},
        'empty_strings_issue5', {{
          ['num = 1000' 0xA 'text = ""' 0xA 'words = "All rights reserved - "'], ...
          containers.Map({'num', 'text', 'words'}, {int64(1000), '', 'All rights reserved - '}), ...
          'Failed to handle an empty string literal' ...
                   }},
        'backslash_escape_issue4', {{
          'a = "A\\B"', ...
          containers.Map('a', 'A\B'), ...
          'Did not properly handle an escaped backslash' ...
                   }}
        );

    invalidInput = struct( ...
        'noValue', {{ ...
            'key = #' ...
          , 'toml:UnexpectedValue' ...
          , 'Did not fail for unspecified value.' ...
                    }} ...
      , 'emptyBareKey', {{ ...
          sprintf('\nkey = "value"\n= "value2"') ...
        , 'toml:UnexpectedStatement' ...
        , 'Did not fail for empty bare key.' ...
                   }} ...
      , 'decimalIntLeadingZeros_1', {{ ...
          'key = 01' ...
        , 'toml:LeadingZero' ...
        , 'Did not raise an error for leading zeros on a decimal integer.' ...
                   }} ...
      , 'decimalIntLeadingZeros_2', {{ ...
          'key = 000123' ...
        , 'toml:LeadingZero' ...
        , 'Did not raise an error for leading zeros on a decimal integer.' ...
                   }} ...
      , 'upperCaseBoolean_1', {{ ...
          'key = True' ...
        , 'toml:UnexpectedValue' ...
        , 'Did not raise an error for uppercase Boolean values.' ...
                   }} ...
      , 'upperCaseBoolean_2', {{ ...
          'key = FALSE' ...
        , 'toml:UnexpectedValue' ...
        , 'Did not raise an error for uppercase Boolean values.' ...
                   }} ...
      , 'nameCollision', {{ ...
          sprintf(['[[fruit]]\nname = "apple"\n\n' ...
                   '[[fruit.variety]]\nname = "red delicious"\n\n' ...
                   '[fruit.variety]\nname = "granny smith"']) ...
        , 'toml:NameCollision' ...
        , 'Did not reject a name collision between an array and a table.' ...
                   }} ...
      , 'redefinedArray', {{ ...
          sprintf('fruit = []\n[[fruit]]') ...
        , 'toml:NameCollision' ...
        , 'Did not reject a redefined array.' ...
                   }} ...
      , 'redefinedTable_1', {{ ...
          sprintf('[a]\nb = 1\n\n[a]\nc = 2') ...
        , 'toml:NameCollision' ...
        , 'Did not reject a redefined table.' ...
                   }} ...
      , 'redefinedTable_2', {{ ...
          sprintf('[a]\nb = 1\n\n[a.b]\nc = 2') ...
        , 'toml:NameCollision' ...
        , 'Did not reject a redefined table.' ...
                   }} ...
      , 'validation_unquotedString', {{ ...
          'key = value' ...
        , 'toml:UnexpectedValue' ...
        , 'Failed to reject invalid TOML data: identifier used as value.' ...
                   }} ...
      , 'validation_undefinedInteger', {{ ...
          'key = 0q123' ...
        , 'toml:ExpectedLineBreak' ...
        , 'Failed to reject invalid TOML data: invalid integer format.' ...
                   }} ...
      , 'validation_rawHTML', {{ ...
          'key = <a href="github.com">good stuff here</a>' ...
        , 'toml:UnexpectedValue' ...
        , 'Failed to reject invalid TOML data: unquoted HTML.' ...
                   }} ...
      , 'validation_rawJSON', {{ ...
          'key = {"key1": null, "key2": true}' ...
        , 'toml:MissingToken' ...
        , 'Failed to reject invalid TOML data: unquoted JSON.' ...
                   }} ...
      , 'validation_unquotedCurlyBrace', {{ ...
          'key = }' ...
        , 'toml:UnexpectedValue' ...
        , 'Failed to reject invalid TOML data: unquoted symbol.' ...
                   }} ...
      , 'validation_unquotedSquareBracket', {{ ...
          'key = ]' ...
        , 'toml:UnexpectedValue' ...
        , 'Failed to reject invalid TOML data: unquoted symbol.' ...
                   }} ...
      , 'validation_unquotedDot', {{ ...
          'key = .' ...
        , 'toml:UnexpectedValue' ...
        , 'Failed to reject invalid TOML data: unquoted symbol.' ...
                   }} ...
      , 'validation_incompleteArray', {{ ...
          'key = ["abcd", "efgh"' ...
        , 'toml:MissingToken' ...
        , 'Failed to reject invalid TOML data: unclosed array.' ...
                   }} ...
      , 'validation_incompleteStringDouble', {{ ...
          'key = "abcd' ...
        , 'toml:EndOfInput' ...
        , 'Failed to reject invalid TOML data: unclosed double quote.' ...
                   }} ...
      , 'validation_incompleteStringSingle', {{ ...
          'key = ''abcd' ...
        , 'toml:UnterminatedString' ...
        , 'Failed to reject invalid TOML data: unclosed single quote.' ...
                   }} ...
      , 'validation_incompleteTable', {{ ...
          'key = {subkey = "value"' ...
        , 'toml:MissingToken' ...
        , 'Failed to reject invalid TOML data: unclosed inline table.' ...
                   }} ...
      , 'validation_incompleteStringWithTrailingLine', {{ ...
          sprintf('key1 = "abcd\nkey2 = 1234') ...
        , 'toml:LineBreakInBasicString' ...
        , ['Failed to reject invalid TOML data: unclosed double quote with ' ...
           'data on the following line.'] ...
                   }} ...
      , 'validation_incompleteMultilineString', {{ ...
          sprintf('key1 = """\nabcd\nefgh\n') ...
        , 'toml:EndOfInput' ...
        , 'Failed to reject invalid TOML data: unclosed multiline string.' ...
                   }} ...
      , 'specialFloat_uppercaseInf', {{ ...
          'key = INF' ...
        , 'toml:UnexpectedValue' ...
        , 'Did not raise an error for uppercase infinity.' ...
                   }} ...
      , 'specialFloat_uppercaseNaN', {{ ...
          'key = NaN' ...
        , 'toml:UnexpectedValue' ...
        , 'Did not raise an error for uppercase not-a-number.' ...
                   }} ...
      , 'redefinedKey_basic', {{ ...
          sprintf('name = "Tom"\nname = "Pradyun"') ...
        , 'toml:NameCollision' ...
        , 'Did not reject a redefined key.' ...
                   }} ...
      , 'redefinedKey_nested', {{ ...
          sprintf('a.b = 1\na.b.c = 2') ...
        , 'toml:RedefinedKey' ...
        , 'Did not reject a redefined key.' ...
                   }} ...
        );

    invalidEscape = num2cell(setdiff(char(33:126), 'btnfr"\uU'));
  end

  methods (Test, ParameterCombination = 'sequential')

    function testValidInputs(testCase, validInput)
      testCase.verifyEqual(toml.decode(validInput{1}), validInput{2:3})
    end

    function testInvalidInputs(testCase, invalidInput)
      testCase.verifyError(@() toml.decode(invalidInput{1}), invalidInput{2:3})
    end

    function testInvalidStringEscapes(testCase, invalidEscape)
      ch = char(invalidEscape);
      str_to_parse = sprintf('key = "\\%s"', ch);
      testCase.verifyError(@() toml.decode(str_to_parse), ...
                           'toml:ReservedEscapeSequence', ...
                           ['Did not reject a reserved escape sequence: "\', ch, '"'])
    end

  end

end
