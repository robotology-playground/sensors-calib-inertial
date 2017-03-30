function theta = parabolafit_directm(M)
% Direct least squares fitting of parabolas using a pre-processed scatter matrix.
%
% This private function is not to be used directly, but indirectly via one of the parabola fitting
% methods.
%
% Input arguments:
% M:
%    a full, reduced or noise-compensated scatter matrix
%
% Output arguments:
% theta:
%    estimated parameters, which may need normalization
%
% See also: parabolafit_cals, parabolafit_direct
%
% References:
% Matthew Harker, Paul O'Leary and Paul Zsombor-Murray, "Direct type-specific conic fitting and
%    eigenvalue bias correction", Image and Vision Computing, 26:372-381, 2008.

% Copyright 2012 Levente Hunyadi

validateattributes(M, {'numeric'}, {'real','nonempty','2d'});

% solve eigensystem
[V,E] = eig(M);
lambda = diag(E);

% largest magnitude eigenvalue first
[~,ix] = sort(abs(lambda), 'descend');
V(:,:) = V(:,ix);
V(:,:) = V(:,:)';  % ?
lambda(:) = lambda(ix);

% expand (V(2,3) + V(2,2)*s + V(2,1)*t)^2 - 4*(V(1,3) + V(1,2)*s + V(1,1)*t)*(V(3,3) + V(3,2)*s + V(3,1)*t)
gamma = zeros(6,1);
gamma(1) = V(2,2)^2 - 4*V(1,2)*V(3,2);                           % coefficient of s^2
gamma(2) = 2*V(2,1)*V(2,2) - 4*V(1,1)*V(3,2) - 4*V(1,2)*V(3,1);  % coefficient of s*t
gamma(3) = V(2,1)^2 - 4*V(1,1)*V(3,1);                           % coefficient of t^2
gamma(4) = 2*V(2,2)*V(2,3) - 4*V(1,2)*V(3,3) - 4*V(1,3)*V(3,2);  % coefficient of s
gamma(5) = 2*V(2,1)*V(2,3) - 4*V(1,1)*V(3,3) - 4*V(1,3)*V(3,1);  % coefficient of t
gamma(6) = V(2,3)^2 - 4*V(1,3)*V(3,3);                           % constant term

if 0
    % expression as derived in Harker, O'Leary and Zsombor-Murray
    alpha = zeros(3,1);
    alpha(1) = lambda(1)^2;
    alpha(2) = lambda(2)^2;
    alpha(3) = alpha(1) * alpha(2);

    kappa = zeros(8,1);
    kappa(1) = 4*gamma(3)*gamma(6) - gamma(5)^2;
    kappa(2) = gamma(2)*gamma(6) - 0.5*gamma(4)*gamma(5);
    kappa(3) = 0.5*gamma(2)*gamma(5) - gamma(3)*gamma(4);
    kappa(4) = 4*gamma(6)*gamma(1) - gamma(4)^2;
    kappa(5) = 4*gamma(1)*gamma(3) - gamma(2)^2;
    kappa(6) = gamma(2)*gamma(4) - 2*gamma(1)*gamma(5);
    kappa(7) = -4*(gamma(1)*alpha(1) + alpha(2)*gamma(3));
    kappa(8) = gamma(1)*kappa(1) - gamma(2)*kappa(2) + gamma(4)*kappa(3);

    Kappa = zeros(5,1);
    Kappa(1) = kappa(5)*kappa(8);                                                                                              % coefficient of mu^4
    Kappa(2) = 2*kappa(7)*kappa(8);                                                                                            % coefficient of mu^3
    Kappa(3) = 4*((2*gamma(2)*kappa(2) + 4*kappa(8))*alpha(3) + gamma(1)*kappa(4)*alpha(1)^2 + gamma(3)*Kappa(1)*alpha(2)^2);  % coefficient of mu^2
    Kappa(4) = -8*alpha(3)*(kappa(1)*alpha(2) + kappa(4)*alpha(1));                                                            % coefficient of mu
    Kappa(5) = 16*gamma(6)*alpha(3)^2;                                                                                         % constant term
    
    r = roots(Kappa);
    e = zeros(size(r));
    for k = 1 : numel(r)
        mu = r(k);

        u = kappa(5)*mu^2 + kappa(7)*mu + 4*alpha(3);
        s = 2*mu/u * (kappa(3)*mu + alpha(1)*gamma(4));
        t = mu/u * (kappa(6)*mu + 2*alpha(2)*gamma(5));

        theta = V(:,3) + s*V(:,2) + t*V(:,1);
        e(k) = abs(theta(2)^2 - 4*theta(1)*theta(3));  % find the root that best fits the constraint b^2 - 4*a*c
    end
    [~,ix] = min(e);
    mu = r(ix);

    u = kappa(5)*mu^2 + kappa(7)*mu + 4*alpha(3);
    s = 2*mu/u * (kappa(3)*mu + alpha(1)*gamma(4));
    t = mu/u * (kappa(6)*mu + 2*alpha(2)*gamma(5));
    
    % obtain quadratic part of parabola parameters
    theta = V(:,3) + s*V(:,2) + t*V(:,1);
    theta = theta ./ norm(theta);
