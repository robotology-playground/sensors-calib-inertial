function F = sphere_gd(n, radius, center)
% Construct a geodesic sphere.
%
% Input arguments:
% n:
%    the number of segments along the side of triangles to subdivide into
% radius:
%    radius of the sphere
% center:
%    center of the sphere
%
% Output arguments:
% F:
%    a 3x3xn array of (x,y,z) coordinates of 3 points of n triangles
%
% References:
% "Geodesic sphere", http://en.wikipedia.org/wiki/Geodesic_sphere

% Copyright 2011 Levente Hunyadi

if nargin < 1
    n = 6;
else
    validateattributes(n, {'numeric'}, {'positive','integer','scalar','>=',2});
end

if nargin < 2
    radius = 1;
else
    validateattributes(radius, {'numeric'}, {'positive','real','scalar'});
end

if nargin < 3
    center = zeros(3,1);
else
    validateattributes(center, {'numeric'}, {'real','vector'});
    center = center(:);
    validateattributes(center, {'numeric'}, {'size',[3,1]});
end

% icosahedron (at origin) as Platonic solid to initialize construction
tao = 1.61803399;  % Golden ratio
icosavertices = ...
	[ 1,tao,0;-1,tao,0;1,-tao,0;-1,-tao,0 ...
	; 0,1,tao;0,-1,tao;0,1,-tao;0,-1,-tao ...
	; tao,0,1;-tao,0,1;tao,0,-1;-tao,0,-1 ...
	];
icosavertices = transpose(icosavertices);
icosafaces = ...
	[ 0,1,4 ...
	; 1,9,4 ...
	; 4,9,5 ...
	; 5,9,3 ...
	; 2,3,7 ...
	; 3,2,5 ...
	; 7,10,2 ...
	; 0,8,10 ...
	; 0,4,8 ...
	; 8,2,10 ...
	; 8,4,5 ...
	; 8,5,2 ...
	; 1,0,6 ...
	; 11,1,6 ...
	; 3,9,11 ...
	; 6,10,7 ...
	; 3,11,7 ...
	; 11,6,7 ...
	; 6,0,10 ...
	; 9,1,11 ...
	];
icosafaces = transpose(icosafaces + 1);  % migrate from zero-based to one-based indexing
%trimesh(transpose(icosafaces), icosavertices(1,:), icosavertices(2,:), icosavertices(3,:)); return;

% subdivide icosahedron faces
F = zeros(3,3,size(icosafaces,2)*n*n);
for k = 1 : size(icosafaces,2);
	sf = subdivide_face(icosavertices(:,icosafaces(:,k)), n);
    F(:,:,(k-1)*n*n+1:k*n*n) = sf;
end

% project each point to the sphere
for k = 1 : size(F,2)*size(F,3)
    % get the point's magnitude
    m = norm(F(:,k));
    % make its magnitude a unit vector then scale it to the radius in one step
    F(:,k) = radius * F(:,k) / m;
end

F = bsxfun(@plus, center, F);
x = F(1,:,:);
y = F(2,:,:);
z = F(3,:,:);

if nargout < 1
    trimesh(reshape(1:numel(x),3,numel(x)/3)',x(:),y(:),z(:),zeros(size(x)));
end

function faces = subdivide_face(vertices, n)
% Subdivide a face into triangles.
%
% Input arguments:
% vertices:
%    triangle vertices, each row is a dimension x, y or z, and each column
%    is a different triangle
% n:
%    the number of segments along the side of the triangle to subdivide to
%
% Output arguments:
% faces:
%    an array of face vertex coordinates of size [3,3,n*n]
%
% See also:
% http://www.donhavey.com/blog/tutorials/tutorial-3-the-icosahedron-sphere/

[dim,count] = size(vertices);
validateattributes(vertices, {'numeric'}, {'real','nonempty','size',[3,count]});  % dimensionality must be 3
validateattributes(n, {'numeric'}, {'positive','integer','scalar','>=',2});

p1 = vertices(:,1);
p2 = vertices(:,2);
p3 = vertices(:,3);

% triangle sides
side12 = zeros(dim,n+1);
side12(:,1) = p1;
side12(:,n+1) = p2;
side13 = zeros(dim,n+1);
side13(:,1) = p1;
side13(:,n+1) = p3;

% subdivision points
for i = 2 : n
    r = (i-1)/n;
    side12(:,i) = p1 + r*(p2-p1);
    side13(:,i) = p1 + r*(p3-p1);
end

% span points
span = zeros(dim,n-1,n);
for i = 0 : n
    for j = 1 : n-i-1
        k = n-i;
        r = j/k;
        span(:,i+1,j+1) = side12(:,k+1) + r*(side13(:,k+1) - side12(:,k+1));
    end
end

faces = zeros(dim, 3, n*n);

% top four subfaces
k = 0;
k = k + 1;
faces(:,:,k) = [ side12(:,1) side13(:,2) side12(:,2) ];
k = k + 1;
faces(:,:,k) = [ side12(:,2) side12(:,3) span(:,n-1,2) ];
k = k + 1;
faces(:,:,k) = [ side12(:,2) span(:,n-1,2) side13(:,2) ];
k = k + 1;
faces(:,:,k) = [ side13(:,2) side13(:,3) span(:,n-1,2) ];

% rest of the subfaces
for i = 3 : n
    k = k + 1;
    faces(:,:,k) = [ side12(:,i) side12(:,i+1) span(:,n-i+1,2) ];
    k = k + 1;
    faces(:,:,k) = [ side12(:,i) span(:,n-i+2,2) span(:,n-i+1,2) ];

    for j = 2 : n-i+2
        k = k + 1;
        faces(:,:,k) = [ span(:,i-2,j+1) span(:,i-2,j) span(:,i-1,j) ];
        if i > 3
            k = k + 1;
            faces(:,:,k) = [ span(:,i-2,j+1) span(:,i-2,j) span(:,i-3,j+1) ];
        end
    end
    k = k + 1;
    faces(:,:,k) = [ side13(:,i) side13(:,i+1) span(:,n-i+1,i) ];
    k = k + 1;
    faces(:,:,k) = [ side13(:,i) span(:,n-i+2,i-1) span(:,n-i+1,i) ];
end

if nargout < 1  % plot the subdivided mesh if there are no output arguments
    hold on;
    p = side12(:);
    plot3(p(1:3:end),p(2:3:end),p(3:3:end),'ro');
    p = side13(:);
    plot3(p(1:3:end),p(2:3:end),p(3:3:end),'bo');
    x = faces(1,:,:);
    y = faces(2,:,:);
    z = faces(3,:,:);
    trimesh(reshape(1:3*n*n,3,n*n)',x(:),y(:),z(:));
    hold off;
end

function triangles = convert_triangles(faces, vertices) %#ok<DEFNU>
% Convert representation of face index and vertices to triangle vertices.

[dim,count] = size(faces);
validateattributes(faces, {'numeric'}, {'positive','integer','size',[3,count]});  % a face must consist of three points
validateattributes(vertices, {'numeric'}, {'real','size',[3,size(vertices,2)]});  % dimensionality must be 3

triangles = zeros(dim, 3, count);
for k = 1 : count
	t = vertices(:,faces(:,k));
    triangles(:,:,k) = t;
end
