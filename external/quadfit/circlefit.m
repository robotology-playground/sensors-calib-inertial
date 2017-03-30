function [center,radius,residuals] = circlefit(x,y)
% Fit a circle to data using the least squares approach.
%
% Fits the equation of a circle in Cartesian coordinates to a set of xy
% data points by solving the overdetermined system of normal equations, i.e.
% x^2 + y^2 + a*x + b*y + d = 0
%
% Input arguments:
% x,y
%    Cartesian coordinates of noisy data points
%
% Output arguments:
% center:
%    coordinates of the least-squares fit circle center
% radius:
%    least-squares fit cirlce radius
% residuals:
%    residuals in the radial direction
%
% Examples:
% [center,radius,residuals] = circlefit(X)
% [center,radius,residuals] = circlefit(x,y,z);

% Copyright 2010 Levente Hunyadi

narginchk(1,2);
switch nargin  % n x 2 matrix
    case 1
        n = size(x,1);
        validateattributes(x, {'numeric'}, {'2d','real','size',[n,2]});
        y = x(:,2);
        x = x(:,1);
    otherwise  % two x,y vectors
        validateattributes(x, {'numeric'}, {'real','vector'});
        validateattributes(y, {'numeric'}, {'real','vector'});
        n = numel(x);
        x = x(:);  % force into columns
        y = y(:);
        validateattributes(x, {'numeric'}, {'size',[n,1]});
        validateattributes(y, {'numeric'}, {'size',[n,1]});
end

% solve linear system of normal equations
A = [x, y, ones(size(x))];
b = -(x.^2 + y.^2);
a = A \ b;

% return center coordinates and sphere radius
center = -a(1:2)./2;
radius = realsqrt(sum(center.^2)-a(3));

if nargout > 2
	% calculate residuals
   residuals = radius - sqrt(sum(bsxfun(@minus,[x y],center.').^2,2));
end
