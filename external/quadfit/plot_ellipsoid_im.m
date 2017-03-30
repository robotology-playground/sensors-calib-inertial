function plot_ellipsoid_im(p,varargin)
% Plot ellipsoid specified with implicit parameters.

% Copyright 2011 Levente Hunyadi

if nargin >= 4 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3});
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    args = varargin(4:end);
    
    %ezimplot3(@(x,y,z) p(1)*x.^2 + p(2)*y.^2 + p(3)*z.^2 + p(4)*x.*y + p(5)*x.*z + p(6)*y.*z + p(7)*x + p(8)*y + p(9)*z + p(10), [min(x) max(x) min(y) max(y) min(z) max(z)]);
else
    x = [];
    y = [];
    z = [];
    args = varargin(:);
end

[center,radii,~,R] = ellipsoid_im2ex(p);

if ~isempty(x) && ~isempty(y) && ~isempty(z)
    plot_ellipsoid_part(center(1),center(2),center(3),radii(1),radii(2),radii(3),R,x,y,z,args{:});
    
    if 0
        [xp,yp,zp] = ellipsoidfit_residuals(x,y,z, center,radii,R);
        hold all;
        plot3(xp,yp,zp,'r.');
        hold off;
    end
else
    plot_ellipsoid(center(1),center(2),center(3),radii(1),radii(2),radii(3),R,args{:});
end