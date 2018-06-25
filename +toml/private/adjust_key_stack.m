function key_stack = adjust_key_stack(obj, key_stack)
  if length(key_stack) > 0
    % see if another one is there
    switch class(obj)
      case 'cell'
        if ischar(key_stack{1})
          key_stack = [{length(obj)}, key_stack];
        end
        nested_obj = obj{key_stack{1}};
      case 'struct'
        try
          nested_obj = obj.(key_stack{1});
        catch
          if numel(key_stack) > 1
            if ischar(key_stack{2})
              nested_obj = struct();
            else
              nested_obj = {};
            end
          else
            nested_obj = [];
          end
        end
    end

    % go down another level
    key_stack = [key_stack(1), adjust_key_stack(nested_obj, key_stack(2:end))];
  end
end