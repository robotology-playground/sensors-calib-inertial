function [phi,theta,psi] = rot2ang(A)
% Convert rotation matrix to Euler angles.
% Euler angles use the x-convention, i.e. phi, theta and psi are taken around the Z, X
% and again the Z-axis.
%
% See also: ang2rot

% Copyright 2011 Levente Hunyadi

validateattributes(A, {'numeric'}, {'2d','real','size',[3,3]});

a = atan2(A(3,1), A(3,2));
b = acos(A(3,3));
c = -atan2(A(1,3), A(2,3));
if nargout > 1
    nargoutchk(3, 3);
    phi = a;
    theta = b;
    psi = c;
else
    nargoutchk(1, 1);
    phi = [a ; b ; c];
end