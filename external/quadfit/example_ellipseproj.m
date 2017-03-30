function example_ellipseproj
% Demonstration of projecting points to an ellipse.

% Copyright 2013 Levente Hunyadi

N = 100000;  % sample count
sigma_x = 0.1;
sigma_y = 0.1;
cx = 12;
cy = 13;
a = 4;
b = 2;
%cx = 0; cy = 0; a = 1; b = 1;
phi = pi/6;
[x0,y0] = ellipse(N, cx, cy, a, b, phi);

RandStream.setGlobalStream(RandStream('mt19937ar','seed',9999));
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(y0));

tic
Xp = quad2dproj([x,y],[cx,cy],[a,b],phi);
xp = Xp(:,1);
yp = Xp(:,2);
toc

plot(xp,yp,'b.');
plot(x,y,'k.');

p = ellipse_ex2im(cx,cy,a,b,phi);
imconic(p);
