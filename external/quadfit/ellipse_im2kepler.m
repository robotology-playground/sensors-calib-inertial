function varargout = ellipse_im2kepler(varargin)
% Cast ellipse defined with standard parameter vector to Kepler form.
% The general quadratic equation is a*x^2 + 2*b*x*y + c*y^2 + 2*d*x + 2*f*y + g = 0
% where the standard parameter vector is [a 2*b c 2*d 2*f g].
% In Kepler's form, the foci of an ellipse are (p1;p2) and (q1;q2) and 2*a is the major
% axis such that the parameter vector is [p1 p2 q1 q2 a] and the ellipse is expressed
% by the equation P = sqrt((x-p1)^2+(y-p2)^2) + sqrt((x-q1)^2+(y-q2)^2) - 2*a = 0.
%
% See also: ellipse_kepler2im

% Copyright 2011 Levente Hunyadi

if nargin > 1
    narginchk(6,6);
    for k = 1 : 6
        validateattributes(varargin{k}, {'numeric'}, {'real','scalar'});
    end
    [p1,p2,q1,q2,semia] = ellipse_kepler(varargin{:});
    varargout = num2cell([p1,p2,q1,q2,semia]);
else
    narginchk(1,1);
    p = varargin{1};
    validateattributes(p, {'numeric'}, {'real','vector'});
    p = p(:);
    validateattributes(p, {'numeric'}, {'size',[6 1]});
    [p1,p2,q1,q2,semia] = ellipse_kepler(p(1), 0.5*p(2), p(3), 0.5*p(4), 0.5*p(5), p(6));
    varargout{1} = [p1,p2,q1,q2,semia];
end

function [p1,p2,q1,q2,semia] = ellipse_kepler(a,b,c,d,f,g)
% Cast ellipse defined with standard parameter vector to Kepler form.

% helper quantities
N = 2*(a*f^2+c*d^2+g*b^2-2*b*d*f-a*c*g);
D = b^2-a*c;
S = realsqrt((a-c)^2+4*b^2);

% semi-axes
ap = realsqrt( N/(D*(S-(a+c))) );
bp = realsqrt( N/(D*(-S-(a+c))) );
semia = max(ap,bp);
semib = min(ap,bp);

% center
c1 = (c*d-b*f)/D;
c2 = (a*f-b*d)/D;

% angle of tilt
if b ~= 0
    if abs(a) < abs(c)
        phi = 0.5*acot((a-c)/(2*b));
    else
        phi = 0.5*pi+0.5*acot((a-c)/(2*b));
    end
else
    if abs(a) < abs(c)
        phi = 0;
    else  % a > c
        phi = 0.5*pi;
    end
end

% distance of foci from center
semic = realsqrt(semia^2-semib^2);

% coordinates of foci
p1 = c1 + semic*cos(phi);
p2 = c2 + semic*sin(phi);
q1 = c1 - semic*cos(phi);
q2 = c2 - semic*sin(phi);
