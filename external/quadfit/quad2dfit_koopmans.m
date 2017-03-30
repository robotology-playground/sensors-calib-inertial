function [theta,mu] = quad2dfit_koopmans(varargin)
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

% Copyright 2012 Levente Hunyadi

[x,y,sigma_x,sigma_y] = quad2dfit_paramchk(mfilename, varargin{:});

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
Z = [dx.^2, dx.*dy, dy.^2, dx, dy, ones(numel(x),1)];
D = (Z'*Z) / size(Z,1);
C = quad2dcov(angle, dx, dy);
T = -C;
T(:,:,1) = D;
% T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3) should be positive semi-definite

[V,e] = mpolyeig(T);

% find those eigenvalues whose eigenvector is real
ix = abs(imag(e)) < eps & isfinite(e);
e = e(ix);
V = V(:,ix);

% find eigenvalue with smallest magnitude that minimizes
% theta' * (T(:,:,1) - mu*T(:,:,2) - mu^2*T(:,:,3)) * theta
[~,ix] = min(abs(e));
mu = e(ix);
theta = V(:,ix);

mu = mu / (sigma_x^2 + sigma_y^2);  % normalize to noise parameter variance magnitude

% unnormalize
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