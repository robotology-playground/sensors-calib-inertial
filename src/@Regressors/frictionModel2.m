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
tunedAlpha = 1;

for iter = 1:10
    % define the model function for dq>0
    Mpos = @(dq,sgn,alpha) repmat(1/2*(1+sgn(dq)),[1 4]).*[1-exp(-alpha*dq) dq exp(-alpha*dq) zeros(size(dq))];
    % define the model function for dq<0
    Mneg = @(dq,sgn,alpha) repmat(1/2*(1+sgn(dq)),[1 4]).*[1-exp(-alpha*dq) dq zeros(size(dq)) exp(-alpha*dq)];
    % define the model function for the full range of dq [-inf,+inf]
    fullRangeM = @(dq) Mpos(dq,@sign,tunedAlpha) - Mneg(-dq,@sign,tunedAlpha);
    X = fullRangeM(x);
    
    % fit the model with a least-square linear and constrained optimization
    model.theta = pinv(X)*y;
%     model.theta = lsqlin(X,y,eye(4),zeros(4,1));
    % re-evaluate alpha
    prevTunedAlpha = tunedAlpha;
    if((model.theta(1)-model.theta(3))~=0)
        % compute alpha such that dy/dx=0 at x=0
        tunedAlpha = -model.theta(2)/(model.theta(1)-model.theta(3));
    end
    % stop condition: tunedAlpha converged
    if(abs(tunedAlpha-prevTunedAlpha)<abs(tunedAlpha)/10)
        break;
    end
end

model.h = @(vecX) fullRangeM(vecX) * model.theta;
model.alpha = prevTunedAlpha;
model.iterConverge = iter;

end

%% Local functions

function signVec = signExc0(aX)
% sign(x)=1 if x==0
signVec = sign(aX);
signVec(aX==0) = -1;

end
