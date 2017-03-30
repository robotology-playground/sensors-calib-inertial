function [center,radius,residuals] = spherefit(x,y,z)
% Fit a sphere to data using the least squares approach.
%
% Fits the equation of a sphere in Cartesian coordinates to a set of xyz
% data points by solving the overdetermined system of normal equations, i.e.
% x^2 + y^2 + z^2 + a*x + b*y + c*z + d = 0
% The least squares sphere has radius R = sqrt((a^2+b^2+c^2)/4-d) and
% center coordinates (x,y,z) = (-a/2,-b/2,-c/2).
%
% Input arguments:
% x,y,z:
%    Cartesian coordinates of noisy data points
%
% Output arguments:
% center:
%    coordinates of the least-squares fit sphere center
% radius:
%    least-squares fit sphere radius
% residuals:
%    residuals in the radial direction
%
% Examples:
% [center,radius,residuals] = shperefit(X)
% [center,radius,residuals] = spherefit(x,y,z);

% Copyright 2010 Levente Hunyadi

narginchk(1,3);
n = size(x,1);
switch nargin  % n x 3 matrix
    case 1
        validateattributes(x, {'numeric'}, {'2d','real','size',[n,3]});
        z = x(:,3);
        y = x(:,2);
        x = x(:,1);
    otherwise  % three x,y,z vectors
        validateattributes(x, {'numeric'}, {'real','vector'});
        validateattributes(y, {'numeric'}, {'real','vector'});
        validateattributes(z, {'numeric'}, {'real','vector'});
        x = x(:);  % force into columns
        y = y(:);
        z = z(:);
        validateattributes(x, {'numeric'}, {'size',[n,1]});
        validateattributes(y, {'numeric'}, {'size',[n,1]});
        validateattributes(z, {'numeric'}, {'size',[n,1]});
end

% need four or more data points
if n < 4
   error('spherefit:InsufficientData', ...
       'At least four points are required to fit a unique sphere.');
end

% solve linear system of normal equations
A = [x, y, z, ones(size(x))];
b = -(x.^2 + y.^2 + z.^2);
a = A \ b;

% return center coordinates and sphere radius
center = -a(1:3)./2;
radius = realsqrt(sum(center.^2)-a(4));

if nargout > 2
	% calculate residuals
   residuals = radius - sqrt(sum(bsxfun(@minus,[x y z],center.').^2,2));
elseif nargout > 1
	% skip
else
    % plot sphere
    hold all;
	sphere_gd(6,radius,center);
    hold off;
end
