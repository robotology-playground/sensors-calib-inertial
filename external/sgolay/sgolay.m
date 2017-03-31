function [B,G] = sgolay(k,F,varargin)
%SGOLAY Savitzky-Golay Filter Design.
%   B = SGOLAY(K,F) designs a Savitzky-Golay (polynomial) FIR smoothing
%   filter B.  The polynomial order, K, must be less than the frame size,
%   F, and F must be odd.  
%
%   Note that if the polynomial order K equals F-1, no smoothing
%   will occur.
%
%   SGOLAY(K,F,W) specifies a weighting vector W with length F
%   containing real, positive valued weights employed during the
%   least-squares minimization.
%
%   [B,G] = SGOLAY(...) returns the matrix G of differentiation filters.
%   Each column of G is a differentiation filter for derivatives of order
%   P-1 where P is the column index.  Given a length F signal X, an
%   estimate of the P-th order derivative of its middle value can be found
%   from:
%
%                     ^(P)
%                     X((F+1)/2) = P!*G(:,P+1)'*X
%
%   See also SGOLAYFILT, FIR1, FIRLS, FILTER
 
%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8
 
%   Author(s): R. Losada
%   Copyright 1988-2011 The MathWorks, Inc.
%     
 
narginchk(2,3);
 
% Check if the input arguments are valid
if round(F) ~= F, error(message('signal:sgolay:FrameMustBeInteger')), end
if rem(F,2) ~= 1, error(message('signal:sgolay:InvalidDimensions')), end
if round(k) ~= k, error(message('signal:sgolay:DegreeMustBeInteger')), end
if k > F-1, error(message('signal:sgolay:DegreeGeLength')), end
if nargin < 3,
   % No weighting matrix, make W an identity
   W = eye(F);
else
   W = varargin{1};
   % Check W is real.
   if ~isreal(W), error(message('signal:sgolay:NotReal')),end
   % Check for right length of W
   if length(W) ~= F, error(message('signal:sgolay:MismatchedDimensions')),end
   % Check to see if all elements are positive
   if min(W) <= 0, error(message('signal:sgolay:WVMustBePos')), end
   % Diagonalize the vector to form the weighting matrix
   W = diag(W);
end
 
% Compute the projection matrix B
s = fliplr(vander(-(F-1)/2:(F-1)/2));
S = s(:,1:k+1);   % Compute the Vandermonde matrix
 
[Q,R] = qr(sqrt(W)*S,0); %#ok
 
G = S*inv(R)*inv(R)'; % Find the matrix of differentiators
 
B = G*S'*W; 
 
 
% [EOF] - sgolay.m
