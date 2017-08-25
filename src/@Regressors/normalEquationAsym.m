function [ thetaPos,thetaNeg ] = normalEquationAsym( x,y )
%NORMALEQUATION Computes the closed-form solution to linear regression 
%   using the normal equations.

% checks...
if size(x,1) ~= size(y,1) || size(y,2) ~= 1
    error('Badly formatted data!!');
end

% format X adding the column of ones
X = [ones(size(x,1),1) x];

% process positive velocities model
Xpos = X(X(:,2)>=0,:);
ypos = y(X(:,2)>=0);
thetaPos = pinv(Xpos'*Xpos)*Xpos'*ypos;

% process negative velocities model
Xneg = X(X(:,2)<0,:);
yneg = y(X(:,2)<0);
thetaNeg = pinv(Xneg'*Xneg)*Xneg'*yneg;

end
