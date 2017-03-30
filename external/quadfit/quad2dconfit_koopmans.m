function [p,p0,mu0] = quad2dconfit_koopmans(x, y, sigma_x, sigma_y, Q)
% Fit a constrained quadratic curve to data using the nonlinear Koopmans method.
%
% Input arguments:
% x, y:
%    vectors of data to fit
% sigma_x, sigma_y:
%    noise parameter for x and y dimensions
% Q:
%    constraint matrix in parameters x^2, xy, y^2, x, y and 1.
%
% Output arguments:
% p:
%    estimated parameters (taking constraints into account)
% p0:
%    estimated parameters (not taking constraints into account)
% mu0:
%    noise magnitude (not taking constraints into account)

% References:
% Istvan Vajk and Jeno Hetthessy, "Identification of nonlinear errors-in-variables
%    models", Automatica 39, 2003, pp2099-2107.
% Radim Halir and Jan Flusser, "Numerically stable direct least squares fitting of
%    ellipses", 1998

% Copyright 2012 Levente Hunyadi

narginchk(2,5);
validateattributes(x, {'numeric'}, {'nonempty','real','vector'});
validateattributes(y, {'numeric'}, {'nonempty','real','vector'});
x = x(:);
y = y(:);
count = numel(x);
validateattributes(x, {'numeric'}, {'size',[count,1]});
validateattributes(y, {'numeric'}, {'size',[count,1]});
if nargin > 2
    validateattributes(sigma_x, {'numeric'}, {'nonnegative','scalar'});
    validateattributes(sigma_y, {'numeric'}, {'nonnegative','scalar'});
else
    sigma_x = 1;
    sigma_y = 1;
end
if nargin < 5  % assume a constraint for fitting ellipses
    Q = 'ellipse';
end
if ischar(Q)
    switch Q
        case 'ellipse'  % a constraint for fitting ellipses
            Q1 = [ 0, 0, 2 ; 0, -1, 0 ; 2, 0, 0 ];
        case 'hyperbola'  % a constraint for fitting hyperbolae
            Q1 = [ 0, 0, -2 ; 0, 1, 0 ; -2, 0, 0 ];
    end
    Q = blkdiag(Q1, zeros(3,3));
else
    validateattributes(Q, {'numeric'}, {'nonempty','real','2d','size',[6,6]});
end
x = x(:);
y = y(:);

% normalize data
mx = mean(x);
my = mean(y);
sx = (max(x)-min(x))/2;
sy = (max(y)-min(y))/2;
dx = (x-mx)/sx;  % normalized data point coordinates
dy = (y-my)/sy;
sigma_x = sigma_x/sx;
sigma_y = sigma_y/sy;
angle = atan2(sigma_y, sigma_x);

% build sample data covariance matrix
Z = [dx.^2, dx.*dy, dy.^2, dx, dy, ones(numel(dx),1)];
D = (Z'*Z) / size(Z,1);

% build noise covariance matrix
C = quad2dcov(angle, dx, dy);

% build noise covariance matrix polynomial
T = -C;
T(:,:,1) = D;
% T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3) should be positive semi-definite

% solve eigensystem for noise magnitude given no model constraints
[V,e] = mpolyeig(T);

% find those eigenvalues whose eigenvector is real
ix = all(imag(V) < eps, 1);
e = e(ix);
V = V(:,ix);

% find eigenvalue with smallest magnitude
% that minimizes p' * (T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3)) * p
[~,ix] = sort(abs(e));
mu0 = e(ix(1));
p0 = V(:,ix(1));  % parameter estimates without taking constraints into account

%R = D - quad2dcov(mu0*sigma_x, mu0*sigma_y, dx, dy);
R = mpolyval(T, mu0);

% enforce constraint
p = ellipsefit_robust(R, Q);  % parameter estimates taking constraints into account
%err = p'*R*p;

% unnormalize
p = unnormalize(p, mx, my, sx, sy);
p0 = unnormalize(p0, mx, my, sx, sy);
mu0 = mu0 / (sigma_x^2 + sigma_y^2);  % normalize to noise parameter variance magnitude

function p = unnormalize(p, mx, my, sx, sy)

p = ...
[ p(1)*sy*sy ...
; p(2)*sx*sy ...
; p(3)*sx*sx ...
; -2*p(1)*sy*sy*mx - p(2)*sx*sy*my + p(4)*sx*sy*sy ...
; -p(2)*sx*sy*mx - 2*p(3)*sx*sx*my + p(5)*sx*sx*sy ...
; p(1)*sy*sy*mx*mx + p(2)*sx*sy*mx*my + p(3)*sx*sx*my*my - p(4)*sx*sy*sy*mx - p(5)*sx*sx*sy*my + p(6)*sx*sx*sy*sy ...
];

function p = ellipsefit_eigen(R, Q)
% Constrained fit by solving an eigenvalue problem.
% A simple but numerically unstable way of finding best-fit parameters.
%
% See also: ellipsefit_robust

[V,E] = eig(R, Q);
e = diag(E);

% filter eigenvectors with imaginary components
ix = all(imag(V) < eps, 1);
e = e(ix);
V = V(:,ix);
ix = e > 0;
e = e(ix);
V = V(:,ix);

% find eigenvector with smallest error
[~,ix] = sort(abs(e));
p = V(:,ix(1));
