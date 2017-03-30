function [X,e] = mpolyeig(T, sigma)
% Eigenvalues and eigenvectors for matrix polynomial.
% If the original matrix polynomial coefficients are symmetric, the
% function uses a linearization that maintains symmetry thereby
% contributing to increased numerical accuracy.
%
% Input arguments:
% T:
%    a matrix polynomial as a 3D array
% sigma:
%    specifies which eigenvalues (and corresponding eigenvectors) to return
%
% Examples:
%    e = mpolyeig(T)       returns eigenvalues of the matrix polynomial T
%    [X,e] = mpolyeig(T)   returns eigenvalues and eigenvectors
%
% See also: mpolycomp, mpolycomps, polyeig

% Copyright 2008-2009 Levente Hunyadi

if nargin < 2
    sigma = [];
end

[~,n,p] = size(T);
validateattributes(T, {'numeric'}, {'nonempty','size',[n,n,p]});
p = p - 1;

[A,B] = mpolycomp(T);
if isempty(sigma)
    [X,E] = eig(A,B);
else
    switch sigma
        case 'sm'
            [X,E] = eigsm(A,B);
    end
end
e = diag(E);

if nargout > 1
    % for each eigenvalue, extract the eigenvector from whichever portion
    % of the big eigenvector matrix X gives the smallest normalized residual
    V = zeros(n,p);
    for j = 1 : size(X,2)  % p*n for sigma = all eigenvalues
       V(:) = X(:,j);
       R = T(:,:,p+1);
       if ~isinf(e(j))
           for k = p:-1:1
               R = T(:,:,k) + e(j) * R;
           end
       end
       R = R * V;
       res = sum(abs(R)) ./ sum(abs(V));  % normalized residuals
       [~,ix] = min(res);
       X(1:n,j) = V(:,ix) / norm(V(:,ix));  % eigenvector with unit 2-norm
    end
    X = X(1:n,:);
else
    X = e;
end
