function resVec = residuals(thetaPos,thetaNeg,x,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% format X adding the column of ones
Xs = [ones(length(x),1) x];
ys = zeros(length(x),1);

% process positive velocities model
Xpos = Xs(Xs(:,2)>=0,:);
ys(Xs(:,2)>=0) = Xpos*thetaPos;

% process negative velocities model
Xneg = Xs(Xs(:,2)<0,:);
ys(Xs(:,2)<0) = Xneg*thetaNeg;

resVec = y-ys;

end
