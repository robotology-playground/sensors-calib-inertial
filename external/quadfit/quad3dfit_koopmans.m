function [p,mu] = quad3dfit_koopmans(varargin)
% Fit a quadratic curve to data using the nonlinear Koopmans method.
%
% Input arguments:
% x, y, z:
%    vectors of data to fit
% sigma_x, sigma_y, sigma_z:
%    noise parameter for x, y and z dimensions
%
% References:
% Istvan Vajk and Jeno Hetthessy, "Identification of nonlinear errors-in-variables
%    models", Automatica 39, 2003, pp2099-2107.

% Copyright 2012 Levente Hunyadi

[x,y,z,sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk(mfilename, varargin{:});

Z = [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, ones(numel(x),1)];
D = (Z'*Z) / size(Z,1);
C = quad3dcovpoly(sigma_x, sigma_y, sigma_z, x, y, z);
T = -C;
T(:,:,1) = D;

[V,e] = mpolyeig(T);

% find those eigenvalues whose eigenvector is real
ix = all(imag(V) < eps, 1);
e = e(ix);
V = V(:,ix);

% find eigenvalue with magnitude closest to 1
[~,ix] = sort(abs(1-e));
mu = e(ix(1));
p = V(:,ix(1));
