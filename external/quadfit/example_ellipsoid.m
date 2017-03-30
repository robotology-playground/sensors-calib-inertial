function [x,y,z,x0,y0,z0] = example_ellipsoid
% A sample ellipsoid.

% Copyright 2011 Levente Hunyadi

% generate points
xc = 10;
yc = 20;
zc = 10;
%xc = 0; yc = 0; zc = 0;
xr = 30;
yr = 25;
zr = 20;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr);
x0 = x0(:);
y0 = y0(:);
z0 = z0(:);

% rotate points
Q = [ 0.36, 0.48, -0.8 ; -0.8, 0.60, 0 ; 0.48, 0.64, 0.60 ];
%Q = eye(3,3);
[x0,y0,z0] = ellipsoid_rotate(x0,y0,z0,Q);

% add noise
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + randn(size(x0));
y = y0 + randn(size(y0));
z = z0 + randn(size(z0));
%plot3(x,y,z,'.'); return;

if nargout < 3
    hold all;
    %plot3(x,y,z,'.');
    ellipsoidfit(x,y,z);
    hold off;
end

function [x,y,z] = ellipsoid_rotate(x,y,z,Q)

X = [x,y,z];
X = X*Q;
x = X(:,1);
y = X(:,2);
z = X(:,3);