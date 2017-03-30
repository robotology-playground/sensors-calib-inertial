function p = quad3d_translate(p,xt,yt,zt)
% Translates a quadratic surface in implicit form by the given coordinates.
%
% Input arguments:
% p:
%    the parameter vector p corresponding to [x^2, y^2, z^2, x*y, x*z, y*z, x, y, z, 1]
% xt, yt:
%    the translation vector
%
% See also: quad2d_translate

% Copyright 2012 Levente Hunyadi

validateattributes(p, {'numeric'}, {'nonempty','real','vector'});
p = p(:);
validateattributes(p, {'numeric'}, {'size',[10,1]});
validateattributes(xt, {'numeric'}, {'real','scalar'});
validateattributes(yt, {'numeric'}, {'real','scalar'});
validateattributes(zt, {'numeric'}, {'real','scalar'});

% Original implicit equation with shifted terms substituted:
% 0 = a*(x-xt)^2 + b*(y-yt)^2 + c*(z-zt)^2
%   + f*(x-xt)*(y-yt) + g*(x-xt)*(z-zt) + h*(y-yt)*(z-zt)
%   + p*(x-xt) + q*(y-yt) + r*(z-zt) + d
%
% Equation expanded:
% 0 = a*x^2 + a*xt^2 - 2*a*x*xt
%   + b*y^2 + b*yt^2 - 2*b*y*yt
%   + c*z^2 + c*zt^2 - 2*c*z*zt
%   + f*x*y - f*x*yt - f*xt*y + f*xt*yt
%   + g*x*z - g*x*zt - g*xt*z + g*xt*zt
%   + h*y*z - h*y*zt - h*yt*z + h*yt*zt
%   + p*x - p*xt
%   + q*y - q*yt
%   + r*z - r*zt
%   + d

p(:) = ...
    [ p(1) ...
    ; p(2) ...
    ; p(3) ...
    ; p(4) ...
    ; p(5) ...
    ; p(6) ...
    ; p(7) - 2*p(1)*xt - p(4)*yt - p(5)*zt ...
    ; p(8) - 2*p(2)*yt - p(4)*xt - p(6)*zt ...
    ; p(9) - 2*p(3)*zt - p(5)*xt - p(6)*yt ...
    ; p(10) + p(1)*xt^2 + p(2)*yt^2 + p(3)*zt^2 + p(4)*xt*yt + p(5)*xt*zt + p(6)*yt*zt - p(7)*xt - p(8)*yt - p(9)*zt ...
    ];
