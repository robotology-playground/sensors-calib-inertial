function [p,r] = quad2dfit_leastsquares(x,y)
% Fit a quadratic curve to a set of 2D data points using least-squares.
%
% Input arguments:
% x, y:
%    cartesian coordinates of noisy data points
%
% Output arguments:
% p:
%    the 6 parameters describing the ellipse algebraically
%

% Copyright 2011 Levente Hunyadi

narginchk(2, 2);  % check input arguments
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);

assert(numel(x) >= 5, ...
    'At least 5 points are required to fit a unique ellipse.');

% use singular value decomposition (unconstrained problem)
D = [ x .^ 2, ...  % size = (number of data points) x (5 ellipsoid parameters + 1 constant term)
      x .* y, ...
      y .^ 2, ...
      x, ...
      y, ... 
      ones(size(x)) ];
[~,S,V] = svd(D,0);
p = V(:,end);  % smallest singular vector
r = S(end,end);  % smallest singular value