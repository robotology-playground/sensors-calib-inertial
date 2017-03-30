function example_ellipsefit1
% Demonstration of various ellipse (and general quadratic curve) fits.

% Copyright 2011 Levente Hunyadi

%% Various ellipse fits to few data points
x = [1 2 5 7 9 3 6 8];
y = [7 6 8 7 5 7 2 4];

p1 = ellipsefit(x,y);
p2 = quad2dfit_taubin(x,y);
p3 = ellipsefit_direct(x,y);

figure;
hold all;
plot(x,y,'.', 'MarkerSize', 18);
%imconic(ellipse_ex2im([2.6996, 3.8160, 6.5187, 3.0319, 0.3596]));
line = imconic(p1);
set(line, 'LineStyle', '-', 'LineWidth', 2);
line = imconic(p2);
set(line, 'LineStyle', '--', 'LineWidth', 2);
line = imconic(p3);
set(line, 'Color', 'k', 'LineStyle', ':', 'LineWidth', 2);
hold off;

%% Maximum likelihood estimation with foot points
x = [1;2;5;7;9;3;6;8];
y = [7;6;8;7;5;7;2;4];

figure;
ellipsefit_foot(x,y);
axis equal;

%% Iterations of maximum likelihood estimation of ellipse
x = [1 2 5 7 9 3 6 8];
y = [7 6 8 7 5 7 2 4];

figure;
hold on;
plot(x,y,'k.', ...
    'MarkerSize', 18);
ellipsefit(x,y, ...
    'Method', 'kepler', ...
    'OutputFcn', @example_plot);
hold off;

%% Various ellipse fits to many data points
N = 75;  % sample count
sigma_x = 1;
sigma_y = 1;

% generate data points
[x0,y0] = ellipse(N, 2, 3, 4, 2, pi/6);

% pollute with noise
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(x0));

p1 = ellipsefit(x,y);
p2 = quad2dfit_taubin(x,y);
p3 = ellipsefit_direct(x,y);
p4 = ellipsefit_koopmans(x,y,sigma_x,sigma_y);
p5 = quad2dfit_cals(x,y);

figure;
hold all;
plot(x,y,'k.')
imconic(p1);
line = imconic(p2);
setlinestyle(line, '--');
line = imconic(p3);
setlinestyle(line, ':');
line = imconic(p4);
setlinestyle(line, '-.');
line = imconic(p4);
setlinestyle(line, '-.');
legend('Data','ML','Taubin','Direct','Koopmans','CALS');
hold off;

function setlinestyle(line, style)

set(findobj(line, '-property', 'LineStyle'), 'LineStyle', style);

function stop = example_plot(theta,~,state)

stop = false;
p = ellipse_kepler2im(theta);
switch state
    case 'init'
    case 'iter'
        line = imconic(p);
        set(line, 'LineStyle', ':', 'LineWidth', 2);
    case 'done'
        line = imconic(p);
        set(line, 'Color', 'black');
end