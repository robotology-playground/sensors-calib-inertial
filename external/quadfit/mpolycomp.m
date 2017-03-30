function [A,B] = mpolycomp(T)
% Matrix polynomial companion form.
% Builds two p*n-by-p*n matrices such that
% A = [T0   0   0   0]   B = [-T1 -T2 -T3 -T4]
%     [ 0   I   0   0]       [  I   0   0   0]
%     [ 0   0   I   0]       [  0   I   0   0]
%     [ 0   0   0   I]       [  0   0   I   0]
%
% See also: polyeig, eig

% Copyright 2008-2009 Levente Hunyadi

[~,p,n] = size(T);
n = n - 1;
A = eye(p*n,p*n);
A(1:p,1:p) = T(:,:,1);
if n > 0
    B = diag(ones(p*(n-1),1), -p);
    k = 1:p;
    for i = 2 : n+1
        B(1:p,k) = -T(:,:,i);  % T_1, T_2, etc.
        k = k+p;
    end
elseif nargout > 1
    B = eye(p,p);
end