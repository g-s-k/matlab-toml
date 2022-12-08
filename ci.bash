#!/bin/bash

MATLAB=${1:-octave-cli --eval}

IN_FILE='./.input.toml'
OUT_FILE='./.output.toml'

cat > $IN_FILE

$MATLAB \
	"addpath('.');if exist('OCTAVE_VERSION', 'builtin') > 0;addpath('./+toml/private');end;in=fopen('$IN_FILE','rt');data=char(fread(in)).';decoded=toml.decode(data);out=fopen('$OUT_FILE','wt');fprintf(out,'%s\n',toml.testing.jsonify(decoded));" > /dev/null
	
cat $OUT_FILE