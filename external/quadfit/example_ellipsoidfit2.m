function example_ellipsoidfit2
% Demonstration of fits to various special ellipsoids.

% Copyright 2013 Levente Hunyadi

if 1
    [x,y,z] = example_ellipsoid_long_thin;
    plot_ellipsoid_fit(x,y,z,[-72 -118 62]);
    set(gcf,'Name','Long thin ellipsoid');
end

if 1
    [x,y,z] = example_ellipsoid_short_fat;
    plot_ellipsoid_fit(x,y,z,[-72 -118 62]);
    set(gcf,'Name','Short fat ellipsoid');
end

if 1
    [x,y,z] = example_ellipsoid_band;
    plot_ellipsoid_fit(x,y,z,[-72 -118 62]);
    %[x,y,z,x0,y0,z0] = example_ellipsoid_band;
    %plot_ellipsoid_fit(x,y,z,x0,y0,z0,[-72 -118 62]);
    set(gcf,'Name','Ellipsoid band');
end

function plot_ellipsoid_fit(varargin)

narginchk(3,7);
switch nargin
    case 3
        [x,y,z] = varargin{:};
        x0 = []; y0 = []; z0 = [];
    case 4
        [x,y,z,cp] = varargin{:};
        x0 = []; y0 = []; z0 = [];
    case 6
        [x,y,z,x0,y0,z0] = varargin{:};
    case 7
        [x,y,z,x0,y0,z0,cp] = varargin{:};
    otherwise  % impossible combination
        narginchk(4,4);
end

figure;
hold on;
plot3(x,y,z,'k.');
xlabel('x');
ylabel('y');
zlabel('z');
%plot3(x0,y0,z0,'r.');
hold off;

if 0
    p_direct = ellipsoidfit_direct(x,y,z);
    plot_ellipsoid_im(p_direct,'EdgeColor','blue');
end

if 1
    p_koopmans = ellipsoidfit_koopmans(x,y,z);
    plot_ellipsoid_im(p_koopmans,'EdgeColor','red');
end

if ~isempty(x0) && ~isempty(y0) && ~isempty(z0)
    p_ml = ellipsoidfit(x0,y0,z0);
    %plot_ellipsoid_im(p_ml,x0,y0,z0);
    plot_ellipsoid_im(p_ml);
end

campos(cp);
axis equal;

function [x,y,z,x0,y0,z0] = example_ellipsoid_long_thin
% A long thin ellipsoid.

% generate points
xc = 0; yc = 0; zc = 0;
xr = 10;
yr = 2;
zr = 1;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr,50);
x0 = x0(:); y0 = y0(:); z0 = z0(:);

% filter points
f = x0 < -5;
x0 = x0(f); y0 = y0(f); z0 = z0(f);

% add noise
mu = 0.05;
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + mu*randn(size(x0));
y = y0 + mu*randn(size(y0));
z = z0 + mu*randn(size(z0));

if nargout < 3
    hold all;
    %plot3(x,y,z,'.');
    ellipsoidfit(x,y,z);
    hold off;
end

function [x,y,z,x0,y0,z0] = example_ellipsoid_short_fat
% A compressed (short fat) ellipsoid.

% generate points
xc = 0; yc = 0; zc = 0;
xr = 10;
yr = 8;
zr = 1.5;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr,50);
x0 = x0(:); y0 = y0(:); z0 = z0(:);

% filter points
f = x0 < -5;
x0 = x0(f); y0 = y0(f); z0 = z0(f);

% add noise
mu = 0.05;
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + mu*randn(size(x0));
y = y0 + mu*randn(size(y0));
z = z0 + mu*randn(size(z0));

if nargout < 3
    hold all;
    %plot3(x,y,z,'.');
    ellipsoidfit(x,y,z);
    hold off;
end

function [x,y,z,x0,y0,z0] = example_ellipsoid_band
% Points sampled in a band along an ellipsoid.

% generate points
xc = 0; yc = 0; zc = 0;
xr = 20;
yr = 10;
zr = 5;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr,50);
x0 = x0(:); y0 = y0(:); z0 = z0(:);

% filter points
f = x0 > -10 & x0 < 0;
x0 = x0(f); y0 = y0(f); z0 = z0(f);

% add noise
mu = 0.25;
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + mu*randn(size(x0));
y = y0 + mu*randn(size(y0));
z = z0 + mu*randn(size(z0));

if nargout < 3
    hold all;
    %plot3(x,y,z,'.');
    ellipsoidfit(x,y,z);
    hold off;
end
