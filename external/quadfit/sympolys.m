function sympolys(varargin)
% Create multiple symbolic polynomials in the caller workspace.
%
% Example:
%    sympolys a b x y      creates sympoly variables with those names in
%                          the caller workspace; this call is equivalent
%                          to 4 separate calls:
%                             a = sympoly('a')
%                             b = sympoly('b')
%                             x = sympoly('x')
%                             y = sympoly('y')
%
% See also: sympoly.sympoly

% Copyright 2009-2011 Levente Hunyadi

assert(iscellstr(varargin), ...
    'math:sympolys:ArgumentTypeMismatch', ...
    'Multiple symbolic polynomials can be created with "sympolys x y z w".');
assert(nargin > 0, ...
    'math:sympolys:ArgumentCountMismatch', ...
    'Symbolic polynomials are created with the syntax "sympolys x y z w".');

% loop over the inputs
for k = 1 : nargin  % a list of several variables to create
    inp = varargin{k};
    assignin('caller', inp, sympoly(inp));  % assign variables with this name in the caller workspace
end
