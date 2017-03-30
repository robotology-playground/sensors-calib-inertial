function p = quad3dfit_taubin(x,y,z)
% General quadric surface fit with Taubin's method.
%
% Input arguments:
% x,y,z;
%    x, y, and z coodinates of 3D points
%
% Output arguments:
% p:
%    a 10-parameter vector of the algebraic quadric fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% G. Taubin, "Estimation of Planar Curves, Surfaces and Nonplanar Space Curves Defined
%    by Implicit Equations, with Applications to Edge and Range Image Segmentation",
%    IEEE Trans. PAMI, Vol. 13, 1991, pp1115-1138.

% Copyright 2011 Levente Hunyadi

narginchk(3,3);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
z = z(:);

% auxiliary variables
l = ones(numel(x),1);
o = zeros(numel(x),1);

% data
X = [ x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, l ];

% gradients
dx = [2*x, o, o, y, z, o, l, o, o, o];
dy = [o, 2*y, o, x, o, z, o, l, o, o];
dz = [o, o, 2*z, o, x, y, o, o, l, o];
dX = [dx; dy; dz];

% scatter matrices
A = X'*X;
B = dX'*dX;

[V,D] = eig(A,B);
[~,ix] = min(abs(diag(D)));
p = V(:,ix);