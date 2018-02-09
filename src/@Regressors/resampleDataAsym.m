function [ xs,ys ] = resampleDataAsym( thetaPos,thetaNeg,x,nSamples )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% resample x evenly over its respective limits
xs = linspace(min(x),max(x),nSamples)';
% format X adding the column of ones
Xs = [ones(length(xs),1) xs];
ys = zeros(length(xs),1);

% process positive velocities model
Xpos = Xs(Xs(:,2)>=0,:);
ys(Xs(:,2)>=0) = Xpos*thetaPos;

% process negative velocities model
Xneg = Xs(Xs(:,2)<0,:);
ys(Xs(:,2)<0) = Xneg*thetaNeg;

end

