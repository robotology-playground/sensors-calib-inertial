function ellipsoid_projections(x,y,z,varargin)
% Plots ellipsoid projections on the xy, xz and yz planes.

% Copyright 2012 Levente Hunyadi

ellipsoid_project_plane(x, y, varargin{:});
ellipsoid_project_plane(x, z, varargin{:});
ellipsoid_project_plane(y, z, varargin{:});

function ellipsoid_project_plane(x, y, varargin)

fig = figure;
ax = axes('Parent', fig);
linestyle = {'-','--','-.',':'};
plot(ax,x,y,'k.');
xlabel(ax,inputname(1));
ylabel(ax,inputname(2));
for k = 1 : numel(varargin)
    switch sprintf('%s%s', inputname(1), inputname(2))
        case 'xy'
            fun = @ellipsoid_project_xy;
        case 'xz'
            fun = @ellipsoid_project_xz;
        case 'yz'
            fun = @ellipsoid_project_yz;
    end
    imconic(fun(varargin{k}), [], ax, 'LineStyle', linestyle{mod(k-1, numel(linestyle)) + 1}, 'LineWidth', 2);
end

function p = ellipsoid_project_xy(p)
% Project parameters of an ellipsoid to an ellipse in the xy plane.
%
% Ellipsoid parameter structure:
% Z = [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, 1];
%
% Ellipse parameter structure:
% Z = [x.^2, x.*y, y.^2, x, y, 1];

[xt,yt,zt] = quad3d_center(p);
p = quad3d_translate(p,-xt,-yt,-zt);
p = [p(1) ; p(4) ; p(2) ; p(7) ; p(8) ; p(10)];
p = quad2d_translate(p,xt,yt);

function p = ellipsoid_project_xz(p)
% Project parameters of an ellipsoid to an ellipse in the xz plane.
%
% Ellipsoid parameter structure:
% Z = [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, 1];
%
% Ellipse parameter structure:
% Z = [x.^2, x.*z, z.^2, x, z, 1];

[xt,yt,zt] = quad3d_center(p);
p = quad3d_translate(p,-xt,-yt,-zt);
p = [p(1) ; p(5) ; p(3) ; p(7) ; p(9) ; p(10)];
p = quad2d_translate(p,xt,zt);

function p = ellipsoid_project_yz(p)
% Project parameters of an ellipsoid to an ellipse in the yz plane.
%
% Ellipsoid parameter structure:
% Z = [x.^2, y.^2, z.^2, x.*y, x.*z, y.*z, x, y, z, 1];
%
% Ellipse parameter structure:
% Z = [y.^2, y.*z, z.^2, y, z, 1];

[xt,yt,zt] = quad3d_center(p);
p = quad3d_translate(p,-xt,-yt,-zt);
p = [p(2) ; p(6) ; p(3) ; p(8) ; p(9) ; p(10)];
p = quad2d_translate(p,yt,zt);
