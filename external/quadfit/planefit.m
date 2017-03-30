function [p,mu,x0,y0,z0] = planefit(x,y,z,sigma_x,sigma_y,sigma_z)
% Plane fit to noisy 3D data points.
%
% Output arguments:
% theta:
%    the plane normal vector
% mu:
%    noise magnitude

% Copyright 2008-2011 Levente Hunyadi

switch nargin
    case {2,4}
        dim = 2;
    case {3,6}
        dim = 3;
end

switch dim
    case 2
        validateattributes(x, {'numeric'}, {'nonempty','real','vector'});
        validateattributes(y, {'numeric'}, {'nonempty','real','vector'});
        X = [x(:),y(:),ones(numel(x),1)];
        if nargin > 2
            validateattributes(sigma_x, {'numeric'}, {'nonnegative','scalar'});
            validateattributes(sigma_y, {'numeric'}, {'nonnegative','scalar'});
            sigma = [sigma_x,sigma_y];
        else
            sigma = [];
        end
    case 3
        validateattributes(x, {'numeric'}, {'nonempty','real','vector'});
        validateattributes(y, {'numeric'}, {'nonempty','real','vector'});
        validateattributes(z, {'numeric'}, {'nonempty','real','vector'});
        X = [x(:),y(:),z(:),ones(numel(x),1)];
        if nargin > 3
            validateattributes(sigma_x, {'numeric'}, {'nonnegative','scalar'});
            validateattributes(sigma_y, {'numeric'}, {'nonnegative','scalar'});
            validateattributes(sigma_z, {'numeric'}, {'nonnegative','scalar'});
            sigma = [sigma_x,sigma_y,sigma_z];
        else
            sigma = [];
        end
end

if isempty(sigma)
    [~,s,v] = svd(X,0);
    mu = s(end);
    p = v(:,end);  % plane normal vector
else
    C = diag(sigma);
    [p,mu] = gsvd_min(X,C);
    p = p / norm(p);  % plane normal vector
end

% signed distance of points to plane
d = X * p;
X0 = X - d * p.';

% dehomogenize coordinates
switch dim
    case 2
        x0 = X0(:,1) ./ X0(:,3);
        y0 = X0(:,2) ./ X0(:,3);
    case 3
        x0 = X0(:,1) ./ X0(:,4);
        y0 = X0(:,2) ./ X0(:,4);
        z0 = X0(:,3) ./ X0(:,4);
end
