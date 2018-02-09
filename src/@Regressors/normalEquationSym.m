function theta = normalEquationSym( x,y )
%NORMALEQUATION Computes the closed-form solution to linear regression 
%   using the normal equations.

% checks...
if size(x,1) ~= size(y,1) || size(y,2) ~= 1
    error('Badly formatted data!!');
end

% format X adding the column of ones
X = [ones(size(x,1),1) x];

% process positive velocities model
theta = pinv(X'*X)*X'*y;

end
