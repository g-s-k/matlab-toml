% REPR TOML representation of a MATLAB object
%
%   REPR(obj) returns the TOML representation of `obj`.

function str = repr(obj, parent)

  switch class(obj)

    % strings
    case 'char'
      if isrow(obj) || isempty(obj)
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
        cel = arrayfun(@repr, obj, 'uniformoutput', false);
        str = ['[', strjoin(cel, ', '), ']'];
      end

    % cell arrays
    case 'cell'
      if all(cellfun(@isstruct, obj))
        fmtter = @(a) sprintf('[[%s]]\n%s', parent, repr(a));
        cel_str = cellfun(fmtter, obj, 'uniformoutput', false);
        str = strjoin(cel_str, sprintf('\n'));
      else
        cel_mod = cellfun(@repr, obj, 'uniformoutput', false);
        str = ['[', strjoin(cel_mod, ', '), ']'];
      end

    % structures
    case 'struct'
      fn = fieldnames(obj);
      vals = struct2cell(obj);
      str = '';
      for indx = 1:numel(vals)
        new_parent = fn{indx};
        if isstruct(vals{indx})
          if nargin > 1
            fmt_str = ['%s[', parent, '.%s]\n%s'];
            new_parent = [parent, '.', new_parent];
          else
            fmt_str = '%s[%s]\n%s';
          end
        elseif iscell(vals{indx}) && all(cellfun(@isstruct, vals{indx}))
          fmt_str = '%1$s%3$s\n';
        else
          fmt_str = '%s%s = %s\n';
        end
        str = sprintf(fmt_str, str, fn{indx}, repr(vals{indx}, new_parent));
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