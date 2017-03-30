function p = ellipsefit_direct(x,y)
% Direct least squares fitting of ellipses.
%
% Input arguments:
% x,y;
%    x and y coodinates of 2D points
%
% Output arguments:
% p:
%    a 6-parameter vector of the algebraic ellipse fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% Andrew W. Fitzgibbon, Maurizio Pilu and Robert B. Fisher, "Direct Least
%    Squares Fitting of Ellipses", IEEE Trans. PAMI 21, 1999, pp476-480.

% Copyright 2011 Levente Hunyadi

narginchk(2,2);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);

% normalize data
mx = mean(x);
my = mean(y);
sx = (max(x)-min(x))/2;
sy = (max(y)-min(y))/2;
smax = max(sx,sy);
sx = smax;
sy = smax;
x = (x-mx)/sx;
y = (y-my)/sy;

% build design matrix
D = [ x.^2  x.*y  y.^2  x  y  ones(size(x)) ];

% build scatter matrix
S = D'*D;

% build 6x6 constraint matrix
C = zeros(6,6);
C(1,3) = -2;
C(2,2) = 1;
C(3,1) = -2;

if 1
    p = ellipsefit_robust(S,-C);
elseif 0
    % solve eigensystem
    [gevec, geval] = eig(S,C);
    geval = diag(geval);

    % extract eigenvector corresponding to unique negative (nonpositive) eigenvalue
    p = gevec(:,geval < 0 & ~isinf(geval));
    r = geval(geval < 0 & ~isinf(geval));
elseif 0
    % formulation as convex optimization problem
    gamma = 0; %#ok<*UNRCH>
	cvx_begin sdp
        variable('gamma');
        variable('lambda');
        
        maximize(gamma);
        lambda >= 0; %#ok<*VUNUS>
        %[ S + lambda*C,       zeros(size(S,1),1) ...
        %; zeros(1,size(S,2)), lambda - gamma ...
        %] >= 0;
        S + lambda*C >= 0;
        lambda - gamma >= 0;
    cvx_end
    
    % recover primal optimal values from dual
    [evec, eval] = eig(S + lambda*C);
    eval = diag(eval);
    [~,ix] = min(abs(eval));
    p = evec(:,ix);
end

% unnormalize
p(:) = ...
[ p(1)*sy*sy ...
; p(2)*sx*sy ...
; p(3)*sx*sx ...
; -2*p(1)*sy*sy*mx - p(2)*sx*sy*my + p(4)*sx*sy*sy ...
; -p(2)*sx*sy*mx - 2*p(3)*sx*sx*my + p(5)*sx*sx*sy ...
; p(1)*sy*sy*mx*mx + p(2)*sx*sy*mx*my + p(3)*sx*sx*my*my - p(4)*sx*sy*sy*mx - p(5)*sx*sx*sy*my + p(6)*sx*sx*sy*sy ...
];

p = p ./ norm(p);