function example_quad2dcon
% Demonstration of constrained quadratic curve fitting.

% Copyright 2012 Levente Hunyadi

N = 175;  % sample count
sigma_x = 0.1;
sigma_y = 0.1;
%sigma_x = 1;
%sigma_y = 1;

% generate data points
%r = linspace(-0.75,0.25,N);
r = linspace(-1.5,2.0,N);
%r = linspace(-3.75,3.75,N);
a = 1;
b = 1;
x0 = a * cosh(r);
y0 = b * sinh(r);

% pollute with noise
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(x0));

fig = figure;
ax = axes('Parent', fig);
plot(ax,x,y,'k.');

C = blkdiag([ 0, 0, 2 ; 0, -1, 0 ; 2, 0, 0 ], zeros(3,3));

[pe,ph] = quad2dconfit_koopmans(x,y,sigma_x,sigma_y, C);
pp = parabolafit_direct(x,y);

hold on
imconic(ph, [], ax, 'LineStyle', '--', 'LineWidth', 2, 'Color', 'k');
imconic(pe, [], ax, 'LineStyle', '-.', 'LineWidth', 2, 'Color', 'b');
xbounds = [0 8];
ybounds = [-4 4];
h = ezplot(example_quad2dcon_parabola(pp), [xbounds ybounds]);
set(h, 'LineStyle', '-', 'LineWidth', 2, 'Color', 'r');
xlim(ax, xbounds);
ylim(ax, ybounds);
hold off

function fn = example_quad2dcon_parabola(p)

validateattributes(p, {'numeric'}, {'real','finite','vector','numel',6});
fn = @(x,y) p(1).*x.^2 + p(2).*x.*y + p(3).*y.^2 + p(4).*x + p(5).*y + p(6);
