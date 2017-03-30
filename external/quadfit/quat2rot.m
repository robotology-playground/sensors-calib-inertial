function A = quat2rot(q)
% Convert quaternion to rotation matrix.
%
% Input arguments:
% q:
%    the rotation as a quaternion where the last entry is the "scalar term"
%
% Output arguments:
% R:
%    a rotation matrix (i.e. an orthogonal matrix with determinant 1)

% Copyright 2011 Levente Hunyadi

validateattributes(q, {'numeric'}, {'real','vector'});
q = q(:);
validateattributes(q, {'numeric'}, {'size',[4,1]});

x = q(1);
y = q(2);
z = q(3);
w = q(4);

Nq = w^2 + x^2 + y^2 + z^2;
if Nq > 0.0
    s = 2/Nq;
else
    s = 0.0;
end
X = x*s;  Y = y*s;  Z = z*s;
wX = w*X; wY = w*Y; wZ = w*Z;
xX = x*X; xY = x*Y; xZ = x*Z;
yY = y*Y; yZ = y*Z; zZ = z*Z;
A = ...
    [ 1.0-(yY+zZ),       xY-wZ,       xZ+wY ...
    ;       xY+wZ, 1.0-(xX+zZ),       yZ-wX ...
    ;       xZ-wY,       yZ+wX, 1.0-(xX+yY) ];

% syms qx qy qz qw
% A =
% [ - qy^2 - qz^2 + 1,     qx*qy - qw*qz,     qw*qy + qx*qz]
% [     qw*qz + qx*qy, - qx^2 - qz^2 + 1,     qy*qz - qw*qx]
% [     qx*qz - qw*qy,     qw*qx + qy*qz, - qx^2 - qy^2 + 1]