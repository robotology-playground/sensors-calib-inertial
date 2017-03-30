function p = ellipsoidfit_direct(x,y,z)
% Direct least squares fitting of ellipsoids under the constraint 4J - I^2 > 0.
% The constraint confines the class of ellipsoids to fit to those whose smallest radius
% is at least half of the largest radius.
%
% Input arguments:
% x,y,z;
%    x, y and z coodinates of 3D points
%
% Output arguments:
% p:
%    a 10-parameter vector of the algebraic ellipsoid fit
%
% References:
% Qingde Li and John G. Griffiths, "Least Squares Ellipsoid Specific Fitting",
%    Proceedings of the Geometric Modeling and Processing, 2004.

% Copyright 2011 Levente Hunyadi

narginchk(3,3);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
z = z(:);

% build design matrix
D = [ x.^2, y.^2, z.^2, 2*y.*z, 2*x.*z, 2*x.*y, 2*x, 2*y, 2*z, ones(numel(x),1) ];

% build scatter matrix
S = D'*D;

% build 10x10 constraint matrix
k = 4;  % to ensure that the parameter vector always defines an ellipse
C1 = [ 0 k k ; k 0 k ; k k 0 ] / 2 - 1;
C2 = -k * eye(3,3);
C3 = zeros(4,4);

method = 'evd';
switch method
    case 'evd'
        C = blkdiag(C1,C2,C3);

        % solve eigensystem
        [gevec, geval] = eig(S,C);
        geval = diag(geval);

        % extract eigenvector corresponding to the unique positive eigenvalue
        flt = geval > 0 & ~isinf(geval);
        switch nnz(flt)
            case 0
                % degenerate case; single positive eigenvalue becomes near-zero negative eigenvalue
                % due to round-off error
                [~,ix] = min(abs(geval));
                v = gevec(:,ix);
            case 1
                % regular case
                v = gevec(:,flt);
            otherwise
                % degenerate case; several positive eigenvalues appear
                [~,ix] = min(abs(geval));
                v = gevec(:,ix);
        end
    case 'evdinv'
        C = blkdiag(C1,C2);

        % solve generalized eigensystem
        S11 = S(1:6,1:6);
        S12 = S(1:6,7:10);
        S22 = S(7:10,7:10);

        % extract eigenvector corresponding to the unique positive eigenvalue
        [gevec, geval] = eig(S11-S12/S22*S12', C);
        geval = diag(geval);

        % compute parameters
        v1 = gevec(:, geval > 0 & ~isinf(geval)); 
        v2 = -S22\S12'*v1;
        v = [v1; v2];
    case 'svd'
        C = blkdiag(C1,C2,C3);
        [CV,CD] = eig(C);

        CC = sqrt(CD)*CV';  % complex result
        v = gsvd_min(D,CC);
        v = real(v);  % discard imaginary part with small magnitude
end

p = zeros(size(v));
p(1:3) = v(1:3);
p(4:6) = 2*v(6:-1:4);  % exchange order of y*z, x*z, x*y to x*y, x*z, y*z
p(7:9) = 2*v(7:9);
p(10) = v(10);

if nargout == 0
    hold on;
    plot3(x,y,z,'.');
    axis equal;
    plot_ellipsoid_im(p,x,y,z);
    hold off;
end
