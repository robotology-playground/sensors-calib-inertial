function ellipsoidsym
% Symbolic expression of ellipsoid in implicit form with center, axes and quaternions.

% Copyright 2011 Levente Hunyadi

x = sym('x', 'real');
y = sym('y', 'real');
z = sym('z', 'real');

cx = sym('cx', 'real');
cy = sym('cy', 'real');
cz = sym('cz', 'real');

a = sym('a', 'positive');
b = sym('b', 'positive');
c = sym('c', 'positive');

qx = sym('qx', 'real');
qy = sym('qy', 'real');
qz = sym('qz', 'real');
qw = sym('qw', 'real');

S = diag([a,b,c,1]);
R = ...
[ - qy^2 - qz^2 + 1,     qx*qy - qw*qz,     qw*qy + qx*qz ...
;     qw*qz + qx*qy, - qx^2 - qz^2 + 1,     qy*qz - qw*qx ...
;     qx*qz - qw*qy,     qw*qx + qy*qz, - qx^2 - qy^2 + 1 ];
R(4,4) = 1;
T = sym(eye(4,4));
T(4,1:3) = [cx, cy, cz];

Q = T * R * S * R' * T';
f = [x y z 1]*Q*[x;y;z;1];
diff(f, a)