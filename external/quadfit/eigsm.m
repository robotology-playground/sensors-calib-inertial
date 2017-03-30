function [V,E] = eigsm(A,B)
% Smallest eigenvalue with real eigenvector.

% Copyright 2008-2009 Levente Hunyadi

if nargin > 1
    [V,D] = eig(A,B);
else
    [V,D] = eig(A);
end
e = diag(D);

% find those eigenvalues whose eigenvector is real
ix = all(imag(V) < eps, 1);
e = e(ix);
V = V(:,ix);

% find eigenvalue with smallest magnitude
[~,ix] = sort(abs(e));
e = e(ix(1));

if nargout > 1
    E = e;
    V = V(:, ix(1));  % eigenvector corresponding to smallest magnitude eigenvalue
else
    V = e;
end
