function theta = ellipsoidfit_aml(x,y,z,sigma)
% Approximated maximum likelihood fit of ellipsoids.
% The constraint confines the class of ellipsoids to fit to those whose smallest radius
% is at least half of the largest radius.
% The method is iterative.
%
% Input arguments:
% x,y,z:
%    x, y and z coodinates of 3D points
% sigma (optional):
%    noise variance
%
% Output arguments:
% theta:
%    a 10-parameter vector of the algebraic ellipsoid fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0

% Copyright 2011 Levente Hunyadi

narginchk(3,3);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
z = z(:);
if nargin < 4
    sigma = 1;
else
    validateattributes(sigma, {'numeric'}, {'positive','scalar'});
end

C = diag(repmat(sigma, 1, 3));
X = zeros(10,10);

theta = ellipsoidfit_direct(x,y,z);
theta2 = ones(10,1) / norm(ones(10,1));

while norm(theta2 - theta) > 1e-3
    theta2 = theta;  % value from previous iteration
    
    for i = 1 : numel(x)
        vi = [ x(i).^2; y(i).^2; z(i).^2; y(i).*z(i); x(i).*z(i); x(i).*y(i); x(i); y(i); z(i); 1 ];
        Ai = vi * vi';
        dvi = ...
        [ 2*x(i), 0, 0, 0, z(i), y(i), 1, 0, 0, 0 ...
        ; 0, 2*y(i), 0, z(i), 0, x(i), 0, 1, 0, 0 ...
        ; 0, 0, 2*z(i), y(i), x(i), 0, 0, 0, 1, 0 ...
        ]';
        Bi = dvi * C * dvi';

        Xi = Ai / (theta'*Bi*theta) + (theta'*Ai*theta) / (theta'*Bi*theta)^2 * Bi;
        X = X + Xi;
    end
    
    if 0
        Q = X;
    else
        T = 2 / (theta'*Bi*theta)^2 * (Ai*(theta*theta')*Bi + Bi*(theta*theta')*Ai - 2 * (theta'*Ai*theta) / (theta'*Bi*theta) * Bi*(theta*theta')*Bi);
        Ht = 2 * (X - T);
        
        At = Pt * Ht * (2*(theta*theta') - norm(theta)^2 * eye(10,10));
        Bt = norm(theta)^2 / norm(at)^2;
        Ct = 0;
        
        Z = At + Bt + Ct;
        Q = Z'*Z;
    end

    [Theta,Lambda] = eig(X);
    [~,ix] = min(abs(diag(Lambda)));  % eigenvalue closest to zero in absolute value
    theta = Theta(:,ix);
    [~,j] = max(abs(theta));  % index of maximum absolute value component
    theta = theta * sign(theta(j));
end