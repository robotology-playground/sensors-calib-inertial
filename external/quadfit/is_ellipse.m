function tf = is_ellipse(p)
% Test if implicit parameters represent an ellipse.

% Copyright 2011 Levente Hunyadi

a = p(1);
b = 0.5*p(2);
c = p(3);
d = 0.5*p(4);
f = 0.5*p(5);
g = p(6);

I = a + c;
J = a*c - b^2;
Delta = det( [a b d ; b c f ; d f g] );

tf = J > 0 && Delta/I < 0;