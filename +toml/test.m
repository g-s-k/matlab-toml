% import testing framework
import matlab.unittest.*

% create test suite from subpackage
suite = TestSuite.fromPackage('toml.testing');

% run the tests
result = suite.run();

% make them into a table
rt = table(result);

% show the results
disp(rt)
