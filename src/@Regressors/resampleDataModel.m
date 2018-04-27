function [ xs,ys ] = resampleDataModel( model,x,nSamples )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% resample x evenly over its respective limits
xs = linspace(min(x),max(x),nSamples)';
% process model
ys = arrayfun(@(aX) model.h(aX),xs);

end
