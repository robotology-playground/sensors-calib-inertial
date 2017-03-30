function plot_ellipsoid_part(cx,cy,cz,ap,bp,cp,R,x,y,z,varargin)
% Plot ellipsoid specified with center, radii and rotation matrix.
%
% Input arguments:
% cx,cy,cz;
%    x, y and z coodinate of ellipsoid center
% ap,bp,cp;
%    ellipsoid radii
% R:
%    rotation matrix
% varargin:
%    additional parameters as name-value pairs:
%    * EdgeColor: color
%    * AxesColor ['none'|color]

% Copyright 2011 Levente Hunyadi

% generate surface mesh for sphere
F = sphere_gd(6,1);
X = reshape(F, 3, numel(F)/3);

% scale surface mesh
X = diag([ap,bp,cp])*X;

% rotate surface mesh
X = R'*X;

% add center offset
X = bsxfun(@plus, X, [cx;cy;cz]);

% find nearest neighbor face vertices on sphere surface
F = reshape(X, 3, 3, size(F,3));
nn = 12;
f = nntrifaces(F, nn, x, y, z);

% drop unused triangles
vertices = reshape(1:3*size(F,3),3,size(F,3));  % 3xn matrix of face indices
vertices = vertices(:,f);

% draw surface
set(gcf,'NextPlot','add');
set(gca,'NextPlot','add');
trisurf(transpose(vertices),X(1,:),X(2,:),X(3,:),zeros(1,size(X,2)), ...
    'BackFaceLighting', 'unlit');