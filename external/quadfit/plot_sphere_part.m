function plot_sphere_part(n, radius, center, x, y, z)
% Partial sphere surface.

% Copyright 2011 Levente Hunyadi

validateattributes(n, {'numeric'}, {'positive','integer','scalar','>=',2});
validateattributes(radius, {'numeric'}, {'positive','real','scalar'});
validateattributes(center, {'numeric'}, {'real','vector'});
center = center(:);
validateattributes(center, {'numeric'}, {'size',[3,1]});

validateattributes(x, {'numeric'}, {'real','vector'});
validateattributes(y, {'numeric'}, {'real','vector'});
validateattributes(z, {'numeric'}, {'real','vector'});

% number of nearest-neighbor triangle vertices
nn = 8;

% get triangle face vertices of sphere surface
F = sphere_gd(n, radius, center);

% find nearest neighbor face vertices on sphere surface
f = nntrifaces(F, nn, x, y, z);

% drop unused triangles
vertices = reshape(1:3*size(F,3),3,size(F,3));  % 3xn matrix of face indices
vertices = vertices(:,f);

if nargout < 1
	% draw partial surface
    x0 = F(1,:,:);
    y0 = F(2,:,:);
    z0 = F(3,:,:);
    trisurf(transpose(vertices),x0(:),y0(:),z0(:),zeros(size(x0)));
end