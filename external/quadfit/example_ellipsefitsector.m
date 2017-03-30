function example_ellipsefitsector
% Ellipse fitting to data from a limited sector.

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
numel(x0)

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',9999));
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(y0));

p1 = ellipse_ex2im(cx,cy,a,b,phi);
p2 = ellipsefit_direct(x,y);
p3 = quad2dfit_hyperaccurate(x,y);
p4 = ellipsefit_koopmans(x,y,sigma_x,sigma_y);
%p4 = quad2dfit_koopmans(x,y,sigma_x,sigma_y);
if 0
    p5 = ellipsefit(x,y);
else
	p5 = [];
end

fig = figure;
ax = axes('Parent', fig);
plot(ax,x,y,'k.');
imconic(p1, [], ax, 'Color', 'blue', 'LineStyle', '-', 'LineWidth', 2);
imconic(p2, [], ax, 'Color', 'blue', 'LineStyle', ':', 'LineWidth', 2);
imconic(p3, [], ax, 'Color', 'red', 'LineStyle', '--', 'LineWidth', 2);
imconic(p4, [], ax, 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 2);
if ~isempty(p5)
    imconic(p5, [], ax);
    legend('Data points','Original curve','Direct fit','Hyperaccurate fit','Koopmans fit','Maximum likelihood fit');
else
    legend('Data points','Original curve','Direct fit','Hyperaccurate fit','Koopmans fit');
end