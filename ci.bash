#!/bin/bash

MATLAB=${1:-octave-cli --eval}

IN_FILE='./.input.toml'
OUT_FILE='./.output.toml'

cat > $IN_FILE

$MATLAB \
	"addpath('.');if exist('OCTAVE_VERSION', 'builtin') > 0;addpath('./+toml/private');end;decoded=toml.read('$IN_FILE');out=fopen('$OUT_FILE','wt');fprintf(out,'%s\n',toml.testing.jsonify(decoded));" > /dev/null
	
cat $OUT_FILE