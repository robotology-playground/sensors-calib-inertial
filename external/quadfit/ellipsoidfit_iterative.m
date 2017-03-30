function p = ellipsoidfit_iterative(fitfunc, R, k)
% Iterative least squares fitting of ellipsoids under the constraint k*J - I^2 > 0.
%
% This is a utility function and is not meant to be used directly.
%
% Input arguments:
% fitfunc:
%    the handle of the function that fits data
% R:
%    a full, reduced or noise-compensated data covariance matrix
% k:
%    the initial value of k in k*J - I^2 > 0
%
% Output arguments:
% p:
%    a 10-parameter vector of the algebraic ellipsoid fit
%
% See also: ellipsoidfit_simple, ellipsoidfit_koopmans
%
% References:
% Qingde Li and John G. Griffiths, "Least Squares Ellipsoid Specific Fitting",
%    Proceedings of the Geometric Modeling and Processing, 2004.

% Copyright 2013 Levente Hunyadi

validateattributes(fitfunc, {'function_handle'}, {'scalar'});
validateattributes(R, {'numeric'}, {'2d','nonempty'});

narginchk(2,3);
if nargin > 2
    % sufficient condition for the parameter vector to define an ellipse is k = 4
    validateattributes({'numeric'}, {'integer','scalar','>=',4});
else
    % a large initial value
    k = 1024*1024;
end

p = fitfunc(R, k);
if ~is_ellipsoid(p)
    % binary search for a k that produces an ellipsoid
    k = k / 2;
    while k >= 3 && ~is_ellipsoid(p)
        p = fitfunc(R, k);
        k = k / 2;
    end

    % bisection algorithm for minimum k that produces an ellipsoid
    tol = 1e-3;
    a = max(3,k);
    b = 2 * k;
    while abs(a - b) > tol
        k = (a + b) / 2;
        p = fitfunc(R, k);
        if is_ellipsoid(p)
            a = k;
        else
            b = k;
        end
    end
    p = fitfunc(R, a);
end
