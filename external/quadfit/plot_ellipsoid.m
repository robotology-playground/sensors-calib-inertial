function plot_ellipsoid(cx,cy,cz,ap,bp,cp,R,varargin)
% Plot ellipsoid specified with center, radii and rotation matrix.
%
% Input arguments:
% cx,cy,cz;
%    x, y and z coodinate of ellipsoid center
% ap,bp,cp;
%    ellipsoid radii
% R:
%    rotation matrix
% varargin:
%    additional parameters as name-value pairs:
%    * EdgeColor: color
%    * AxesColor ['none'|color]

% Copyright 2011 Levente Hunyadi

% generate surface mesh
[x,y,z] = ellipsoid(0,0,0,ap,bp,cp);

% rotate surface mesh
X = [x(:),y(:),z(:)]*R;
n = realsqrt(numel(x));

% reconstruct mesh from points
x = reshape(X(:,1),n,n) + cx;  % add center offset
y = reshape(X(:,2),n,n) + cy;
z = reshape(X(:,3),n,n) + cz;

% default argument values
edgecolor = 'magenta';
%axescolor = 'black';
axescolor = 'none';

% parse arguments
argin = cell(1,0);
for k = 1:2:numel(varargin)
    argname = varargin{k};
    validateattributes(argname, {'char'}, {'nonempty','row'});
    argvalue = varargin{k+1};
    switch argname
        case 'AxesColor'
            axescolor = argvalue;
        case 'EdgeColor'
            edgecolor = argvalue;
        otherwise
            argin = [ argin, { argname, argvalue } ]; %#ok<AGROW>
    end
end

% plot surface mesh
set(gcf,'NextPlot','add');
set(gca,'NextPlot','add');
colormap(gca,'pink');
surf(x,y,z, ...
    'EdgeColor', edgecolor, ...
    'FaceAlpha', 0.0, ...  % 0.0 = clear, 1.0 = opaque
    argin{:});

if ~strcmp(axescolor, 'none')
    hg = hggroup;
    plot3([cx;cx+ap*R(1,1)], [cy;cy+ap*R(1,2)], [cz;cz+ap*R(1,3)], 'Parent', hg, 'Color', axescolor);
    plot3([cx;cx+bp*R(2,1)], [cy;cy+bp*R(2,2)], [cz;cz+bp*R(2,3)], 'Parent', hg, 'Color', axescolor);
    plot3([cx;cx+cp*R(3,1)], [cy;cy+cp*R(3,2)], [cz;cz+cp*R(3,3)], 'Parent', hg, 'Color', axescolor);
end
