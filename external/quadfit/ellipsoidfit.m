function [p,e,d] = ellipsoidfit(x,y,z,varargin)
% Fit an ellipsoid to data by minimizing point-to-surface distance.
%
% This function uses an iterative procedure. For a non-iterative approach, use
% a direct least squares fit.
%
% Output arguments:
% p:
%    parameters of ellipsoid expressed in implicit form
% e:
%    mean square distance
% d:
%    distance from data points to fitted ellipsoid
%
% See also: ellipsoidfit_direct, ellipsoidfit_leastsquares

% Copyright 2011 Levente Hunyadi

if ~exist('lsqnonlin','file')
    error('quadfit:DependencyMissing', 'This function requires the Optimization Toolbox.\nFor a least-squares fit, try the function "ellipsoidfit_leastsquares".');
end

if nargin > 0
    narginchk(3,Inf);
    validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
    validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
    validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
    x = x(:);
    y = y(:);
    z = z(:);
else
    if exist('example_ellipsoid.mat','file') > 0
        S = load('example_ellipsoid.mat', 'ellipsoid');
    else
        S = struct;
    end
    if isfield(S,'ellipsoid')
        x = S.ellipsoid(:,1); y = S.ellipsoid(:,2); z = S.ellipsoid(:,3);
    else
        [x,y,z] = example_ellipsoid;
    end
    %plot3(x,y,z,'b.');  % observed noisy data points
end

% compute a close-enough initial least-squares fit
%p_im = ellipsoidfit_direct(x,y,z);  % always fits an ellipsoid
p_im = ellipsoidfit_simple(x,y,z);  % always fits an ellipsoid, closer to maximum likelihood
[center,radii,quat] = ellipsoid_im2ex(p_im);
pinit = [center;radii;quat];

opts = optimset( ...
    ... %'Algorithm', 'levenberg-marquardt', ...
    'DerivativeCheck', 'on', ...
    'Display', 'off', ...
    'Jacobian', 'off');

lb_center = [-Inf,-Inf,-Inf];
ub_center = [Inf,Inf,Inf];
lb_radii = [0,0,0];
ub_radii = [Inf,Inf,Inf];
lb_quat = [0,-1,-1,-1];  % resolve sign ambiguity in quaternion representation
ub_quat = [1,1,1,1];
lb = [lb_center,lb_radii,lb_quat];
ub = [ub_center,ub_radii,ub_quat];

fun = @(p) ellipsoidfit_distance(x,y,z,p);
[pe,e] = lsqnonlin(fun, pinit, lb, ub, opts);

if nargout >= 1
    [cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = ellipsoid_deal(pe);
    R = quat2rot([q1,q2,q3,q4]);
    p = ellipsoid_ex2im([cx,cy,cz],[ap,bp,cp],R);
    e = e / numel(x);
    if nargout > 2
        d = ellipsoidfit_distance(x,y,z,pe);
    end
else
    hold all;

    %[cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = ellipsoid_deal(pinit);
    %R = quat2rot([q1,q2,q3,q4]);
    %plot_ellipsoid(cx,cy,cz,ap,bp,cp,R);  % plot initial fit

    plot3(x,y,z,'b.');  % observed noisy data points
    
    [cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = ellipsoid_deal(pe);
    R = quat2rot([q1,q2,q3,q4]);
    [xf,yf,zf] = ellipsoidfit_residuals(x,y,z, [cx,cy,cz], [ap,bp,cp], R);
    plot3(xf,yf,zf,'r.');  % noise-free counterparts of noisy data points
    plot_ellipsoid(cx,cy,cz,ap,bp,cp,R);  % plot maximum likelihood fit of ellipse
    
    hold off;
end

function [cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = ellipsoid_deal(p)

pcl = num2cell(p);
[cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = pcl{:};

function [d,ddp] = ellipsoidfit_distance(x,y,z,p)
% Distance of points to ellipsoid defined with parameters center, axes and rotation.

[cx,cy,cz,ap,bp,cp,q1,q2,q3,q4] = ellipsoid_deal(p);
R = quat2rot([q1,q2,q3,q4]);

% get foot points
[xf,yf,zf] = ellipsoidfit_residuals(x,y,z, [cx,cy,cz], [ap,bp,cp], R);

% calculate distance from foot points
d = realsqrt((x-xf).^2 + (y-yf).^2 + (z-zf).^2);

% use ellipse equation P = 0 for computing derivatives
if nargout > 1  % FIXME derivatives
    % Jacobian matrix, i.e. derivatives w.r.t. parameters
    dPdp = [ ...  % Jacobian J is m-by-n, where m = numel(x) and n = numel(p)
    ];
    dPdx = 0;
    dPdy = 0;
    
    % derivative of distance to foot point w.r.t. parameters
    ddp = bsxfun(@rdivide, dPdp, realsqrt(dPdx.^2 + dPdy.^2));
end
