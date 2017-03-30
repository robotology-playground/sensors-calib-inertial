function example_ellipsefitnoise
% Comparing ellipse fits under various noise conditions.
% Noise conditions include Gaussian normal noise and uniform noise.

% Copyright 2011 Levente Hunyadi

N = 875;  % sample count
sigma_x = 0.1;
sigma_y = 0.1;
cx = 12;
cy = 13;
a = 4;
b = 2;
phi = pi/6;
[x0,y0,nx0,ny0] = ellipse(N, cx, cy, a, b, phi); %#ok<NASGU,ASGLU>
%[x0,y0,nx0,ny0] = ellipse(N, 0, 0, 1, 1);

f = x0 < 12 & y0 < 12;
x0 = x0(f);
y0 = y0(f);

% parameters for original curve
p1 = ellipse_ex2im(cx,cy,a,b,phi);

% seed random number generator
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));

% normal noise
xn = x0 + sigma_x * randn(size(x0));
yn = y0 + sigma_y * randn(size(y0));

p2 = ellipsefit_direct(xn,yn);
p3 = quad2dfit_koopmans(xn,yn,sigma_x,sigma_y);

figure;
hold all;
plot(xn,yn,'k.');
xlim([8,13]);
ylim([10,13]);
h = imconic(p1);
set(h, 'LineStyle', '-', 'LineWidth', 2);
h = imconic(p2);
set(h, 'LineStyle', '--', 'LineWidth', 2);
h = imconic(p3);
set(h, 'LineStyle', '-.', 'LineWidth', 2);
legend('Data points with normal noise','Original curve','Direct fit with normal noise','Koopmans fit with normal noise');
hold off;

% uniform noise
xu = x0 + randuni(sigma_x, size(x0));
yu = y0 + randuni(sigma_y, size(y0));

p2 = ellipsefit_direct(xu,yu);
p3 = quad2dfit_koopmans(xu,yu,sigma_x,sigma_y);

figure;
hold all;
plot(xu,yu,'k.');
xlim([8,13]);
ylim([10,13]);
h = imconic(p1);
set(h, 'LineStyle', '-', 'LineWidth', 2);
h = imconic(p2);
set(h, 'LineStyle', '--', 'LineWidth', 2);
h = imconic(p3);
set(h, 'LineStyle', '-.', 'LineWidth', 2);
legend('Data points with uniform noise','Original curve','Direct fit with uniform noise','Koopmans fit with uniform noise');
hold off;

function r = randuni(sigma, varargin)
% Random numbers drawn from uniform distribution.

r = rand(varargin{:}) - 0.5;  % uniform distribution between -0.5 and 0.5
r = sigma/(0.5/sqrt(3)) * r;  % uniform distribution has sigma = 0.5/sqrt(3)