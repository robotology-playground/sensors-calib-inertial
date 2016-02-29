clear
close all
clc

%% test optimset and fminunc

c = 6;                              % define parameter first
options = optimset('GradObj','on'); % indicate gradient is provided 
[x, fval, exitFlag, output, grad] = fminunc(@(x) myfun(x,c),[0;0],options)

%% EXITFLAG:
%       1  Magnitude of gradient small enough. 
%       2  Change in X too small.
%       3  Change in objective function too small.
%       5  Cannot decrease function along search direction.
%       0  Too many function evaluations or iterations.
%      -1  Stopped by output/plot function.
%      -3  Problem seems unbounded. 

%% plt myfun
[X,Y] = meshgrid(-2:.2:2, -4:.4:4);
Z = c * X .* exp(-X.^2 - Y.^2);
surf(X,Y,Z)
hold;
plot3(x(1), x(2), fval, 'ro');
title('example');
