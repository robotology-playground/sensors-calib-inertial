function quadprojfun(kind)
% The projection function Q(t) for various conics and quadrics.
%
% In deriving the projection function, we use the canonical equation of the quadratic curve or
% surface, i.e. the curve or surface is axis-aligned and centered at the origin (where possible).
%
% While it may appear restrictive, the canonical equation lets us treat projection of a point to a
% quadratic curve or surface without loss of generality. Should the curve or surface not be in the
% canonical form, a transformation matrix M that axis-aligns and centers the ellipse can be applied
% to the data points, and the inverse transformation matrix to the computed foot points.
%
% References
% David Eberly, "Distance from a point to an ellipse, an ellipsoid, or a hyperellipsoid", 2011,
%    http://www.geometrictools.com/Documentation/DistancePointEllipseEllipsoid.pdf
% Nikolai Chernov and Hui Ma, "Least squares fitting of quadratic curves and surfaces", In Sota R.
%    Yoshida, editor, Computer Vision, pages 285–302, Nova Science Publishers, 2011,
%    ISBN 978-1-61209-399-4
%
% Examples:
% quadprojfun
% quadprojfun ellipse
% quadprojfun('hyperbolic_paraboloid')

% Copyright 2013 Levente Hunyadi

if nargin > 0
    validateattributes(kind, {'char'}, {'nonempty','row'});
else
    kind = {'ellipse','hyperbola','parabola','ellipsoid','elliptic_paraboloid','hyperbolic_paraboloid','hyperboloid_one_sheet'};
end

% projection to ellipse
if any(strcmp('ellipse', kind))
    %syms a b w1 w2 w3 t
    %Q = ( (a*w1)./(t+a^2) ).^2 + ( (b*w2)./(t+b^2) ).^2 - 1;
    %dQdt1 = diff(Q,t)
    %dQdt1 = - (2*a^2*w1^2)/(a^2 + t)^3 - (2*b^2*w2^2)/(b^2 + t)^3;
    %dQdt2 = diff(dQdt1,t)
    %Qdt2 = (6*a^2*w1^2)/(a^2 + t)^4 + (6*b^2*w2^2)/(b^2 + t)^4;
    
    a = 2;
    b = 1;
    w1 = 0.5;
    w2 = 0.5;
    t = linspace(-b^2, b, 1000);
    f = ( (a*w1)./(t+a^2) ).^2 + ( (b*w2)./(t+b^2) ).^2 - 1;
    draw_figure('Ellipse', t, f, [-b^2-b^2/5,max(t)], [-2,9], -b^2, -1, {'-b^2'}, {'-1'});
end

% projection to hyperbola
if any(strcmp('hyperbola', kind))
    a = 2;
    b = 1;
    w1 = 2;
    w2 = 5;
    t = linspace(-a^2, b^2, 1000);
    f = ( (a*w1)./(t+a^2) ).^2 - ( (b*w2)./(-t+b^2) ).^2 - 1;
    
    tx = ( b^2*sqrt(a*w1) - a^2*sqrt(b*w2) ) / (sqrt(a*w1) + sqrt(b*w2));
    
    draw_figure('Hyperbola, case 1', t, f, [min(t),max(t)], [-10,10], [-a^2,tx,b^2], 0, {'-a^2','t_\ast','b^2'}, {'0'});
end
if any(strcmp('hyperbola', kind))
    a = 2;
    b = 1;
    w1 = 9;
    w2 = 4;
    t = linspace(-a^2, b^2, 1000);
    f = ( (a*w1)./(t+a^2) ).^2 - ( (b*w2)./(-t+b^2) ).^2 - 1;
    
    tx = ( b^2*sqrt(a*w1) - a^2*sqrt(b*w2) ) / (sqrt(a*w1) + sqrt(b*w2));
    
    draw_figure('Hyperbola, case 2', t, f, [min(t),max(t)], [-100,100], [-a^2,tx,b^2], 0, {'-a^2','t_\ast','b^2'}, {'0'});
end

% projection to parabola
if any(strcmp('parabola', kind))
    p = 1;
    w1 = 0.5;
    w2 = 0.5;
    t = linspace(-1, 1, 1000);
    f = w2^2 ./ (t+1).^2 - 2.*p.*w1 - 2.*p.^2.*t;
    draw_figure('Parabola', t, f, [-1.25,1], [-5,10], -1, 0, {'-1'}, {'0'});
end

% projection to ellipsoid
if any(strcmp('ellipsoid', kind))
    %syms a b c w1 w2 w3 t
    %Q = ( (a*w1)./(t+a^2) ).^2 + ( (b*w2)./(t+b^2) ).^2 + ( (c*w3)./(t+c^2) ).^2 - 1
    %dQdt1 = diff(Q,t)
    %dQdt1 = - (2*a^2*w1^2)/(a^2 + t)^3 - (2*b^2*w2^2)/(b^2 + t)^3 - (2*c^2*w3^2)/(c^2 + t)^3
    %dQdt2 = diff(dQdt1,t)
    %dQdt2 = (6*a^2*w1^2)/(a^2 + t)^4 + (6*b^2*w2^2)/(b^2 + t)^4 + (6*c^2*w3^2)/(c^2 + t)^4
end

