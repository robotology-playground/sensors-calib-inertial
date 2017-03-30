function tf = is_ellipsoid(p)
% Test if implicit parameters represent an ellipsoid.

% Copyright 2011 Levente Hunyadi

% ellipsoid equation:
% a*x^2 + b*y^2 + c*z^2 + 2*f*y*z 2*g*x*z 2*h*x*y + 2*p*x + 2*q*y + 2*r*z + d = 0
% syms a b c f g h

a = p(1);
b = p(2);
c = p(3);
f = 0.5*p(6);
g = 0.5*p(5);
h = 0.5*p(4);

I = a + b + c;
J = a*b + b*c + a*c - f^2 - g^2 - h^2;
K = det( [a h g ; h b f ; g f c] );

tf = J > 0 && I*K > 0;