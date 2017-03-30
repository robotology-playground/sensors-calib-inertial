function p = quad2dfit_hyperaccurate(x,y)
% General quadratic curve fit with Kanatani's hyperaccurate fit method.
%
% Input arguments:
% x,y;
%    x and y coodinates of 2D points
%
% Output arguments:
% p:
%    a 6-parameter vector of the algebraic quadratic curve fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% Kenichi Kanatani and Prasanna Rangarajan, "Hyperaccurate Ellipse Fitting without
%    Iterations", Memoirs of the Faculty of Engineering, Okayama University, Vol. 44,
%    pp. 42-49, January 2010.

% Copyright 2012 Levente Hunyadi

% normalize data
mx = mean(x);
my = mean(y);
sx = (max(x)-min(x))/2;
sy = (max(y)-min(y))/2;
smax = max(sx,sy);
sx = smax;
sy = smax;
x = (x-mx)/sx;  % normalized data point coordinates
y = (y-my)/sy;

% sample mean and sample covariance matrix
epsilon_c = zeros(6,1);
M = zeros(6,6);
for k = 1 : numel(x)
    epsilon = [ x(k)^2 ; 2*x(k)*y(k) ; y(k)^2 ; 2*x(k) ; 2*y(k) ; 1 ];
    epsilon_c = epsilon_c + epsilon;
    M = M + (epsilon * epsilon');
end
epsilon_c = epsilon_c / numel(x);
M = M / numel(x);
Mi = pinv(M);

% Taubin method N
N_T = zeros(6,6);
for k = 1 : numel(x)
    V_0 = 4 * ...
        [    x(k)^2,     x(k)*y(k),         0, x(k),    0, 0 ...
        ; x(k)*y(k), x(k)^2+y(k)^2, x(k)*y(k), y(k), x(k), 0 ...
        ;         0,     x(k)*y(k),    y(k)^2,    0, y(k), 0 ...
        ;      x(k),          y(k),         0,    1,    0, 0 ...
        ;         0,          x(k),      y(k),    0,    1, 0 ...
        ;         0,             0,         0,    0,    0, 0 ];
    N_T = N_T + V_0;
end
N_T = N_T / numel(x);

% first-order terms
e = [ 1 ; 0 ; 1 ; 0 ; 0 ; 0 ];
O_1 = (epsilon_c * e') + (e * epsilon_c');

% second-order terms
O_2 = zeros(6,6);
for k = 1 : numel(x)
    epsilon = [ x(k)^2 ; 2*x(k)*y(k) ; y(k)^2 ; 2*x(k) ; 2*y(k) ; 1 ];
    V_0 = 4 * ...
        [    x(k)^2,     x(k)*y(k),         0, x(k),    0, 0 ...
        ; x(k)*y(k), x(k)^2+y(k)^2, x(k)*y(k), y(k), x(k), 0 ...
        ;         0,     x(k)*y(k),    y(k)^2,    0, y(k), 0 ...
        ;      x(k),          y(k),         0,    1,    0, 0 ...
        ;         0,          x(k),      y(k),    0,    1, 0 ...
        ;         0,             0,         0,    0,    0, 0 ];

    % second-order terms
    E = (epsilon * epsilon');
    
    %O_2 = O_2 + trace(Mi * V_0) * E + (epsilon' * Mi * epsilon) * V_0 + (V_0 * Mi * E) + (V_0 * Mi * E)';
    VME = V_0 * Mi * E;
    O_2 = O_2 + trace(Mi * V_0) * E + (epsilon' * Mi * epsilon) * V_0 + VME + VME';
end
O_2 = O_2 / numel(x)^2;

% compute weight N
N = N_T + O_1 - O_2;

% eigenvector belonging to eigenvalue with smallest absolute value
[V,D] = eig(M,N);
[~,ix] = sort(abs(diag(D)));
p = V(:,ix(1));

p(:) = [ p(1) ; 2*p(2) ; p(3) ; 2*p(4) ; 2*p(5) ; p(6) ];

p = ...
[ p(1)*sy*sy ...
; p(2)*sx*sy ...
; p(3)*sx*sx ...
; -2*p(1)*sy*sy*mx - p(2)*sx*sy*my + p(4)*sx*sy*sy ...
; -p(2)*sx*sy*mx - 2*p(3)*sx*sx*my + p(5)*sx*sx*sy ...
; p(1)*sy*sy*mx*mx + p(2)*sx*sy*mx*my + p(3)*sx*sx*my*my - p(4)*sx*sy*sy*mx - p(5)*sx*sx*sy*my + p(6)*sx*sx*sy*sy ...
];
