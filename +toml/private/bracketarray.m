function out = bracketarray(in)
  % BRACKETARRAY TOML representation of a MATLAB numerical array, in the style of a numpy array
  %
  %   BRACKETARRAY(array) returns the TOML/numpy-like representation of `array' with nested brackets
  %   [1, 2; 3, 4] becomes [[1,2],[3,4]]

  %   From: https://stackoverflow.com/questions/57438523/in-matlab-how-can-i-write-out-a-multidimensional-array-as-a-string-that-looks-li/57445408#57445408
  %   By: matlabbit

  out = permute(in, [2, 1, 3:ndims(in)]);
  out = string(out);

  dimsToCat = ndims(out);
  if iscolumn(out)
    dimsToCat = dimsToCat - 1;
  end

  for iDim = 1:dimsToCat
    out = "[" + join(out, ",", iDim) + "]" ;
  end
  out = char(out);
end

%% Test Suite
% disp({1, isequal(bracketarray(ones(1,1)), '[1]')})
% disp({2, isequal(bracketarray(ones(2,1)), '[[1],[1]]')})
% disp({3, isequal(bracketarray(ones(1,2)), '[1,1]')})
% disp({4, isequal(bracketarray(ones(2,2)), '[[1,1],[1,1]]')})
% disp({5, isequal(bracketarray(ones(3,2)), '[[1,1],[1,1],[1,1]]')})
% disp({6, isequal(bracketarray(ones(2,3)), '[[1,1,1],[1,1,1]]')})
% disp({7, isequal(bracketarray(ones(1,1,2)), '[[[1]],[[1]]]')})
% disp({8, isequal(bracketarray(ones(2,1,2)), '[[[1],[1]],[[1],[1]]]')})
% disp({9, isequal(bracketarray(ones(1,2,2)), '[[[1,1]],[[1,1]]]')})
% disp({10,isequal(bracketarray(ones(2,2,2)), '[[[1,1],[1,1]],[[1,1],[1,1]]]')})
% disp({11,isequal(bracketarray(ones(1,1,1,2)), '[[[[1]]],[[[1]]]]')})
% disp({12,isequal(bracketarray(ones(2,1,1,2)), '[[[[1],[1]]],[[[1],[1]]]]')})
% disp({13,isequal(bracketarray(ones(1,2,1,2)), '[[[[1,1]]],[[[1,1]]]]')})
% disp({14,isequal(bracketarray(ones(1,1,2,2)), '[[[[1]],[[1]]],[[[1]],[[1]]]]')})
% disp({15,isequal(bracketarray(ones(2,1,2,2)), '[[[[1],[1]],[[1],[1]]],[[[1],[1]],[[1],[1]]]]')})
% disp({16,isequal(bracketarray(ones(1,2,2,2)), '[[[[1,1]],[[1,1]]],[[[1,1]],[[1,1]]]]')})
% disp({17,isequal(bracketarray(ones(2,2,2,2)), '[[[[1,1],[1,1]],[[1,1],[1,1]]],[[[1,1],[1,1]],[[1,1],[1,1]]]]')})
% disp({18,isequal(bracketarray(permute(reshape([1:16],2,2,2,2),[2,1,3,4])), '[[[[1,2],[3,4]],[[5,6],[7,8]]],[[[9,10],[11,12]],[[13,14],[15,16]]]]')})
% disp({19,isequal(bracketarray(ones(1,1,1,1,2)), '[[[[[1]]]],[[[[1]]]]]')})
% 
% assert(isequal(toml.encode(struct('a', ones(1,1))), 'a = 1'), 'ones(1,1) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,1))), 'a = [[1],[1]]'), 'ones(2,1) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,2))), 'a = [1,1]'), 'ones(1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,2))), 'a = [[1,1],[1,1]]'), 'ones(2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(3,2))), 'a = [[1,1],[1,1],[1,1]]'), 'ones(3,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,3))), 'a = [[1,1,1],[1,1,1]]'), 'ones(2,3) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,1,2))), 'a = [[[1]],[[1]]]'), 'ones(1,1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,1,2))), 'a = [[[1],[1]],[[1],[1]]]'), 'ones(2,1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,2,2))), 'a = [[[1,1]],[[1,1]]]'), 'ones(1,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,2,2))), 'a = [[[1,1],[1,1]],[[1,1],[1,1]]]'), 'ones(2,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,1,1,2))), 'a = [[[[1]]],[[[1]]]]'), 'ones(1,1,1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,1,1,2))), 'a = [[[[1],[1]]],[[[1],[1]]]]'), 'ones(2,1,1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,2,1,2))), 'a = [[[[1,1]]],[[[1,1]]]]'), 'ones(1,2,1,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,1,2,2))), 'a = [[[[1]],[[1]]],[[[1]],[[1]]]]'), 'ones(1,1,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,1,2,2))), 'a = [[[[1],[1]],[[1],[1]]],[[[1],[1]],[[1],[1]]]]'), 'ones(2,1,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,2,2,2))), 'a = [[[[1,1]],[[1,1]]],[[[1,1]],[[1,1]]]]'), 'ones(1,2,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(2,2,2,2))), 'a = [[[[1,1],[1,1]],[[1,1],[1,1]]],[[[1,1],[1,1]],[[1,1],[1,1]]]]'), 'ones(2,2,2,2) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', permute(reshape([1:16],2,2,2,2),[2,1,3,4]))), 'a = [[[[1,2],[3,4]],[[5,6],[7,8]]],[[[9,10],[11,12]],[[13,14],[15,16]]]]'), 'permute(reshape([1:16],2,2,2,2),[2,1,3,4]) not encoded correctly!');
% assert(isequal(toml.encode(struct('a', ones(1,1,1,1,2))), 'a = [[[[[1]]]],[[[[1]]]]]'), 'ones(1,1,1,1,2) not encoded correctly!');
% 
% assert(isequal(toml.decode('a = 1'), struct('a', ones(1,1))), 'ones(1,1) not decoded correctly!');
% assert(isequal(toml.decode('a = [[1],[1]]'), struct('a', ones(2,1))), 'ones(2,1) not decoded correctly!');
% assert(isequal(toml.decode('a = [1,1]'), struct('a', ones(1,2))), 'ones(1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[1,1],[1,1]]'), struct('a', ones(2,2))), 'ones(2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[1,1],[1,1],[1,1]]'), struct('a', ones(3,2))), 'ones(3,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[1,1,1],[1,1,1]]'), struct('a', ones(2,3))), 'ones(2,3) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[1]],[[1]]]'), struct('a', ones(1,1,2))), 'ones(1,1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[1],[1]],[[1],[1]]]'), struct('a', ones(2,1,2))), 'ones(2,1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[1,1]],[[1,1]]]'), struct('a', ones(1,2,2))), 'ones(1,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[1,1],[1,1]],[[1,1],[1,1]]]'), struct('a', ones(2,2,2))), 'ones(2,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1]]],[[[1]]]]'), struct('a', ones(1,1,1,2))), 'ones(1,1,1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1],[1]]],[[[1],[1]]]]'), struct('a', ones(2,1,1,2))), 'ones(2,1,1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1,1]]],[[[1,1]]]]'), struct('a', ones(1,2,1,2))), 'ones(1,2,1,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1]],[[1]]],[[[1]],[[1]]]]'), struct('a', ones(1,1,2,2))), 'ones(1,1,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1],[1]],[[1],[1]]],[[[1],[1]],[[1],[1]]]]'), struct('a', ones(2,1,2,2))), 'ones(2,1,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1,1]],[[1,1]]],[[[1,1]],[[1,1]]]]'), struct('a', ones(1,2,2,2))), 'ones(1,2,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1,1],[1,1]],[[1,1],[1,1]]],[[[1,1],[1,1]],[[1,1],[1,1]]]]'), struct('a', ones(2,2,2,2))), 'ones(2,2,2,2) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[1,2],[3,4]],[[5,6],[7,8]]],[[[9,10],[11,12]],[[13,14],[15,16]]]]'), struct('a', permute(reshape([1:16],2,2,2,2),[2,1,3,4]))), 'permute(reshape([1:16],2,2,2,2),[2,1,3,4]) not decoded correctly!');
% assert(isequal(toml.decode('a = [[[[[1]]]],[[[[1]]]]]'), struct('a', ones(1,1,1,1,2))), 'ones(1,1,1,1,2) not decoded correctly!');