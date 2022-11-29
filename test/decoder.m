addpath("+toml/private");

function str = jsonify(obj)
	if isstruct(obj)
		keys = fieldnames(obj);
		print_key_value = @(k) sprintf('"%s":%s', k, jsonify(obj.(k)));
		keys_and_values = cellfun(print_key_value, keys, 'uniformoutput', false);
		str = ['{', strjoin(keys_and_values, ','), '}'];

	elseif iscell(obj)
		values = cellfun(@jsonify, obj, 'uniformoutput', false);
		str = ['[', strjoin(values, ','), ']'];

	elseif ischar(obj)
		str = ['{"type":"string","value":"', strrep(obj, '"', '\"'), '"}'];

	elseif numel(obj) != 1 && ndims(obj) == 2 && size(obj, 1) == 1
		values = arrayfun(@jsonify, obj, 'uniformoutput', false);
		str = ['[', strjoin(values, ','), ']'];

	elseif numel(obj) != 1
	    cel = cell(1, size(obj, 1));
	    indices = repmat({':'}, 1, ndims(obj));
	    for row = 1:size(obj, 1)
			indices{1} = row;
			cel{row} = jsonify(squeeze(obj(indices{:})));
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
		if obj == round(obj)
			tag = 'integer';
		else
			tag = 'float';
		end
		str = sprintf('{"type":"%s","value":"%d"}', tag, obj);

	else
		error("don't know what this is");
	end
end

data = char(fread(0)).';
decoded = toml.decode(data);
printf("%s\n", jsonify(decoded));