% projection to elliptic paraboloid
if any(strcmp('elliptic_paraboloid', kind))
    %syms a b w1 w2 w3 t
    %Q = (a^2.*w1^2)./(a^2 + t).^2 + (b^2.*w2^2)./(b^2 + t).^2 - w3 - t./2
    %dQdt1 = diff(Q,t)
    %dQdt1 = - (2*a^2*w1^2)./(a^2 + t).^3 - (2*b^2*w2^2)./(b^2 + t).^3 - 1/2
    %dQdt2 = diff(dQdt1,t)
    %dQdt2 = (6*a^2*w1^2)./(a^2 + t).^4 + (6*b^2*w2^2)./(b^2 + t).^4
    
    a = 3;
    b = 0.5;
    w1 = 0.5;
    w2 = 0.5;
    w3 = 0.5;
    t = linspace(-b^2, 2, 1000);
    f = (a^2.*w1^2)./(a^2 + t).^2 + (b^2.*w2^2)./(b^2 + t).^2 - w3 - t./2;
    draw_figure('Elliptic paraboloid', t, f, [min(t)-0.25,max(t)], [-2,10], -b^2, 0, {'-b^2'}, {'0'});
end

% projection to hyperbolic paraboloid
if any(strcmp('hyperbolic_paraboloid', kind))
    %syms a b w1 w2 w3 t
    %Q = (a^2*w1^2)./((t+a^2).^2)-(b^2*w2^2)./((-t+b^2).^2)-w3-t./2;
    %dQdt1 = diff(Q,t)
    %dQdt1 = - (2*b^2*w2^2)/(b^2 - t)^3 - (2*a^2*w1^2)/(a^2 + t)^3 - 1/2;
    %dQdt2 = diff(dQdt1,t)
    %dQdt2 = (6*a^2*w1^2)/(a^2 + t)^4 - (6*b^2*w2^2)/(t - b^2)^4

    a = 1;
    b = 0.5;
    w1 = 0.5;
    w2 = 0.5;
    w3 = 0.5;
    t = linspace(-a^2, b^2, 1000);
    f = (a^2*w1^2)./((t+a^2).^2)-(b^2*w2^2)./((-t+b^2).^2)-w3-t./2;
    draw_figure('Hyperbolic paraboloid', t, f, [min(t)-0.25,max(t)+0.25], [-10,10], [-a^2,b^2], [], {'-a^2','b^2'}, {});
end

% projection to a hyperboloid of one sheet
if any(strcmp('hyperboloid_one_sheet', kind))
    %syms a b c w1 w2 w3 t
    %Q = (a^2*w1^2) / ((t+a^2)^2) + (b^2*w2^2) / ((t+b^2)^2) - (c^2*w3^2) / ((-t+c^2)^2) - 1;
    %Q = (a^2*w1^2)./((t+a^2).^2)-(b^2*w2^2)./((-t+b^2).^2)-w3-t./2;
    %dQdt1 = diff(Q,t)
    %dQdt1 = (2*c^2*w3^2)/(t - c^2)^3 - (2*a^2*w1^2)/(a^2 + t)^3 - (2*b^2*w2^2)/(b^2 + t)^3
    %dQdt2 = diff(dQdt1,t)
    %dQdt2 = (6*a^2*w1^2)/(a^2 + t)^4 - (6*c^2*w3^2)/(t - c^2)^4 + (6*b^2*w2^2)/(b^2 + t)^4
end

function draw_figure(name, t, f, xlim, ylim, xticks, yticks, xticklabels, yticklabels)

fig = figure('Name', name);
ax = axes('Parent',fig);
plot(ax, t, f, 'LineWidth', 2);
set(ax, ...
    'TickLength',[0 0], ...  % suppress tick marks
    'XTick',xticks, ...
    'XTickLabel',xticklabels, ...
    'YTick',yticks, ...
    'YTickLabel',yticklabels, ...
    'XLimMode','manual', ...
    'XLim',xlim, ...
    'YLimMode','manual', ...
    'YLim',ylim ...
);

% vertical lines
line('Parent',ax,'XData',[0,0],'YData',ylim);
for k = 1 : numel(xticks)
    line('Parent',ax,'XData',[xticks(k),xticks(k)],'YData',ylim,'LineStyle','--');
end

% horizontal lines
line('Parent',ax,'XData',xlim,'YData',[0,0]);
for k = 1 : numel(yticks)
    line('Parent',ax,'XData',xlim,'YData',[yticks(k),yticks(k)],'LineStyle','--');
end

% apply LaTeX interpreter to axis tick labels
if 1
    % clear current labels
    set(ax, 'XTickLabel', {}, 'YTickLabel', {});
    
    % get figure dimensions
    dims = axis(ax);

    % reset the ytick labels in desired font
    for i = 1 : numel(yticks)
        % create text box and set appropriate properties
        text(dims(1), yticks(i), yticklabels{i}, ...
            'HorizontalAlignment','right','VerticalAlignment','middle','Interpreter','tex','FontSize',10);

    end

    % reset the xtick labels in desired font 
    for i = 1 : numel(xticks)
        % create text box and set appropriate properties
        text(xticks(i), dims(3), xticklabels{i}, ...
            'HorizontalAlignment','center','VerticalAlignment','top','Interpreter', 'tex','FontSize',10); 
    end
end