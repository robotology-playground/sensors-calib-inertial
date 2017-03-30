function A = ang2rot(phi, theta, psi)
% Convert Euler angles to rotation matrix.
% Euler angles use the x-convention, i.e. phi, theta and psi are taken around the Z, X
% and again the Z-axis.
%
% See also: rot2ang

% Copyright 2011 Levente Hunyadi

if nargin > 1
    narginchk(3, 3);
    a = phi;
    b = theta;
    c = psi;
else
    narginchk(1, 1);
    a = phi(1);
    b = phi(2);
    c = phi(3);
end

ca = cos(a); sa = sin(a);
cb = cos(b); sb = sin(b);
cc = cos(c); sc = sin(c);

A_x = ...
    [ 1,  0,   0 ...
    ; 0, ca, -sa ...
    ; 0, sa,  ca ];
A_y = ...
    [ cb,  0, sb ...
    ; 0,   1,  0 ...
    ; -sb, 0, cb ];
A_z = ...
    [ cc, -sc, 0 ...
    ; sc,  cc, 0 ...
    ; 0,    0, 1 ];
A = A_x * A_y * A_z;