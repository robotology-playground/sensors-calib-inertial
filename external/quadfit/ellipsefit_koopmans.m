function [theta,mu] = ellipsefit_koopmans(varargin)
% Fit an ellipse to data using the nonlinear Koopmans method.
%
% Input arguments:
% x, y:
%    vectors of data to fit
% sigma_x, sigma_y:
%    noise parameter for x and y dimensions

% Copyright 2012 Levente Hunyadi

[x,y,sigma_x,sigma_y] = quad2dfit_paramchk(mfilename, varargin{:});

[theta,~,mu] = quad2dconfit_koopmans(x, y, sigma_x, sigma_y, 'ellipse');
