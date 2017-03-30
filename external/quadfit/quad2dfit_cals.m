function [theta,mu] = quad2dfit_cals(varargin)
% Fit a quadratic curve to data using consistent algebraic least squares.
% Fit a quadratic curve to data using the nonlinear Koopmans method.
%
% Input arguments:
% x, y:
%    vectors of data to fit
% sigma_x, sigma_y:
%    noise parameter for x and y dimensions

% References:
% Istvan Vajk and Jeno Hetthessy, "Identification of nonlinear errors-in-variables
%    models", Automatica 39, 2003, pp2099-2107.
% I. Markovsky, A. Kukush, and S. V. Huffel, "Consistent least squares
%    fitting of ellipsoids", Numer. Math., vol. 98, no. 1, pp. 177--194, 2004
% A. Kukush, I. Markovsky, and S. V. Huffel, "Consistent estimation in an
%    implicit quadratic measurement error model", Comput. Statist. Data Anal.,
%    vol. 47, no. 1, pp. 123--147, 2004.

% Copyright 2012 Levente Hunyadi

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

% build sample data matrix
angle = atan2(sigma_y, sigma_x);
Z = [dx.^2, dx.*dy, dy.^2, dx, dy];
mZ = mean(Z);  % relative offset for hyperplane to pass through origin

% build sample data covariance matrix
DD = (Z'*Z) / size(Z,1);
D = [ DD mZ' ; mZ 1 ];

% build theoretical noise covariance matrix of reduced size
S = quad2dcov(angle, dx, dy);
T = zeros(5,5,3);
T(:,:,1) = -S(1:5,1:5,1) + D(1:5,1:5) - D(1:5,6)*D(6,1:5);
T(:,:,2) = -S(1:5,1:5,2) + D(1:5,6)*S(6,1:5,2) + S(1:5,6,2)*D(6,1:5);
T(:,:,3) = -S(1:5,1:5,3) - S(1:5,6,2) * S(6,1:5,2);
% T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3) should be positive semi-definite

strategy = 'linear_translate';
switch strategy
    case 'polynomial'  % use linear and quadratic components and full matrix size
        [V,e] = mpolyeig(T);

        % find those eigenvalues whose eigenvector is real
        ix = all(imag(V) < eps, 1);
        e = e(ix);
        V = V(:,ix);

        % find eigenvalue with smallest magnitude that minimizes
        % theta' * (T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3)) * theta
        [~,ix] = sort(abs(e));
        mu = e(ix(1));
        theta = V(:,ix(1));
    case 'linear'  % use linear component only (simplified method)
        [V,E] = eig(T(:,:,1),-T(:,:,2));
        e = diag(E);
        [~,ix] = sort(abs(e));
        mu = e(ix(1));
        theta = V(:,ix(1));
    case 'linear_translate'  % use linear component only with data translation
        Z = bsxfun(@minus, Z, mZ);  % translate hyperplane to pass through origin
        [theta,mu] = gsvd_min(Z, chol(-T(:,:,2)));
end

% unnormalize noise magnitude
mu = mu / (sigma_x^2 + sigma_y^2);  % normalize to noise parameter variance magnitude

% unnormalize model parameter vector
theta = [ theta ; -mZ * theta ];

theta = ...
[ theta(1)*sy*sy ...
; theta(2)*sx*sy ...
; theta(3)*sx*sx ...
; -2*theta(1)*sy*sy*mx - theta(2)*sx*sy*my + theta(4)*sx*sy*sy ...
; -theta(2)*sx*sy*mx - 2*theta(3)*sx*sx*my + theta(5)*sx*sx*sy ...
; theta(1)*sy*sy*mx*mx + theta(2)*sx*sy*mx*my + theta(3)*sx*sx*my*my - theta(4)*sx*sy*sy*mx - theta(5)*sx*sx*sy*my + theta(6)*sx*sx*sy*sy ...
];

if nargout < 1
    figure;
    hold('all');
    plot(x, y, 'b.');
    imconic(theta);
    hold('off');
end