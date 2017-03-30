function example_parabolafit
% Demonstration of parabola fitting.

% Copyright 2012 Levente Hunyadi

N = 200;  % sample count
%sigma_x = 0.1;
%sigma_y = 0.1;
sigma_x = 0.35;
sigma_y = 0.35;

x0 = linspace(-2,5,N);
x0 = x0(:);
y0 = x0.^2;

x0 = x0 + 15;
y0 = -y0 + 15;

% pollute with noise
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(x0));

p_original = parabolafit_direct(x0,y0);
p_direct = parabolafit_direct(x,y);
p_cals = parabolafit_cals(x,y);
%p = parabolafit_oleary([x;y;ones(1,numel(x))]); p = p ./ norm(p);

%fig = figure;
%ax = axes('Parent', fig);
%plot(ax,x,y,'k.');
%imconic(p,0);
%imconic([1 0 0 -2 0.25 1],[],ax);
%imconic([0 0 1 -1 0 0],[],ax);
%imconic(p,[],ax);
%ezimplot3(@(x,y,z) p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6), [-50,50,-50,50,-1,1],100);
%axis equal;

%[R,theta] = imconicrotation([0 0 -1 1 0 0])  % x = y^2
%[R,theta] = imconicrotation([-1 0 0 0 1 0])  % y = x^2
%[R,theta] = imconicrotation([1 0 0 0 1 0])  % y = -x^2
%imconic(imconictranslate([0 0 -1 1 0 0], [5,15]))

hold on
plot(x,y,'k.');
h = ezplot(example_parabolafit_fn(p_original), [min(x) max(x) min(y) max(y)]);
set(h, 'Color', 'k');
h = ezplot(example_parabolafit_fn(p_direct), [min(x) max(x) min(y) max(y)]);
set(h, 'Color', 'b');
h = ezplot(example_parabolafit_fn(p_cals), [min(x) max(x) min(y) max(y)]);
set(h, 'Color', 'r');
hold off

function fn = example_parabolafit_fn(p)

validateattributes(p, {'numeric'}, {'real','finite','vector','numel',6});
fn = @(x,y) p(1).*x.^2 + p(2).*x.*y + p(3).*y.^2 + p(4).*x + p(5).*y + p(6);