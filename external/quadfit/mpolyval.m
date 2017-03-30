function M = mpolyval(T, s)
% Evaluates a matrix polynomial T(s) at the specified value of s.
% The matrix polynomial is represented as a set of polynomial coefficient
% terms
% T_0 + s T_1 + s^2 T_2 + s^3 T_3 + ... + s^n T_n
% where s is a scalar free parameter.
% The representation may be a 3-dimensional array whose last dimension
% indexes in increasing power of s, or a cell array of matrices, where
% again the cell index increases with the power of s.
% The function returns a matrix that is no longer a function of s.
%
% Input arguments:
% T:
%    the matrix coefficients of the matrix polynomial
% s:
%    the independent variable in the matrix polynomial
%
% Output arguments:
% M:
%    the resultant matrix after the substitution of s into T
%
% See also: polyval, polyvalm

% Copyright 2008-2009 Levente Hunyadi

validateattributes(T, {'numeric','cell'}, {'nonempty'});
validateattributes(s, {'numeric'}, {'scalar'});

if iscell(T)
    M = T{1};
    f = s;
    for i = 2 : numel(T)
        M = M + f * T{i};
        f = f * s;
    end
else
    assert(ndims(T) <= 3, ...
        'math:mpolyval:ArgumentDimensionMismatch', ...
        'Expected: a 3-dimensional array with last dimension being the power of s.');
    n = size(T,3);
    f = [ 1 cumprod( repmat(s, 1, n-1) ) ];
    M = sum(bsxfun(@times, T, reshape(f, [1,1,n])), 3);
end
