function str = jsonify(obj)
	if isa(obj, 'containers.Map')
		print_key_value = @(k) sprintf('"%s":%s', escape_str(k), toml.testing.jsonify(obj(k)));
		keys_and_values = cellfun(print_key_value, keys(obj), 'uniformoutput', false);
		str = ['{', strjoin(keys_and_values, ','), '}'];

	elseif isstruct(obj)
		print_key_value = @(k) sprintf('"%s":%s', escape_str(k), toml.testing.jsonify(obj.(k)));
		keys_and_values = cellfun(print_key_value, fieldnames(obj), 'uniformoutput', false);
		str = ['{', strjoin(keys_and_values, ','), '}'];

	elseif iscell(obj)
		values = cellfun(@toml.testing.jsonify, obj, 'uniformoutput', false);
		str = ['[', strjoin(values, ','), ']'];

	elseif ischar(obj)
		if regexp(obj, '^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?[Z+-]')
			str = ['{"type":"datetime","value":"', obj, '"}'];
		elseif regexp(obj, '^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}')
			str = ['{"type":"datetime-local","value":"', obj, '"}'];
		elseif regexp(obj, '^\d{4}-\d{2}-\d{2}$')
			str = ['{"type":"date-local","value":"', obj, '"}'];
		elseif regexp(obj, '^\d{2}:\d{2}:\d{2}(\.\d+)?$')
			str = ['{"type":"time-local","value":"', obj, '"}'];
		else
			str = ['{"type":"string","value":"', escape_str(obj), '"}'];
		end

	elseif numel(obj) ~= 1 && ndims(obj) == 2 && size(obj, 1) == 1
		values = arrayfun(@toml.testing.jsonify, obj, 'uniformoutput', false);
		str = ['[', strjoin(values, ','), ']'];

	elseif numel(obj) ~= 1
	    cel = cell(1, size(obj, 1));
	    indices = repmat({':'}, 1, ndims(obj));
	    for row = 1:size(obj, 1)
			indices{1} = row;
			cel{row} = toml.testing.jsonify(squeeze(obj(indices{:})));
	    end
	    str = ['[', strjoin(cel, ', '), ']'];		

	elseif islogical(obj)
		if obj
			val = 'true';
		else
			val = 'false';
		end
		str = ['{"type":"bool","value":"', val, '"}'];

	elseif isnumeric(obj)
		if isinteger(obj)
			str = sprintf('{"type":"integer","value":"%d"}', obj);
		elseif isnan(obj)
			str = '{"type":"float","value":"nan"}';
		else
			str = sprintf('{"type":"float","value":"%0.15f"}', obj);
		end

	else
		error("don't know what this is");
	end
end

function str = escape_str(str)
	str = strrep(str, '\', '\\');
	str = strrep(str, '"', '\"');
	str = strrep(str, '/', '\/');
	str = strrep(str, "\r", '\r');
	str = strrep(str, "\f", '\f');
	str = strrep(str, "\n", '\n');
	str = strrep(str, "\t", '\t');
	str = strrep(str, "\b", '\b');
	str = strrep(str, char(0x1f), '\u001F');
end
