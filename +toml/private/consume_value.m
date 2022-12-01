function [val, str] = consume_value(str)
  str = trimstart(str);
  
  if isempty(str)
    error('toml:MissingValue', ...
      'Expected a value, found end of input.');

  elseif startsWith(str, '[')
    str = str(2:end);
    val = {};
    first = true;
    while ~isempty(str)
      str = consume_comment(str);

      if first
        if startsWith(str, ',')
          error('toml:LeadingComma', ...
            'Comma found before first element in array.');
        end
      elseif ~startsWith(str, ']')
        str = expect(str, ',');
      end

      str = trimstart(str, true);
      if startsWith(str, ']')
        str = str(2:end);
        break
      end
      
      if ~startsWith(str, '#')
        [item, str] = consume_value(str);
        val{end+1} = item;
        first = false;
      end
    end
    
  elseif startsWith(str, '{')
    str = str(2:end);
    val = struct();
    first = true;
    while ~isempty(str)
      str = trimstart(str);
      if startsWith(str, '}')
        str = str(2:end);
        break
      end
      if ~first
        str = expect(str, ',');
      end
      [key_seq, str] = consume_key(str, '=');
      [item, str] = consume_value(str);
      val = set_nested_field(val, key_seq, item);
      first = false;
    end

  elseif startsWith(str, 'true')
    val = true;
    str = str(5:end);
  elseif startsWith(str, 'false')
    val = false;
    str = str(6:end);
    
  elseif startsWith(str, "'")
    [val, str] = consume_literal_string(str, true);
  elseif startsWith(str, '"')
    [val, str] = consume_basic_string(str, true);

  elseif startsWith(str, '+')
    [val, str] = consume_signed_value(str(2:end));
  elseif startsWith(str, '-')
    [val, str] = consume_signed_value(str(2:end));
    val = -val;
    
  elseif startsWith(str, "inf")
    val = Inf;
    str = str(4:end);
  elseif startsWith(str, "nan")
    val = NaN;
    str = str(4:end);
    
  elseif startsWith(str, "0b")
    [digits, str] = consume_integer(str(3:end), 2);
    val = uint64(bin2dec(strrep(digits, '_', '')));
  elseif startsWith(str, "0o")
    [digits, str] = consume_integer(str(3:end), 8);
    val = uint64(base2dec(strrep(digits, '_', ''), 8));
  elseif startsWith(str, "0x")
    [digits, str] = consume_integer(str(3:end), 16);
    val = uint64(hex2dec(strrep(digits, '_', '')));
    
  elseif isstrprop(str(1), 'digit')
    [digits, str] = consume_integer(str, 10);
    
    % date
    if numel(digits) == 4 && startsWith(str, '-')
      [month, str] = consume_integer(str(2:end), 10);
      str = expect(str, '-');
      [day, str] = consume_integer(str, 10);
      val = [digits '-' month '-' day];
      
      if startsWith(str, 'T') || startsWith(str, 't') || ...
         (strncmp(str, ' ', 1) && numel(str) > 1 && isstrprop(str(2), 'digit'))
        [time_str, str] = consume_time(str(2:end));
        val = [val 'T' time_str];
        
        if startsWith(str, 'Z') || startsWith(str, 'z')
          val = [val 'Z'];
          str = str(2:end);
        elseif startsWith(str, '+') || startsWith(str, '-')
          sign = str(1);
          [hour, str] = consume_integer(str(2:end), 10);
          str = expect(str, ':');
          [minute, str] = consume_integer(str, 10);
          val = [val sign hour ':' minute];
        end
      end

    % time
    elseif numel(digits) == 2 && startsWith(str, ':')
      [val, str] = consume_time(str, digits);

    % number
    else
      has_fractional = false;
      has_exponent = false;

      % float with fractional
      if startsWith(str, '.')
        has_fractional = true;
        [frac_part, str] = consume_integer(str(2:end), 10);
        digits = [digits '.' frac_part];
      end

      % float with exponential
      if startsWith(str, 'e') || startsWith(str, 'E')
        has_exponent = true;
        str = str(2:end);
        digits = [digits 'e'];

        if startsWith(str, '+')
          str = str(2:end);
        elseif startsWith(str, '-')
          digits = [digits '-'];
          str = str(2:end);
        end

        [exp_part, str] = consume_integer(str, 10);
        digits = [digits exp_part];
      end
      
      val = str2num(strrep(digits, '_', ''));
      if ~has_fractional && ~has_exponent
        if numel(digits) > 1 && digits(1) == '0'
          error('toml:LeadingZero', ...
            'Encountered integer value with a leading zero.');
        end
        val = int64(val);
      end
    end

  else
    error('toml:UnexpectedValue', ...
      ['Encountered an unknown value: ', str]);
  end
end

function [num, str] = consume_signed_value(str)
  if startsWith(str, '0b') || startsWith(str, '0o') || startsWith(str, '0x')
    error('toml:SignOnNonBase10', ...
      'Encountered a plus/minus sign on an unsigned int value.');
  elseif startsWith(str, '+') || startsWith(str, '-')
    error('toml:MultipleSigns', ...
      'Encountered multiple plus/minus signs in a row.');
  end
  [num, str] = consume_value(str);
  if ~isnumeric(num)
    error('toml:InvalidSign', ...
      'Encountered a plus/minus sign on a non-numeric value.');
  end
end

function [digits, str] = consume_integer(str, base)
  switch base
    case 2
      c_valid = @(c) c == '0' || c == '1';
    case 8
      c_valid = @(c) c >= '0' && c <= '7';
    case 10
      c_valid = @(c) c >= '0' && c <= '9';
    case 16
      c_valid = @(c) (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
  end

  digits = str;
  for idx = 1:numel(str)
    if ~c_valid(str(idx)) && str(idx) ~= '_'
      digits = str(1:idx-1);
      break
    end
  end
  
  if startsWith(digits, '_')
    error('toml:LeadingUnderscore', ...
      'Numbers cannot have a leading underscore.');
  elseif endsWith(digits, '_')
    error('toml:TrailingUnderscore', ...
      'Numbers cannot have a trailing underscore.');
  elseif isempty(digits)
    error('toml:NoDigits', ...
      'Expected at least one digit.');
  end
  
  str = str(numel(digits)+1:end);
end

function [val, str] = consume_time(str, hour)
  if nargin < 2
    [hour, str] = consume_integer(str, 10);
  end

  str = expect(str, ':');
  [minute, str] = consume_integer(str, 10);
  str = expect(str, ':');
  [second, str] = consume_integer(str, 10);

  val = [hour ':' minute ':' second];
  
  if startsWith(str, '.')
    [sub_second, str] = consume_integer(str(2:end), 10);
    val = [val '.' sub_second(1:min(6, numel(sub_second)))];
  end
end
