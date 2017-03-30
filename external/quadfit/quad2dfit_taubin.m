function p = quad2dfit_taubin(x,y)
% General quadratic curve fit with Taubin's method.
%
% Input arguments:
% x,y;
%    x and y coodinates of 2D points
%
% Output arguments:
% p:
%    a 6-parameter vector of the algebraic quadratic curve fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% G. Taubin, "Estimation of Planar Curves, Surfaces and Nonplanar Space Curves Defined
%    by Implicit Equations, with Applications to Edge and Range Image Segmentation",
%    IEEE Trans. PAMI, Vol. 13, 1991, pp1115-1138.

% Copyright 2011 Levente Hunyadi

narginchk(2,2);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
XY = [x,y];

% Copyright (c) 2009, Nikolai Chernov
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the University of Alabama at Birmingham nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

centroid = mean(XY);   % the centroid of the data set

Z = [(XY(:,1)-centroid(1)).^2, (XY(:,1)-centroid(1)).*(XY(:,2)-centroid(2)),...
     (XY(:,2)-centroid(2)).^2, XY(:,1)-centroid(1), XY(:,2)-centroid(2), ones(size(XY,1),1)];
M = Z'*Z/size(XY,1);

P = [M(1,1)-M(1,6)^2, M(1,2)-M(1,6)*M(2,6), M(1,3)-M(1,6)*M(3,6), M(1,4), M(1,5);
     M(1,2)-M(1,6)*M(2,6), M(2,2)-M(2,6)^2, M(2,3)-M(2,6)*M(3,6), M(2,4), M(2,5);
     M(1,3)-M(1,6)*M(3,6), M(2,3)-M(2,6)*M(3,6), M(3,3)-M(3,6)^2, M(3,4), M(3,5);
     M(1,4), M(2,4), M(3,4), M(4,4), M(4,5);
     M(1,5), M(2,5), M(3,5), M(4,5), M(5,5)];

Q = [4*M(1,6), 2*M(2,6), 0, 0, 0;
     2*M(2,6), M(1,6)+M(3,6), 2*M(2,6), 0, 0;
     0, 2*M(2,6), 4*M(3,6), 0, 0;
     0, 0, 0, 1, 0;
     0, 0, 0, 0, 1];

[V,D] = eig(P,Q);

[~,ID] = sort(diag(D));

A = V(:,ID(1));
A = [A; -A(1:3)'*M(1:3,6)];
A4 = A(4)-2*A(1)*centroid(1)-A(2)*centroid(2);
A5 = A(5)-2*A(3)*centroid(2)-A(2)*centroid(1);
A6 = A(6)+A(1)*centroid(1)^2+A(3)*centroid(2)^2+...
     A(2)*centroid(1)*centroid(2)-A(4)*centroid(1)-A(5)*centroid(2);
A(4) = A4;  A(5) = A5;  A(6) = A6;
p = A/norm(A);