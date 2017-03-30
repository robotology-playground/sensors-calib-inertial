function test_sympoly
% Test suite for symbolic polynomial manipulation.
%
% More complex examples are by John D'Errico.
%
% References:
% John D'Errico, "Symbolic Polynomial Manipulation", MatLab Central File
%    Exchange, http://www.mathworks.com/matlabcentral/fileexchange/9577

% Copyright 2009-2011 Levente Hunyadi

%
% Creating sympoly objects
%

% zero sympoly
x = sympoly;
% constant sympoly
x = sympoly(2);
% constant matrix sympoly
x = sympoly(magic(3));
% single-variable sympoly
x = sympoly('x');
% multiple sympoly objects with a single command in the caller context
sympolys y z;
if exist('sym', 'file')  % Symbolic Toolbox is installed
    % scalar sym --> scalar sympoly
    x = sympoly(4*sym('x')^2 + sym('y'));
    % array sym --> array sympoly
    x = sympoly([4*sym('x')^2, sym('y')]);
    % sym with fractional negative exponent
    x = sympoly(4*sym('x')^-0.5);
end

%
% Addition
%

x = sympoly('x');
assert(issinglevariable(x));
% linear sympoly
x1 = x + 1;
assert(~issinglevariable(x1));
x2 = x - 2;
% multinomial
e = x + y + z;
assert(e - x - y - z == 0);
% unary plus
assert((+x) + (+y) == x + y);
% unary minus
assert((-x) + (+y) == y - x);

%
% Multiplication
%

assert(2*sympoly(3) == 6);
e = 2*x;
e = x*2;
e = x*x;
e = x*y;
e = x1*y;
e = x1*x1;
e = x1*x2;

%
% Power
%

assert(sympoly(2)^5 == 32);
assert(sympoly(2)^-5 == 1/32);
assert(x^2 == x*x);
assert(y*x^2 == x*x*y);
assert((x+y)^2 == x^2 + y^2 + 2*x*y);
assert(all(all(sympoly(eye(3,3)^5) == eye(3,3))));
assert(all(all(sympoly(eye(3,3)^-5) == eye(3,3))));

%
% Linear combination
%

% a polynomial with coefficients and exponents
assert(x + 2*y + 3*z == z*3 + x + y*2);
assert((x+y+2)*(y+1) == x*y+x+y^2+3*y+2);

%
% Equality and inequality
%

assert(sympoly(2) == 2);
assert(x == x);
assert(x ~= x + 1);
assert(x + 1 ~= x + 2);
assert(x + y ~= x + 1);
assert(x + y ~= x + y^2);
assert(x^2 + y ~= x + y^2);

%
% Vector sum and product
%

assert(sum([x y z 1]) == x + y + z + 1);
assert(sum([x;y;z;1]) == x + y + z + 1);
assert(prod([x y z 1]) == x*y*z);
assert(prod([x;y;z;1]) == x*y*z);
assert(all(sum([x+1,0;y-1,z]) == [x+y,z]));
assert(all(sum([x+1,0;y-1,z], 2) == [x+1;y+z-1]));

%
% Division
%

assert(x ./ 2 == 0.5*x);
assert(x ./ x == 1);
assert(1 ./ x == x^-1);
assert(x^2 ./ x == x);
assert(x^-2 ./ x == x^-3);
assert(y ./ x == x^-1*y);
assert((x+y) ./ x == 1 + x^-1*y);

%
% Differentiation and integration
%

assert(diff(x) == 1);
assert(diff(y) == 1);
assert(diff(2*x+1) == 2);
assert(diff(sympoly(2), 'x') == 0);
assert(diff(x^3) == 3*x^2);
assert(diff(x^3 + y^2, 'x') == 3*x^2);
assert(diff(x^3 + x^2*y^2, 'x') == 3*x^2 + 2*x*y^2);
assert(diff(int(x)) == x);
assert(int(2*x) == x^2);
assert(int(2*x, 0, 2) == 4);
assert(int(2*x, -2, 2) == 0);
assert(defint(175/16*x^7 - 255/16*x^5 + 105/16*x^3 - 9/16*x, [-1,1]) == 0);

%
% Coefficients and conversions
%

% extract coefficients of a scalar
[c,t] = coeffs(x^3+y^2+z+1, x);
assert(all(c == [ y^2 + z + 1  1 ]));
assert(all(t == [ 1  x^3 ]));
% extract coefficients of a scalar
e = (x+y+2)*(y+1);
[c,t] = coeffs(e, 'x');
assert(all(c == [ y^2+3*y+2, y+1 ]));
assert(all(t == [ 1, x ]));
assert(sum(c.*t) == e);
% extract coefficients of a matrix
[c,t] = coeffs([x^3+y^2+z+1 x^2+x*z ; x+y 1], x);
assert(all(t == [ 1  x  x^2  x^3 ]));
assert(all(all(c(:,:,1) == [ y^2 + z + 1  0 ; y  1 ])));
assert(all(all(c(:,:,2) == [ 0  z ; 1  0 ])));

