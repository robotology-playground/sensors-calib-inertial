function [x,y,nx,ny] = ellipse(N, cx, cy, a, b, phi)
% Generates points along an ellipse.
%
% Input arguments:
% N:
%    number of points to generate
% cx, cy:
%    coordinates of the center of the ellipse
% a:
%    semi-major axis length
% b:
%    semi-minor axis length
% phi:
%    rotation of the aligned ellipse w.r.t. x-axis
%
% Output arguments:
% x,y:
%    points of the ellipse
% nx,ny:
%    ellipse normal vector target coordinates at points x,y

% Copyright 2008-2009 Levente Hunyadi

if nargin < 2
    cx = 0;
else
    validateattributes(cx, {'numeric'}, {'real','scalar'});
end
if nargin < 3
    cy = 0;
else
    validateattributes(cy, {'numeric'}, {'real','scalar'});
end
if nargin < 4
    a = 1;
else
    validateattributes(a, {'numeric'}, {'positive','real','scalar'});
end
if nargin < 5
    b = 1;
else
    validateattributes(b, {'numeric'}, {'positive','real','scalar'});
end
if nargin < 6
    phi = 0;
else
    validateattributes(phi, {'numeric'}, {'real','scalar'});
end

% X(t) = X_c + a cos(t) cos(phi) - b sin(t) sin(phi)
% Y(t) = Y_c + a cos(t) sin(phi) + b sin(t) cos(phi)

% create aligned ellipse
if nargout > 2
    [ax,ay,anx,any] = aligned_ellipse(N, a, b);
else
    [ax,ay] = aligned_ellipse(N, a, b);
end

% rotate
rx = ax*cos(-phi) + ay*sin(-phi);
ry = ay*cos(-phi) - ax*sin(-phi);
if nargout > 2
    nx = anx*cos(-phi) + any*sin(-phi);
    ny = any*cos(-phi) - anx*sin(-phi);
end

% translate
x = rx + cx;
y = ry + cy;

% plot
if nargout < 2
    plot(x, y, '.');
end

function [x,y,nx,ny] = aligned_ellipse(N, a, b)

if nargin < 2
    a = 1;
end
if nargin < 3
    b = 1;
end

t = 2*pi * rand(N,1);
x = a*cos(t);
y = b*sin(t);
if nargout > 2
    % tx = -a*sin(t);
    % ty = b*cos(t);
    % nx = tx*cos(phi) + ty*sin(phi) where phi = pi/2
    % ny = ty*cos(phi) + tx*sin(phi) where phi = pi/2
    nx = b*cos(t);
    ny = a*sin(t);
    n = sqrt(nx.^2 + ny.^2);
    nx = nx ./ n;
    ny = ny ./ n;
end