function plotconvhull(x,y,z)
% Plot convex hull of a set of data points.

% Copyright 2011 Levente Hunyadi

[x,y,z] = convhull2d(x,y,z);
patch(x,y,z,'g');
%patch(x,y,z,'g', 'FaceAlpha', 0.25);  % alpha forces saving figure as pixel graphics

function [xh,yh,zh] = convhull2d(x,y,z)

X = [x(:),y(:),z(:)];

% find dimension with the maximum projected area
maxA = 0;
maxdim = 0;
for k = 1 : size(X,2)
    dix = 1 : size(X,2);  % e.g. [1,2,3]
    dix(k) = [];  % project component, e.g. [1,3]
    A = (max(X(:,dix(1)))-min(X(:,dix(1)))) * (max(X(:,dix(2)))-min(X(:,dix(2))));  % spanned area of projection
    if A > maxA
        maxA = A;
        maxdim = k;
    end
end

% find convex hull of projection
dix = 1 : size(X,2);  % dimension index
dix(maxdim) = [];
vix = convhull(X(:,dix(1)),X(:,dix(2)));  % convex hull vertex indices

% return "support" vertices
xh = x(vix);
yh = y(vix);
zh = z(vix);