% convert to numeric polynomial
assert(all(sym2poly(3*x^4 + x^2 + 6*x + 5) == [3 0 1 6 5]));

%
% Substitution
%

assert(subspower(x^2+1,x^2,y) == y + 2);
assert(subspower(x^2+1,x,y) == x^2 + 1);
assert(subs(x+1,'x',2*x) == 2*x + 1);
assert(subs(x^2+1,x^2,y) == y + 1);
assert(subs(x*y+1,'x',x-1) == x*y - y + 1);

%
% Error mean
%

% given a unit random variable x, compute the mean of p(x) = 3*x + 2*x^2 - x^3
x = sympoly('x');
[polymean,polyvar] = errorprop(3*x + 2*x^2 - x^3,'x',0,1);
assert(polymean == 2);
assert(polyvar == 14);

% given random variables x and y with N(mux,sx^2), and N(muy,sy^2), compute the
% mean of x*y + 3*y^3
sympolys x y mux muy sx sy;
[polymean,polyvar] = errorprop(x*y+3*y^3,{'x' 'y'},[mux,muy],[sx,sy]);
assert(polymean == mux*muy + 3*muy^3 + 9*muy*sy^2);
assert(polyvar == mux^2*sy^2 + 18*mux*muy^2*sy^2 + 18*mux*sy^4 + 81*muy^4*sy^2 + muy^2*sx^2 + 324*muy^2*sy^4 + sx^2*sy^2 + 135*sy^6);

%
% Dynamic systems
%

u1 = sympoly(symvard('u', -1));
y0 = sympoly(symvard('y', 0));
y1 = sympoly(symvard('y', -1));
y2 = sympoly(symvard('y', -2));
phi = [y0;y1;y2;u1;u1^2;y1*y2;u1*y1];
theta = [-1;1.5;-0.7;1;-0.3;-0.05;0.1];
G = phi'*theta;
assert(diff(G, u1) == -0.6*u1 + 0.1*y1 + 1.0);

%
% More complex examples
%

% a simple construction for a Newton-Cotes integration rule
% Simpson's 3/8 rule
M = vander(0:3);
sympolys x f0 f1 f2 f3;
% an interpolating polynomial on the set of points { (0,f0), (1,f1), (2,f2), (3,f3) }
P = [x^3, x^2, x, 1]*pinv(M)*[f0;f1;f2;f3];
% integrate the polynomial over its support
i = defint(P,'x',[0 3]);
%assert(i == 3/8*f0 + 9/8*f1 + 9/8*f2 + 3/8*f3);

% a 4 point open Newton-Cotes rule
M = vander(1:4);
sympolys x f1 f2 f3 f4;
% an interpolating polynomial on the set of points { (1,f1), (2,f2), (3,f3) (4,f4) }
P = [x^3, x^2, x, 1]*pinv(M)*[f1;f2;f3;f4];
%assert(P == -1/6*f1*x^3 + 3/2*f1*x^2 - 13/3*f1*x + 4*f1 + 1/2*f2*x^3 - 4*f2*x^2 + 19/2*f2*x - 6*f2 - 1/2*f3*x^3 + 7/2*f3*x^2 - 7*f3*x + 4*f3 + 1/6*f4*x^3 - 1*f4*x^2 + 11/6*f4*x - 1*f4);
% integrate the polynomial over the full domain of the rule
i = defint(P,'x',[0 5]);
%assert(i == 55/24*f1 + 5/24*f2 + 5/24*f3 + 55/24*f4);

test_covariance

function test_covariance

n = 6;

c = sympoly(zeros(n,1));
x = sympoly('x');
x0 = sympoly('x0');
xn = sympoly('xn');
sigma_x = sympoly('sigma_x');

for i = 2 : 2 : n
    e = (x0 + xn)^i - x0^i;  % noise compensation of x^i
    c(i) = errorprop(e, {'xn'}, 0, sigma_x);  % take expectation
end
disp(c);  % print using disp

for i = 2 : 1 : n
    for j = i - 1 : -1 : 2
        c(i) = subspower(c(i), x0^j, x^j - c(j));  % substitute (x - xn)^j in place of x0^j
    end
end

c %#ok<NOPRT>  % print using display
code(c)        % print MatLab code for column vector
latex(c)       % print LaTeX code for column vector

code(c.')      % print MatLab code for row vector
latex(c.')     % print LaTeX code for row vector

c(1,2) = sympoly('y');  % extend vector to matrix
code(c)
latex(c)