function [x,y,z] = quad3d_center(u)
% Center of a central quadric (quadratic surface).
% When reducing the surface to its canonical form, a translation of the coordinate
% system as given by the coordinates of the center must be made.
%
% 0 = f(x,y,z) = a*x^2 + b*y^2 + c*z^2
%              + 2*f*y*z + 2*g*x*z + 2*h*x*y
%              + 2*p*x + 2*q*y + 2*r*z + d
%
% A center of a quadric surface is a point P with the property that any line through P
% * determines a chord of the surface whose midpoint is P, or
% * has no point in common with the surface, or
% * lies entirely in the surface.
%
% Input arguments:
% u:
%    parameters of quadric as [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, 1]
%
% Output arguments:
% x, y, z:
%    coordinates of center

% Copyright 2012 Levente Hunyadi

a = u(1);
b = u(2);
c = u(3);
h = 0.5*u(4);
g = 0.5*u(5);
f = 0.5*u(6);
p = 0.5*u(7);
q = 0.5*u(8);
r = 0.5*u(9);
% d = u(10);  % parameter not used

% E = ...
%   [ a, h, g, p ...
%   ; h, b, f, q ...
%   ; g, f, c, r ...
%   ; p, q, r, d ...
%   ];

P = ...  % minor of E belonging to p
    [ h, g, p ...
    ; b, f, q ...
    ; f, c, r ...
    ];

Q = ...  % minor of E belonging to q
    [ a, g, p ...
    ; h, f, q ...
    ; g, c, r ...
    ];

R = ...  % minor of E belonging to r
    [ a, h, p ...
    ; h, b, q ...
    ; g, f, r ...
    ];

D = ...  % minor of E belonging to d
    [ a, h, g ...
    ; h, b, f ...
    ; g, f, c ...
    ];

d = det(D);
x = -det(P) / d;
y =  det(Q) / d;
z = -det(R) / d;
