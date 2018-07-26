function model = normalEquation( x,y )
%pwmModel1Sym Computes the closed-form solution to linear regression 
%   using the normal equations.
%   
%   \in x: column vector (function inputs)
%   \in y: column vector (measurements)
%   model.theta: fitted parametters
%   model.h: function handle, takes a column vector X as input

% checks...
if size(x,1) ~= size(y,1) || ~iscolumn(y)
    error('Badly formatted data!!');
end

% format X adding the column of ones
M = @(dq) [ones(size(dq)) dq];
X = M(x);

% process the model
model.theta = pinv(X'*X)*X'*y;
model.h = @(vecX) M(vecX(:)) * model.theta;

end
