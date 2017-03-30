function q = rot2quat(A)
% Convert rotation matrix to quaternion.
%
% Input arguments:
% R:
%    a rotation matrix (i.e. an orthogonal matrix with determinant 1)
%
% Output arguments:
% q:
%    the rotation as a quaternion where the last entry is the "scalar term"

% Copyright 2011 Levente Hunyadi

validateattributes(A, {'numeric'}, {'2d','real','size',[3,3]});

[m,k] = min(abs([1 + A(1,1) - A(2,2) - A(3,3), 1 - A(1,1) + A(2,2) - A(3,3), 1 - A(1,1) - A(2,2) + A(3,3), 1 + A(1,1) + A(2,2) + A(3,3)]));
if m > 0  % not an identity rotation
    q = zeros(4,1);
    switch k
        case 1
            q(1) = 0.5 * sqrt(m);
            s = 0.25 / q(1);
            q(2) = s * (A(1,2) + A(2,1));
            q(3) = s * (A(1,3) + A(3,1));
            q(4) = s * (A(3,2) - A(2,3));
        case 2
            q(2) = 0.5 * sqrt(m);
            s = 0.25 / q(2);
            q(1) = s * (A(1,2) + A(2,1));
            q(3) = s * (A(2,3) + A(3,2));
            q(4) = s * (A(1,3) - A(3,1));
        case 3
            q(3) = 0.5 * sqrt(m);
            s = 0.25 / q(3);
            q(1) = s * (A(1,3) + A(3,1));
            q(2) = s * (A(2,3) + A(3,2));
            q(4) = s * (A(2,1) - A(1,2));
        case 4
            q(4) = 0.5 * sqrt(m);
            s = 0.25 / q(4);
            q(1) = s * (A(2,3) - A(3,2));
            q(2) = s * (A(3,1) - A(1,3));
            q(3) = s * (A(1,2) - A(2,1));
    end
else  % an identity rotation
    q = [0;0;0;1];
end