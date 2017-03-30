function [x, y] = ellipse_orbital(N, e, p, cx, cy, phi)
% Generates points along an ellipse using Kepler's parameters.
%
% Input arguments:
% N:
%    number of points to generate
% e:
%    eccentricity of the ellipse
% p:
%    semi-latus rectum of the ellipse.
% cx, cy:
%    coordinates of the center of the ellipse
% phi:
%    rotation of the aligned ellipse w.r.t. x-axis

% Copyright 2008-2009 Levente Hunyadi

if nargin < 2  % eccentricity of ellipse
    e = 0;
else
    validateattributes(e, {'numeric'}, {'nonnegative','real','scalar'});
end
if nargin < 3  % semi-latus rectum
    p = 1;
else
    validateattributes(p, {'numeric'}, {'nonnegative','real','scalar'});
end
if nargin < 4
    cx = 0;
else
    validateattributes(cx, {'numeric'}, {'real','scalar'});
end
if nargin < 5
    cy = 0;
else
    validateattributes(cy, {'numeric'}, {'real','scalar'});
end
if nargin < 6
    phi = 0;
else
    validateattributes(phi, {'numeric'}, {'real','scalar'});
end

% X(t) = X_c + a cos(t) cos(phi) - b sin(t) sin(phi)
% Y(t) = Y_c + a cos(t) sin(phi) + b sin(t) cos(phi)
[ax, ay] = aligned_ellipse(N, e, p);
rx = ax*cos(phi) + ay*sin(phi);
ry = ay*cos(phi) - ax*sin(phi);
x = rx + cx;
y = ry + cy;
if nargout < 2
    plot(x, y, '.');
end

function [rx, ry] = aligned_ellipse(N, e, p)

if nargin < 2  % eccentricity of ellipse
    e = 0;
end
if nargin < 3  % semi-latus rectum
    p = 1;
end

theta = 2*pi * rand(N,1);
r = p ./ (1 + e .* cos(theta));
ry = r .* sin(theta);
rx = r .* cos(theta);