function model = frictionModel1Sym( x,y )
%frictionModel1Sym Computes the closed-form solution to linear regression 
%   using the normal equations.
%   \in x: column vector (function inputs)
%   \in y: column vector (measurements)
%   model.theta: fitted parametters (Kc, Kv)
%   model.h: function handle, takes a column vector X as input

% checks...
if size(x,1) ~= size(y,1) || ~iscolumn(y)
    error('Badly formatted data!!');
end

% remove velocities too close to 0
filtIdxes = abs(x)>abs(max(x)/100);
y = y(filtIdxes);
x = x(filtIdxes);

% format X adding the column of sign(x)
M = @(dq) [sign(dq) dq];
X = M(x);

% process positive velocities model
model.theta = pinv(X'*X)*X'*y;
model.h = @(vecX) M(vecX(:)) * model.theta;

end

%% Local functions

function signVec = signExc0(aX)
% sign(x)=1 if x==0
signVec = sign(aX);
signVec(aX==0) = -1;

end
