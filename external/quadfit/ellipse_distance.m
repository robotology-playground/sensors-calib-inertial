function [e,d,xf,yf] = ellipse_distance(x, y, p)
% Distance of points projected onto an ellipse.
%
% Input arguments:
% x, y:
%    co-ordinates of data points whose distance from the ellipse to measure
% p:
%    parameters of the ellipse expressed in implicit form

% Copyright 2011 Levente Hunyadi

validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);

[cx cy a b theta] = ellipse_im2ex(p);
[xfyf,rss] = quad2dproj([x y], [cx cy], [a b], theta);
e = rss / numel(x);

% get foot points
xf = xfyf(:,1);
yf = xfyf(:,2);

% calculate distance from foot points
d = sqrt((x-xf).^2 + (y-yf).^2);

% use ellipse equation P = 0 to determine if point inside ellipse (P < 0)
f = b^2.*((x-cx).*cos(theta)-(y-cy).*sin(theta)).^2 + a^2.*((x-cx).*sin(theta)+(y-cy).*cos(theta)).^2 - a^2.*b^2 < 0;

% convert to signed distance, d < 0 inside ellipse
d(f) = -d(f);
