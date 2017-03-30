function [p,p0,mu0] = ellipsoidfit_koopmans(varargin)
% Fit an ellipsoid to data using the nonlinear Koopmans method.
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
% Qingde Li and John G. Griffiths, "Least Squares Ellipsoid Specific Fitting",
%    Proceedings of the Geometric Modeling and Processing, 2004.

% Copyright 2012 Levente Hunyadi

[x,y,z,sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk(mfilename, varargin{:});

% build sample data covariance matrix
Z = [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, ones(numel(x),1)];
%Z = [x.^2, y.^2, z.^2, 2*x.*y, 2*x.*z, 2*y.*z, 2*x, 2*y, 2*z, ones(numel(x),1)];
D = (Z'*Z) / size(Z,1);

% build noise covariance matrix
C = quad3dcovpoly(sigma_x, sigma_y, sigma_z, x, y, z);

% solve quadratic eigenvalue problem (QEP) for noise magnitude given no model constraints
if 1
    [V,e] = qep(-C(:,:,3), -C(:,:,2), D-C(:,:,1));  % data and noise covariance matrices
else
    T = -C;
    T(:,:,1) = D;
    [V,e] = mpolyeig(T);
end

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
if 1
    R = D-C(:,:,1) - mu0*C(:,:,2) - mu0^2*C(:,:,3);
else
    R = mpolyval(T, mu0);
end

% fit ellipsoid with bisection search on k in the expression k*J - I^2 > 0
p = ellipsoidfit_iterative(@ellipsoidfit_sufficient, R);

function [X,e] = qep(M, C, K)
% Solves a quadratic eigenvalue problem.

validateattributes(M, {'numeric'}, {'2d','real','nonempty'});
validateattributes(C, {'numeric'}, {'2d','real','nonempty'});
validateattributes(K, {'numeric'}, {'2d','real','nonempty'});
[~,n] = size(M);
validateattributes(M, {'numeric'}, {'size',[n,n]});
validateattributes(C, {'numeric'}, {'size',[n,n]});
validateattributes(K, {'numeric'}, {'size',[n,n]});

if is_nonsingular(K)  % K is nonsingular (but M is not necessarily)
    swap = false;
    A2 = M;  % quadratic term
    A1 = C;  % linear term
    A0 = K;  % constant term
elseif is_nonsingular(M)  % M is nonsingular (but K is not necessarily)
    swap = true;  % exchange order of terms (solve inverse eigenvalue problem)
    A0 = M;
    A1 = C;
    A2 = K;
end

if nargout > 1
    [X,e] = quadratic_eigenvalue_problem(A2, A1, A0);
else
    e = quadratic_eigenvalue_problem(A2, A1, A0);
end
if swap
    e = 1 ./ e;
end
if nargout < 2
    X = e;
end

function [X,e] = quadratic_eigenvalue_problem(M, C, K)

[~,n] = size(K);
Z = zeros(n,n);
if is_nonsingular(K)
    W = -K;
else
    W = eye(n,n);
end

% build large matrix pair
A = [ Z, W ; -K, -C ];
B = [ W, Z ; Z, M ];
if nargout < 2
    X = eig(A, B);  % preferably a symmetric pair of matrices
else
    [X,E] = eig(A,B);
    e = diag(E);

    % for each eigenvalue, extract the eigenvector from whichever portion
    % of the big eigenvector matrix X gives the smallest normalized residual
    V = zeros(n,2);
    for j = 1 : 2*n
       V(:) = X(:,j);
       R = M;
       if ~isinf(e(j))
           R = C + e(j)*R;
           R = K + e(j)*R;
       end
       R = R * V;
       res = sum(abs(R)) ./ sum(abs(V));  % normalized residuals
       [~,ind] = min(res);
       X(1:n,j) = V(:,ind) / norm(V(:,ind));  % eigenvector with unit 2-norm
    end
    X = X(1:n,:);
end

function tf = is_nonsingular(A)

tf = rank(A) == min(size(A));

function p = ellipsoidfit_sufficient(R, k)
% Fits an ellipsoid with the sufficient invariant constraint k*J - I^2 > 0.
% In the constraint k*J - I^2 > 0, we have
% I = a + b + c
% J = ab + bc + ac - f^2 - g^2 - h^2

% build 10x10 constraint matrix
Q1 = [ 0 k k ; k 0 k ; k k 0 ] / 2 - 1;
Q2 = -k/4 * eye(3,3);  % for [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, 1]
%Q2 = -k * eye(3,3);  % for [x.^2, y.^2, z.^2, 2*x.*y, 2*x.*z, 2*y.*z, 2*x, 2*y, 2*z, 1]
Q3 = zeros(4,4);
Q = blkdiag(Q1,Q2,Q3);

% enforce constraint
p = ellipsoidfit_robust(R, Q);  % parameter estimates taking constraints into account
%p = [p(1);p(2);p(3);2*p(4);2*p(5);2*p(6);2*p(7);2*p(8);2*p(9);p(10)];  % for [x.^2, y.^2, z.^2, 2*x.*y, 2*x.*z, 2*y.*z, 2*x, 2*y, 2*z, 1]

function p = ellipsoidfit_robust(R, Q)
% Constrained fit by solving a modified eigenvalue problem.

% check that constraint matrix has all zeros except in upper left block
assert( nnz(Q(7:10,:)) == 0 );
assert( nnz(Q(:,7:10)) == 0 );

S1 = R(1:6,1:6);     % quadratic part of the scatter matrix
S2 = R(1:6,7:10);    % combined part of the scatter matrix
S3 = R(7:10,7:10);   % linear part of the scatter matrix
T = -(S3 \ S2');     % for getting a2 from a1
M = S1 + S2 * T;     % reduced scatter matrix
M = Q(1:6,1:6) \ M;  % premultiply by inv(C1)
[evec,~] = eig(M);   % solve eigensystem

% evaluate a'*C*a
cond = zeros(1,size(evec,2));
for k = 1 : numel(cond)
    cond(k) = evec(:,k)'*Q(1:6,1:6)*evec(:,k);
end

p1 = evec(:,cond > 0);  % eigenvector for minimum positive eigenvalue
p = [p1 ; T * p1];  % ellipse coefficients
