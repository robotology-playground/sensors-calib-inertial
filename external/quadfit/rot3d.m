function [x,y,z] = rot3d(x,y,z,Q)
% Rotate points in three dimensions.
%
% Input arguments:
% x, y, z:
%    coordinates of data points to rotate
% Q:
%    the rotation matrix to subject data points to

% Copyright 2011-2012 Levente Hunyadi

X = [x,y,z];
X = X*Q;
x = X(:,1);
y = X(:,2);
z = X(:,3);