% REPR TOML representation of a MATLAB object
%
%   REPR(obj) returns the TOML representation of `obj`.

function str = repr(obj, parent)

  if ispc
    newline = sprintf('\r\n');
  else
    newline = sprintf('\n');
  end

  switch class(obj)

    % strings
    case 'char'
      if isrow(obj) || isempty(obj)
        % escape characters
        esc_char = {'\\', '\b', '\t', '\n', '\f', '\r', '\"'};
        for ii = 1:length(esc_char)
          obj = strrep(obj, sprintf(esc_char{ii}), esc_char{ii});
        end
        % convert chars above \x052f to escaped unicode \u
        unicode_chars = find(double(obj) > hex2dec('52F'));
        for jj = unicode_chars
          obj = strrep(obj, obj(jj), sprintf('\\u%04s', dec2hex(double(obj(jj)))));
        end
        % wrap in basic string double quotes
        str = ['"', obj, '"'];
      else
        str = repr(reshape(cellstr(obj), 1, []));
      end

    % Booleans
    case 'logical'
      reprs = {'false', 'true'};
      str = reprs{obj + 1};

    % numbers
    case 'double'
      if numel(obj) == 1
        str = lower(num2str(obj));
      else
        str = bracketarray(obj);
      end

    % cell arrays
    case 'cell'
      if all(cellfun(@isstruct, obj))
        fmtter = @(a) sprintf('[[%s]]%s%s', parent, newline, repr(a));
        cel_str = cellfun(fmtter, obj, 'uniformoutput', false);
        str = strjoin(cel_str, newline);
      else
        cel_mod = cellfun(@repr, obj, 'uniformoutput', false);
        str = ['[', strjoin(cel_mod, ', '), ']'];
      end

    % structures
    case 'struct'
      obj = sortfields(obj);
      fn = fieldnames(obj);
      vals = struct2cell(obj);
      str = '';
      for indx = 1:numel(vals)
        new_parent = fn{indx};
        if isstruct(vals{indx})
          if nargin > 1
            fmt_str = ['%1$s[', parent, '.%2$s]%4$s%3$s'];
            new_parent = [parent, '.', fn{indx}];
          else
            fmt_str = '%1$s[%2$s]%4$s%3$s';
          end
        elseif iscell(vals{indx}) && all(cellfun(@isstruct, vals{indx}))
          fmt_str = '%1$s%3$s%4$s';
        else
          fmt_str = '%1$s%2$s = %3$s%4$s';
        end
        str = sprintf(fmt_str, str, fn{indx}, repr(vals{indx}, new_parent), newline);
      end

    % datetime objects
    case 'datetime'
      obj.Format = 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS';
      if ~isempty(obj.TimeZone)
        obj.Format = [obj.Format, 'XXX'];
      end
      str = char(obj);

    % unrecognized type
    otherwise
      error('toml:NonEncodableType', ...
            'Cannot encode type as TOML: %s', class(obj))
  end
end