% DECODE convert TOML to native MATLAB datatypes
%
%   DECODE(toml_str) returns the MATLAB representation of the
%   TOML-formatted data in `toml_str`. If it is invalid TOML, an
%   appropriate exception will be raised.
%
%   See also TOML.READ

function obj_out = decode(toml_str)
  obj_out = struct();
  location_stack = {};

  while true
    toml_str = consume_comment(toml_str);
    if isempty(toml_str)
      break
    end

    if startsWith(toml_str, '[[') % array
      toml_str = toml_str(3:end);
      [location_stack, toml_str] = consume_key(toml_str, ']]');
      location_stack = adjust_key_stack(obj_out, location_stack);
      [obj_out, location_stack] = create_nested_field(obj_out, location_stack, {struct()});
      toml_str = expect_line_break_or_comment_or_eof(toml_str);

    elseif startsWith(toml_str, '[') % table
      toml_str = toml_str(2:end);
      [location_stack, toml_str] = consume_key(toml_str, ']');
      location_stack = adjust_key_stack(obj_out, location_stack);
      [obj_out, location_stack] = create_nested_field(obj_out, location_stack, struct());
      toml_str = expect_line_break_or_comment_or_eof(toml_str);

    elseif startsWith(toml_str, '"') || startsWith(toml_str, "'") || is_key_char(toml_str(1)) % key / value pair
      [key_seq, toml_str] = consume_key(toml_str, '=');
      [value_fix, toml_str] = consume_value(toml_str);
      obj_out = set_nested_field(obj_out, [location_stack, key_seq], value_fix);
      toml_str = expect_line_break_or_comment_or_eof(toml_str);
      
    elseif ~startsWith(toml_str, '#')
      error('toml:UnexpectedStatement', ...
        ['Found unrecognized statement: ' toml_str]);
    end
  end
end

function [obj, location_stack] = create_nested_field(obj, location_stack, item)
  try
    existing_val = get_nested_field(obj, location_stack);

    if iscell(item)
      location_stack{end + 1} = length(existing_val) + 1;
      obj = set_nested_field(obj, location_stack, struct());
    end

  catch
    obj = set_nested_field(obj, location_stack, item);

    if iscell(item)
      location_stack{end + 1} = 1;
    end
  end
end
