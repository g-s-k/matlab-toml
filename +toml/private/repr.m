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
        str = ['"', strrep(strrep(obj, '\', '\\'), '"', '\"'), '"'];
      else
        str = repr(reshape(cellstr(obj), 1, []));
      end

    % Booleans
    case 'logical'
      reprs = {'false', 'true'};
      str = reprs{obj + 1};

    % numbers
    case { 'double', 'int64' }
      if numel(obj) == 1
        str = lower(num2str(obj));
      elseif ndims(obj) == 2 && size(obj, 1) == 1
        cel = arrayfun(@repr, obj, 'uniformoutput', false);
        str = ['[', strjoin(cel, ', '), ']'];
      else
        cel = cell(1, size(obj, 1));
        indices = repmat({':'}, 1, ndims(obj));
        for row = 1:size(obj, 1)
          indices{1} = row;
          cel{row} = repr(squeeze(obj(indices{:})));
        end
        str = ['[', strjoin(cel, ', '), ']'];
      end

    % cell arrays
    case 'cell'
      if all(cellfun(@isstruct, obj)) || all(cellfun(@(el) isa(el, 'containers.Map'), obj))
        fmtter = @(a) sprintf('[[%s]]%s%s', parent, newline, repr(a));
        cel_str = cellfun(fmtter, obj, 'uniformoutput', false);
        str = strjoin(cel_str, newline);
      else
        cel_mod = cellfun(@repr, obj, 'uniformoutput', false);
        str = ['[', strjoin(cel_mod, ', '), ']'];
      end

    % maps
    case 'containers.Map'
      fn = keys(obj);
      vals = values(obj);
      str = '';
      for indx = 1:numel(vals)
        new_parent = fn{indx};
        current_item_repr = repr(vals{indx}, new_parent);
        if isa(vals{indx}, 'containers.Map')
          if nargin > 1
            fmt_str = ['[', parent, '.%s]%s%s'];
            item = sprintf(fmt_str, fn{indx}, newline, current_item_repr);
            new_parent = [parent, '.', fn{indx}];
          else
            item = sprintf("[%s]%s%s", fn{indx}, newline, current_item_repr);
          end
        elseif iscell(vals{indx}) && all(cellfun(@(el) isa(el, 'containers.Map'), vals{indx}))
          item = current_item_repr;
        else
          item = sprintf("%s = %s", fn{indx}, current_item_repr);
        end
        str = sprintf("%s%s%s", str, item, newline);
      end

    % structures
    case 'struct'
      fn = fieldnames(obj);
      vals = struct2cell(obj);
      str = '';
      for indx = 1:numel(vals)
        new_parent = fn{indx};
        current_item_repr = repr(vals{indx}, new_parent);
        if isstruct(vals{indx})
          if nargin > 1
            fmt_str = ['[', parent, '.%s]%s%s'];
            item = sprintf(fmt_str, fn{indx}, newline, current_item_repr);
            new_parent = [parent, '.', fn{indx}];
          else
            item = sprintf("[%s]%s%s", fn{indx}, newline, current_item_repr);
          end
        elseif iscell(vals{indx}) && all(cellfun(@isstruct, vals{indx}))
          item = current_item_repr;
        else
          item = sprintf("%s = %s", fn{indx}, current_item_repr);
        end
        str = sprintf("%s%s%s", str, item, newline);
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