function model = frictionModel2( x,y )
%frictionModel2 Computes the closed-form solution to linear regression 
%   using the normal equations.
%   \in x: column vector (function inputs)
%   \in y: column vector (measurements)
%   model.theta: fitted parametters (Kc, Kv, KsPos, KsNeg)
%   model.h: function handle, takes a column vector X as input

% checks...
if ~iscolumn(x) || ~iscolumn(y) || all(size(x)~=size(y))
    error('Badly formatted data!!');
end

% remove velocities too close to 0
filtIdxes = abs(x)>abs(max(x)/100);
y = y(filtIdxes);
x = x(filtIdxes);

% define the model function for dq>0
Mpos = @(dq,sgn) repmat(1/2*(1+sgn(dq)),[1 4]).*[1-exp(-dq) dq exp(-dq) zeros(size(dq))];
Mneg = @(dq,sgn) repmat(1/2*(1+sgn(dq)),[1 4]).*[1-exp(-dq) dq zeros(size(dq)) exp(-dq)];
% define the model function for the full range of dq [-inf,+inf]
fullRangeM = @(dq) Mpos(dq,@sign) - Mneg(-dq,@sign);
X = fullRangeM(x);

% process positive velocities model
model.theta = pinv(X'*X)*X'*y;
model.h = @(vecX) fullRangeM(vecX) * model.theta;

end

%% Local functions

function signVec = signExc0(aX)
% sign(x)=1 if x==0
signVec = sign(aX);
signVec(aX==0) = -1;

end
