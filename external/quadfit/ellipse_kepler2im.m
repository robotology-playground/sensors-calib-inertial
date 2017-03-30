function p = ellipse_kepler2im(varargin)
% Cast ellipse defined in Kepler form to standard parameter vector form.
% The general quadratic equation is a*x^2+2*b*x*y+c*y^2+2*d*x+2*f*y+g = 0 where the
% standard parameter vector is [a 2*b c 2*d 2*f g].
% In Kepler's form, the foci of an ellipse are (p1;p2) and (q1;q2) and 2*a is the major
% axis such that the parameter vector is [p1 p2 q1 q2 a] and the ellipse is expressed
% by the equation P = sqrt((x-p1)^2+(y-p2)^2) + sqrt((x-q1)^2+(y-q2)^2) - 2*a = 0.
%
% See also: ellipse_im2kepler

% Copyright 2011 Levente Hunyadi

if nargin > 1
    narginchk(5,5);
    for k = 1 : 5
        validateattributes(varargin{k}, {'numeric'}, {'real','scalar'});
    end
    p = ellipse_standard(varargin{:});
else
    narginchk(1,1);
    q = varargin{1};
    validateattributes(q, {'numeric'}, {'real','vector'});
    q = q(:);
    validateattributes(q, {'numeric'}, {'size',[5 1]});
    p = ellipse_standard(q(1), q(2), q(3), q(4), q(5));
end

function p = ellipse_standard(p1,p2,q1,q2,a)
% Cast ellipse defined in Kepler form to standard parameter vector form.

p = ...
[ -16*a^2 + 4*p1^2 - 8*p1*q1 + 4*q1^2 ...    % x^2
; 8*p1*p2 - 8*p1*q2 - 8*p2*q1 + 8*q1*q2 ...  % x*y
; -16*a^2 + 4*p2^2 - 8*p2*q2 + 4*q2^2 ...    % y^2
; 16*a^2*p1 + 16*a^2*q1 - 4*p1^3 + 4*p1^2*q1 - 4*p1*p2^2 + 4*p1*q1^2 + 4*p1*q2^2 + 4*p2^2*q1 - 4*q1^3 - 4*q1*q2^2 ...  % x
; 16*a^2*p2 + 16*a^2*q2 - 4*p1^2*p2 + 4*p1^2*q2 - 4*p2^3 + 4*p2^2*q2 + 4*p2*q1^2 + 4*p2*q2^2 - 4*q1^2*q2 - 4*q2^3 ...  % y
; 16*a^4 - 8*a^2*p1^2 - 8*a^2*p2^2 - 8*a^2*q1^2 - 8*a^2*q2^2 + p1^4 + 2*p1^2*p2^2 - 2*p1^2*q1^2 - 2*p1^2*q2^2 + p2^4 - 2*p2^2*q1^2 - 2*p2^2*q2^2 + q1^4 + 2*q1^2*q2^2 + q2^4 ...  % 1
];

p = p ./ norm(p);