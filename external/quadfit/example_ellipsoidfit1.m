function example_ellipsoidfit1
% Demonstration of various ellipsoid fits.

% Copyright 2011-2012 Levente Hunyadi

[x,y,z,x0,y0,z0] = example_ellipsoid_partial();
%[x,y,z,x0,y0,z0] = example_ellipsoid();

hold on;
plot3(x,y,z,'k.');
xlabel('x');
ylabel('y');
zlabel('z');
%plot3(x0,y0,z0,'r.');
hold off;

if 0
    p_taubin = ellipsoidfit_taubin(x,y,z);
    plot_ellipsoid_im(p_taubin,'EdgeColor','blue');
    err = ellipsoidfit_error(x0,y0,z0,p_taubin);
end

if 0
    p_direct = ellipsoidfit_direct(x,y,z);
    plot_ellipsoid_im(p_direct,'EdgeColor','blue');
    err = ellipsoidfit_error(x0,y0,z0,p_direct);
end

if 0
    p_aml = ellipsoidfit_aml(x,y,z);
    plot_ellipsoid_im(p_aml,'EdgeColor','green');
    err = ellipsoidfit_error(x0,y0,z0,p_aml);
end

if 1
    p_koopmans = ellipsoidfit_koopmans(x,y,z);
    plot_ellipsoid_im(p_koopmans,'EdgeColor','blue');
    err = ellipsoidfit_error(x0,y0,z0,p_koopmans);
end

if 1
    p_ml = ellipsoidfit(x,y,z);
    plot_ellipsoid_im(p_ml,x,y,z);
    err = ellipsoidfit_error(x0,y0,z0,p_ml);
end

ellipsoid_projections(x,y,z,p_ml,p_direct,p_koopmans);

function e = ellipsoidfit_error(x0,y0,z0,p)

[center,radii,~,R] = ellipsoid_im2ex(p);
[xp,yp,zp] = ellipsoidfit_residuals(x0,y0,z0,center,radii,R);
e = mean((xp-x0).^2+(yp-y0).^2+(zp-z0).^2);

function [x,y,z,x0,y0,z0] = example_ellipsoid_partial
% A sample ellipsoid.

% generate points
xc = 10;
yc = 20;
zc = 10;
%xc = 0; yc = 0; zc = 0;
%xr = 5;
xr = 15;
yr = 25;
zr = 20;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr,50);
x0 = x0(:);
y0 = y0(:);
z0 = z0(:);

% rotate points
Q = [ 0.36, 0.48, -0.8 ; -0.8, 0.60, 0 ; 0.48, 0.64, 0.60 ];
%Q = eye(3,3);
[x0,y0,z0] = rot3d(x0,y0,z0,Q);

% add noise
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + randn(size(x0));
y = y0 + randn(size(y0));
z = z0 + randn(size(z0));

sx = 10; sy = 5; sz = 0;
f = (x-sx).^2 + (y-sy).^2 + (z-sz).^2 < 500;

x0 = x0(f);
y0 = y0(f);
z0 = z0(f);

x = x(f);
y = y(f);
z = z(f);
%plot3(x,y,z,'.'); return;

if nargout < 3
    hold all;
    %plot3(x,y,z,'.');
    ellipsoidfit(x,y,z);
    hold off;
end
