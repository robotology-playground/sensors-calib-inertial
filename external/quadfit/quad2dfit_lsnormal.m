function p = quad2dfit_lsnormal(x,y,nx,ny)
% Fit a quadratic curve to a set of 2D data points with normals.
%
% Input arguments:
% x, y:
%    cartesian coordinates of noisy data points
% nx, ny:
%    cartesian coordinates of normals
%
% Output arguments:
% p:
%    the 6 parameters describing the ellipse algebraically
%

% Copyright 2011 Levente Hunyadi

narginchk(4, 4);  % check input arguments
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(nx, {'numeric'}, {'real','nonempty','vector'});
validateattributes(ny, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
nx = nx(:);
ny = ny(:);

assert(numel(x) >= 5, ...
    'At least 5 points are required to fit a unique ellipse.');

o = zeros(size(x));
h = ones(size(x));

% data points
X = [ x.^2, x.*y, y.^2, x, y, h ];

% normals
dXdx = [ 2.*x, y, o, h, o, o ];
dXdy = [ o, x, 2.*y, o, h, o ];
dX = [ dXdx ; dXdy ];

% system of equations
A = [ X ; dX ];
b = [ o ; nx ; ny ];
p = A \ b;  % Moore-Penrose pseudoinverse