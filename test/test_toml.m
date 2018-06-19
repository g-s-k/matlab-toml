%% setup
parentDir = fileparts(pwd);

if ispc()
  cmp = @strcmpi;
else
  cmp = @strcmp;
end

parentIsOnPath = any(cmp(parentDir, strsplit(path, pathsep)));

if ~parentIsOnPath
  addpath(parentDir);
end

%% run the tests
import matlab.unittest.*

suite = TestSuite.fromClass(?TestToml);

result = suite.run();

rt = table(result);

disp(rt)

%% teardown
if ~parentIsOnPath
  rmpath(parentDir);
end