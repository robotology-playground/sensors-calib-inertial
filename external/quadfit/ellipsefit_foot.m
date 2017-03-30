function [xf,yf] = ellipsefit_foot(x,y)
% Maximum likelihood ellipse fit with foot points.

% Copyright 2011 Levente Hunyadi

p_impl = ellipsefit(x,y, ...
    'Method', 'kepler');
p_expl = ellipse_im2ex(p_impl);
xfyf = quad2dproj([x,y], p_expl);
xf = xfyf(:,1);
yf = xfyf(:,2);

if nargout < 2
    hold on;
    for k = 1 : numel(x)
        plot([x(k),xf(k)],[y(k),yf(k)],'r', ...
            'LineWidth', 2);
    end
    imconic(p_impl, [], gca, ...
        'LineWidth', 2);
    plot(xf,yf,'r.', ...
        'MarkerSize', 18);
    plot(x,y,'k.', ...
        'MarkerSize', 18);
    hold off;
end