elseif 0
    p = V' * [0,0,-2;0,1,0;-2,0,0] * V;
    kappa(1) = lambda(1)*p(1,2)*p(2,2)+p(1,1)*lambda(2)*p(1,2) ;
    kappa(2) = 2*lambda(1)*p(1,2)*p(2,3)+p(1,1)*lambda(2)*p(1,3) ;
    kappa(3) = lambda(1)*p(1,2)*p(3,3) ;
    kappa(4) = (2*p(1,2)^2-p(1,1)*p(2,2))*lambda(2)+p(2,2)^2*lambda(1) ;
    kappa(5) = (-2*p(1,1)*p(2,3)+4*p(1,2)*p(1,3))*lambda(2)+3*p(2,3)*lambda(1)*p(2,2) ;
    kappa(6) = (2*p(2,3)^2+p(3,3)*p(2,2))*lambda(1)+(-p(3,3)*p(1,1)+2*p(1,3)^2)*lambda(2) ;
    kappa(7) = p(3,3)*lambda(1)*p(2,3) ;
    kappa(8) = (2*p(1,2)^2-p(1,1)*p(2,2))*lambda(1)+lambda(2)*p(1,1)^2 ;
    kappa(9) = (2*p(1,2)*p(1,3)-p(1,1)*p(2,3))*lambda(1) ;

    Kappa = ...
        [ -kappa(4)*kappa(8) + kappa(1)^2 ...
        ; 2*kappa(1)*kappa(2) - kappa(4)*kappa(9) - kappa(5)*kappa(8) ...
        ; 2*kappa(1)*kappa(3) - kappa(5)*kappa(9) - kappa(6)*kappa(8) + kappa(2)^2 ...
        ; -kappa(6)*kappa(9) + 2*kappa(2)*kappa(3) - kappa(7)*kappa(8) ...
        ; -kappa(7)*kappa(9) + kappa(3)^2 ...
        ];

    r = roots(Kappa);
    r(abs(imag(r)) > 0) = [];
    num = -( kappa(1) * r.^2 + kappa(2) * r + kappa(3) );
    den = kappa(8) * r + kappa(9);
    s = num ./ den;
    Theta = V * [ s'; r'; ones(size(r')) ];
    
    e = zeros(size(r));
    for k = 1 : numel(r)
        e(k) = Theta(:,k)'*M*Theta(:,k);
    end
    [~,ix] = min(e);
    theta = Theta(:,ix);
else
    % expression as computed by parabolafit_direct_symbolic
    Kappa = zeros(5,1);  % coefficient of [mu^4, mu^3, mu^2, mu, 1] (the last being the constant term)
    Kappa(1) = 16*gamma(6)*gamma(1)^2*gamma(3)^2 - 4*gamma(1)^2*gamma(3)*gamma(5)^2 - 8*gamma(6)*gamma(1)*gamma(2)^2*gamma(3) + gamma(1)*gamma(2)^2*gamma(5)^2 + 4*gamma(1)*gamma(2)*gamma(3)*gamma(4)*gamma(5) - 4*gamma(1)*gamma(3)^2*gamma(4)^2 + gamma(6)*gamma(2)^4 - gamma(2)^3*gamma(4)*gamma(5) + gamma(2)^2*gamma(3)*gamma(4)^2;
    Kappa(2) = 32*gamma(6)*gamma(1)^2*gamma(3)*lambda(1)^2 - 8*gamma(1)^2*gamma(5)^2*lambda(1)^2 - 8*gamma(6)*gamma(1)*gamma(2)^2*lambda(1)^2 + 8*gamma(1)*gamma(2)*gamma(4)*gamma(5)*lambda(1)^2 + 32*gamma(6)*gamma(1)*gamma(3)^2*lambda(2)^2 - 8*gamma(1)*gamma(3)*gamma(4)^2*lambda(1)^2 - 8*gamma(1)*gamma(3)*gamma(5)^2*lambda(2)^2 - 8*gamma(6)*gamma(2)^2*gamma(3)*lambda(2)^2 + 8*gamma(2)*gamma(3)*gamma(4)*gamma(5)*lambda(2)^2 - 8*gamma(3)^2*gamma(4)^2*lambda(2)^2;
    Kappa(3) = 16*gamma(6)*gamma(1)^2*lambda(1)^4 + 64*gamma(6)*gamma(1)*gamma(3)*lambda(1)^2*lambda(2)^2 - 4*gamma(1)*gamma(4)^2*lambda(1)^4 - 16*gamma(1)*gamma(5)^2*lambda(1)^2*lambda(2)^2 - 8*gamma(6)*gamma(2)^2*lambda(1)^2*lambda(2)^2 + 12*gamma(2)*gamma(4)*gamma(5)*lambda(1)^2*lambda(2)^2 + 16*gamma(6)*gamma(3)^2*lambda(2)^4 - 16*gamma(3)*gamma(4)^2*lambda(1)^2*lambda(2)^2 - 4*gamma(3)*gamma(5)^2*lambda(2)^4;
    Kappa(4) = - 8*gamma(4)^2*lambda(1)^4*lambda(2)^2 - 8*gamma(5)^2*lambda(1)^2*lambda(2)^4 + 32*gamma(1)*gamma(6)*lambda(1)^4*lambda(2)^2 + 32*gamma(3)*gamma(6)*lambda(1)^2*lambda(2)^4;
    Kappa(5) = 16*gamma(6)*lambda(1)^4*lambda(2)^4;
    
    r = roots(Kappa);
    r(abs(imag(r)) > 0) = [];  % delete imaginary solutions

    s = zeros(size(r));
    t = zeros(size(r));
    e = zeros(size(r));
    for k = 1 : numel(r)
        % find the root that best fits the data
        mu = r(k);
        s(k) = -(mu*(gamma(4) - (gamma(2)*gamma(5)*mu)/(2*lambda(1)^2 + 2*gamma(3)*mu)))/(2*lambda(2)^2 + mu*(2*gamma(1) - (gamma(2)^2*mu)/(2*lambda(1)^2 + 2*gamma(3)*mu)));
        t(k) = -(mu*(gamma(5) - (gamma(2)*gamma(4)*mu)/(2*lambda(2)^2 + 2*gamma(1)*mu)))/(2*lambda(1)^2 + mu*(2*gamma(3) - (gamma(2)^2*mu)/(2*lambda(2)^2 + 2*gamma(1)*mu)));
        theta = V(:,3) + s(k)*V(:,2) + t(k)*V(:,1);
        e(k) = abs(theta'*M*theta);
    end
    [~,ix] = min(e);

    % obtain quadratic part of parabola parameters
    theta = V(:,3) + s(ix)*V(:,2) + t(ix)*V(:,1);
    theta = theta ./ norm(theta);
end

function parabolafit_direct_symbolic
% Symbolic derivation of the Lagrangian used for parabola estimation.

% variables for eigenvector combination
s = sym('s');
t = sym('t');

% express solution as a combination of eigenvectors
V = symm('V',3,3);
expr = expand((V(2,3) + V(2,2)*s + V(2,1)*t)^2 - 4*(V(1,3) + V(1,2)*s + V(1,1)*t)*(V(3,3) + V(3,2)*s + V(3,1)*t));
expr

% variables for Lagrange function
gamma = symm('gamma',6,1);  % helper coefficients for constraint
lambda = symm('lambda',3,1);  % eigenvalues
C = gamma(1)*s^2 + gamma(2)*s*t + gamma(3)*t^2 + gamma(4)*s + gamma(5)*t + gamma(6);  % constraint
D = lambda(3)^2 + lambda(2)^2*s^2 + lambda(1)^2*t^2;  % delta expression to minimize
mu = sym('mu');  % Lagrange multiplier

% Lagrange function and derivatives
H = D + mu*C;
dHs = diff(H,s);
dHt = diff(H,t);
dHmu = diff(H,mu);

% express s and t in terms of mu
ds = simple(solve(subs(dHs, t, solve(dHt, t)), s));
dt = simple(solve(subs(dHt, s, solve(dHs, s)), t));

% substitute s and t in constraint expression
dHmu = subs(dHmu,s,ds);
dHmu = subs(dHmu,t,dt);
dHmu = simple(dHmu);
[dHmu,~] = numden(dHmu);  % multiply by denominator (allowed since dHmu == 0)

ds
dt
[c,t] = coeffs(dHmu,mu)
