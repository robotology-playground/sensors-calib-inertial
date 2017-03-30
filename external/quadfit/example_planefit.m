function example_planefit
% Demonstration of plane fitting.

% Copyright 2011 Levente Hunyadi

x0 = 4*rand(1,100);
y0 = 4*rand(size(x0));
z0 = 2 * x0 - 3 * y0 + 15;

x = x0 + 0.1*randn(size(x0));
y = y0 + 0.1*randn(size(y0));
z = z0 + 0.1*randn(size(z0));

[~,~,xf,yf,zf] = planefit(x,y,z);

hold all;
plot3(x0,y0,z0,'.');
plot3(x,y,z,'.');
plotconvhull(x0,y0,z0);
plotconvhull(xf,yf,zf);
hold off;