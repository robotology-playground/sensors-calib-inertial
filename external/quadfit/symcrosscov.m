function C = symcrosscov(phi1, phi2, sysvars)
% Compensation for observation cross-covariance matrix.
%
% Given a sample data covariance matrix D = E( phi1 * phi2' ) of noisy
% observations, compute the noise compensation C such that C = D - D0
% where D0 is based on noise-free observations.
%
% Input arguments:
% phi1, phi2:
%    a vector of terms to compute the cross-covariance of, e.g. [x x^2 y],
%    or a polynomial system equation, e.g. 2*x+4*x^2+6*y
%
% Output arguments:
% C:
%    a cross-covariance matrix as a function of noise variances and (means
%    of) noisy observatons, e.g. sigma_x, sigma_y, x, y, x.^2
%
% Example:
% Compute the cross-covariance compensation for following vectors observed
% with noise: phi = [x^2 x*y y^2 x y] and epsilon = [x y]
%
% >> x = sympoly(symvariable('x'));
% >> y = sympoly(symvariable('y'));
% >> symcrosscov([x^2 x*y y^2 x y], [x y]);
% [ 3*sigma_x^2*x    sigma_x^2*y ]
% [   sigma_x^2*y    sigma_y^2*x ]
% [   sigma_y^2*x  3*sigma_y^2*y ]
% [     sigma_x^2              0 ]
% [             0      sigma_y^2 ]
%
% This implies that the cross-covariance compensation for cov(x^2,x) is
% 3*sigma_x^2*mean(x), i.e. cov(x^2,x)-cov(x0^2,x0) = 3*sigma_x^2*mean(x).

% Copyright 2009-2011 Levente Hunyadi

% data covariance matrix (including noise contribution)
if numel(phi1) > 1
    t1 = phi1;
else
    [t1,~] = terms(phi1);  % drop term coefficients
end
if numel(phi2) > 1
    t2 = phi2;
else
    [t2,~] = terms(phi2);
end
D = t1(:) * t2(:)';

if nargin < 3
    % variables in system
    sysvars = union(variables(phi1), variables(phi2));
end

% variables in noise-free data covariance matrix
vars = sysvars;
for k = 1 : numel(sysvars)
    vars(k) = copy(sysvars(k), [ sysvars(k).Name '0' ]);  % e.g. u0[k-1]
end

% noise-free data covariance matrix
D0 = renamevars(D, sysvars, vars);

% noise covariance matrix
C = D - D0;

% express expected value of noise contribution in terms of noise
% covariances and noisy observations
for i = 1 : numel(t2)
    for j = 1 : numel(t1)
        s = C(j,i);
        for k = 1 : numel(D(j,i).Variables)
            % noisy data in D are expressed in terms of noise variances and
            % lower-order noise-free data, e.g. x^3 = x0^3 + 3*sigma_x^2*x0
            % sigma_x: standard deviation of noise contribution
            % x, x0:   expected value of noisy and noise-free sequence
            var = D(j,i).Variables(k);               % e.g. u[k-1]
            if ~any(var == sysvars)
                continue;  % skip variables that denote constants
            end
            
            polyvar = sympoly(var);

            % express noisy data in terms of noise-free data and noise;
            % by construction, highest-degree noise-free term is canceled
            vartrue = copy(var, [ var.Name '0' ]);   % e.g. u0[k-1]
            polytrue = sympoly(vartrue);
            varnoise = copy(var, [ var.Name 'n' ]);  % e.g. un[k-1]
            polynoise = sympoly(varnoise);
            s = subs(s, polyvar, polytrue + polynoise);

            % take expectation for noise contributions
            sigma = symvariable(['sigma_' var.Name]);     % e.g. sigma_u for u[k-1]
            polysigma = sympoly(sigma);
            s = errorprop(s, varnoise, 0, polysigma);

            % eliminate lower-degree noise-free data using noisy data
            % e.g. x0 --> x, x0^2 --> x^2 - sigma_x^2, etc.
            p = degree(s, vartrue);
            while p > 0
                e = errorprop((polytrue + polynoise)^p - polytrue^p, varnoise, 0, polysigma);
                s = subspower(s, polytrue^p, polyvar^p - e);  % substitute (x - xn) in place of x0
                p = degree(s, vartrue);
            end
        end
        C(j,i) = s;
    end
end
