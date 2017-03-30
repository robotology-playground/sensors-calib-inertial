function [center,radii,quat,R] = ellipsoid_im2ex(v)
% Cast ellipsoid defined with implicit parameter vector to explicit form.
% The implicit equation of a general ellipse is
% F(x,y,z) = Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz - 1 = 0
%
% Input arguments:
% v:
%    the 10 parameters describing the ellipsoid algebraically
% Output arguments:
% center:
%    ellispoid center coordinates [cx; cy; cz]
% ax:
%    ellipsoid semi-axes (radii) [a; b; c]
% quat:
%    ellipsoid rotation in quaternion representation
% R:
%    ellipsoid rotation (radii directions as rows of the 3x3 matrix)
%
% See also: ellipse_im2ex

% Copyright 2011 Levente Hunyadi

validateattributes(v, {'numeric'}, {'nonempty','real','vector'});

% eliminate times two from rotation and translation terms
v = v(:);
validateattributes(v, {'numeric'}, {'size',[10,1]});
v(4:9) = 0.5*v(4:9);

% find the algebraic form of the ellipsoid (quadratic form matrix)
Q = [ v(1) v(4) v(5) v(7); ...
      v(4) v(2) v(6) v(8); ...
      v(5) v(6) v(3) v(9); ...
      v(7) v(8) v(9) v(10) ];

% find the center of the ellipsoid
center = Q(1:3,1:3) \ -v(7:9);

if nargout > 1
    % form the corresponding translation matrix
    T = eye(4,4);
    T(4, 1:3) = center;

    % translate to the center
    S = T * Q * T';

    % check for positive definiteness
    [~,indef] = chol( -S(4,4)*S(1:3,1:3) );
    if indef > 0  % matrix is not positive definite
        error('ellipsoid_im2ex:InvalidArgumentValue', ...
            'Parameters do not define a real ellipse.');
    end
    
    % solve the eigenproblem
    [evecs, evals] = eig( S(1:3,1:3) );
    radii = realsqrt( -S(4,4) ./ diag(evals) );

    % convert rotation matrix to quaternion
    if nargout > 2
        quat = rot2quat(evecs);
        R = evecs';
    end
end