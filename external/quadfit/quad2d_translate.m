function p = quad2d_translate(p,xt,yt)
% Translates a quadratic curve in implicit form by the given coordinates.
%
% Input arguments:
% p:
%    the parameter vector p corresponding to [x^2 x*y y^2 x y 1]
% xt, yt:
%    the translation vector
%
% See also: quad3d_translate

% Copyright 2012 Levente Hunyadi

validateattributes(p, {'numeric'}, {'nonempty','real','vector'});
p = p(:);
validateattributes(p, {'numeric'}, {'size',[6,1]});
validateattributes(xt, {'numeric'}, {'real','scalar'});
validateattributes(yt, {'numeric'}, {'real','scalar'});

p(:) = ...
    [ p(1) ...
    ; p(2) ...
    ; p(3) ...
    ; p(4) - 2*p(1)*xt - p(2)*yt ...
    ; p(5) - p(2)*xt - 2*p(3)*yt ...
    ; p(6) + p(1)*xt^2 + p(2)*xt*yt + p(3)*yt^2 - p(4)*xt - p(5)*yt ...
    ];
