function example_spherefit
% Demonstration of least-squares sphere fit.

% Copyright 2011 Levente Hunyadi

example_sphere;

function [x,y,z,x0,y0,z0] = example_sphere
% A sample sphere.

% generate points
xc = 10;
yc = 20;
zc = 10;
%xc = 0; yc = 0; zc = 0;
r = 30;
[x0,y0,z0] = ellipsoid(xc,yc,zc,r,r,r);
x0 = x0(:);
y0 = y0(:);
z0 = z0(:);

% add noise
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + randn(size(x0));
y = y0 + randn(size(y0));
z = z0 + randn(size(z0));
%plot3(x,y,z,'.'); return;

ix = x > 0 & y > 0 & z > 0;
x = x(ix);
y = y(ix);
z = z(ix);

if nargout < 3
    hold all;
    axis equal;
    plot3(x,y,z,'.');
    [center,radius] = spherefit(x,y,z);
    plot_sphere_part(6,radius,center,x,y,z);
   	%sphere_gd(6,radius,center);
    hold off;
end