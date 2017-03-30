function example_ellipsoidcomp
% Comparative demonstration of fits to random ellipsoids.

% Copyright 2013 Levente Hunyadi

fitting_methods = { @ellipsoidfit_simple, @ellipsoidfit_koopmans, @ellipsoidfit };
experiment_count = 530;
R = zeros(3, experiment_count);
D = zeros(numel(fitting_methods), experiment_count);

for i = 1 : experiment_count;
    [x,y,z,center_orig,radii_orig] = example_ellipsoid_random;
    R(:,i) = radii_orig;

    for j = 1 : numel(fitting_methods)
        fitting_func = fitting_methods{j};
        p = fitting_func(x,y,z);
        [center,radii] = ellipsoid_im2ex(p);
        D(j,i) = dist(center_orig, center);
    end

    if experiment_count <= 8  % do not visualize fits for many experiments
        figure;
        hold on;
        plot3(x,y,z,'k.');
        xlabel('x');
        ylabel('y');
        zlabel('z');
        hold off;

        p_direct = ellipsoidfit_simple(x,y,z);
        plot_ellipsoid_im(p_direct,'EdgeColor','blue');

        p_koopmans = ellipsoidfit_koopmans(x,y,z);
        plot_ellipsoid_im(p_koopmans,'EdgeColor','red');

        p_ml = ellipsoidfit(x,y,z);
        plot_ellipsoid_im(p_ml);

        axis equal;
    end
end

if 1
    % discard 10 largest values for each method (remove non-convergent cases)
    for i = 1 : 10
        [~,ix] = max(D,[],2);
        R(:,ix) = [];
        D(:,ix) = [];
    end
end

% ellipsoid parameters (semi-axes radii) and distance of ellipsoid center from origin
[R' D']

% mean distance from origin for various methods
mean(D,2)

% standard deviation of distance from origin for various methods
std(D,1,2)

% export variables to workspace
% some methods might have converged to suboptimal estimates; these cases may have to be removed
assignin('base', 'R', R);
assignin('base', 'D', D);

function d = dist(a,b)

d = sqrt(sum((a-b).^2));

function [x,y,z,center,radii] = example_ellipsoid_random
% Some points from a random ellipsoid centered at the origin.

% generate points
xc = 0; yc = 0; zc = 0;
xr = 9 * rand + 1;
yr = 9 * rand + 1;
zr = 9 * rand + 1;
[x0,y0,z0] = ellipsoid(xc,yc,zc,xr,yr,zr,50);
x0 = x0(:); y0 = y0(:); z0 = z0(:);

% filter points
%f = x0 < 0;  % half surface
f = x0 < 0 & y0 > 0;  % quarter surface
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

center = [xc ; yc ; zc];
radii = [xr ; yr ; zr];