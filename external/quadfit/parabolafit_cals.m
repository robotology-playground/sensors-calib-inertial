function [p,mu] = parabolafit_cals(varargin)
% Fit a parabola using consistent algebraic least squares.
%
% Input arguments:
% x,y;
%    x and y coodinates of 2D points
%
% Output arguments:
% p:
%    a 6-parameter vector of the algebraic parabola fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% Matthew Harker, Paul O'Leary and Paul Zsombor-Murray, "Direct type-specific conic
%    fitting and eigenvalue bias correction", Image and Vision Computing, 26:372-381,
%    2008.

% Copyright 2013 Levente Hunyadi

[x,y,sigma_x,sigma_y] = quad2dfit_paramchk(mfilename, varargin{:});

% normalize data
mx = mean(x);
my = mean(y);
sx = (max(x)-min(x))/2;  % scaling for x
sy = (max(y)-min(y))/2;  % scaling for y
dx = (x-mx)/sx;  % normalized data point coordinates
dy = (y-my)/sy;
sigma_x = sigma_x/sx;  % scaling for sigma_x
sigma_y = sigma_y/sy;  % scaling for sigma_y

% translate hyperplane to pass through origin
Z = [dx.^2, dx.*dy, dy.^2, dx, dy];
mZ = mean(Z);
Z = bsxfun(@minus, Z, mZ);
D = (Z'*Z) / size(Z,1);

% build covariance polynomial
angle = atan2(sigma_y, sigma_x);
Psi = -quad2dcovred(angle, x, y);
Psi(:,:,1) = Psi(:,:,1) + D;

% find those eigenvalues whose eigenvector is real and finite
[~,e] = mpolyeig(Psi);
ix = abs(imag(e)) < eps & isfinite(e);
e = e(ix);

% find eigenvalue with smallest magnitude that minimizes
% theta' * (T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3)) * theta
[~,ix] = min(abs(e));
mu = e(ix);

% covariance matrix with noise canceled
R = Psi(:,:,1) + mu*Psi(:,:,2) + mu^2*Psi(:,:,3);

S1 = R(1:3,1:3);  % quadratic part of the scatter matrix
S2 = R(1:3,4:5);  % combined part of the scatter matrix
S3 = R(4:5,4:5);  % linear part of the scatter matrix
T = -(S3 \ S2');  % for getting a2 from a1
M = S1 + S2 * T;  % reduced scatter matrix

p = parabolafit_directm(M);

% recover parabola coefficients
p = [ eye(3,3) ; T ] * p;

% unnormalize noise magnitude
mu = mu / (sigma_x^2 + sigma_y^2);  % normalize to noise parameter variance magnitude

% unnormalize model parameter vector
p = [ p ; -mZ * p ];

p = ...
[ p(1)*sy*sy ...
; p(2)*sx*sy ...
; p(3)*sx*sx ...
; -2*p(1)*sy*sy*mx - p(2)*sx*sy*my + p(4)*sx*sy*sy ...
; -p(2)*sx*sy*mx - 2*p(3)*sx*sx*my + p(5)*sx*sx*sy ...
; p(1)*sy*sy*mx*mx + p(2)*sx*sy*mx*my + p(3)*sx*sx*my*my - p(4)*sx*sy*sy*mx - p(5)*sx*sx*sy*my + p(6)*sx*sx*sy*sy ...
];
