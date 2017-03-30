function example_ellipsenormfit
% Comparing the accuracy of various ellipse fits with and without normals.

% Copyright 2011 Levente Hunyadi

N = 175;  % sample count
sigma_x = 0.5;
sigma_y = 0.5;
sigma_nx = 0.1;
sigma_ny = 0.1;
cx = 2;
cy = 3;
[x0,y0,nx0,ny0] = ellipse(N, cx, cy, 4, 2, pi/6);
%[x0,y0,nx0,ny0] = ellipse(N, 0, 0, 1, 1);

x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(y0));
nx = nx0 + sigma_nx * randn(size(nx0));
ny = ny0 + sigma_ny * randn(size(ny0));

p = quad2dfit_lsnormal(x,y,nx,ny);
plssq = quad2dfit_leastsquares(x,y);
pkoop = quad2dfit_koopmans(x,y,sigma_x,sigma_y);

hold all;
axis equal;
plot(x,y,'k.');
for k = 1 : numel(x0)
    plot([x0(k) x0(k)+nx(k)], [y0(k) y0(k)+ny(k)], 'k:');
end
imconic(p,[],gca,'LineWidth',2);
imconic(plssq,[],gca,'LineWidth',2);
imconic(pkoop,[],gca,'LineWidth',2);
hold off;

function p = eig_sm(D)

[V,E] = eig(D);
e = diag(E);
%V = V(:,e>0); e = e(e>0);
[~,ix] = min(e);
p = V(:,ix);
