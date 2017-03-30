function example_ellipsefit2
% Various ellipse fits to some data points.

% Copyright 2013 Levente Hunyadi

% seed random number generator
RandStream.setGlobalStream(RandStream('mt19937ar','seed',9999));

if 0
    N = 275;  % sample count
    sigma_x = 0.2;
    sigma_y = 0.2;
    
    % generate data points
    [x0,y0] = ellipse(N, 2, 3, 4, 2, pi/6);
else
    N = 275;  % sample count
    sigma_x = 0.2;
    sigma_y = 0.2;
    cx = 2;
    cy = 3;
    a = 4;
    b = 2;
    phi = pi/6;
    [x0,y0,nx0,ny0] = ellipse(N, cx, cy, a, b, phi); %#ok<NASGU,ASGLU>
    %[x0,y0,nx0,ny0] = ellipse(N, 0, 0, 1, 1);

    f = x0 < cx & y0 < cy;
    x0 = x0(f);
    y0 = y0(f);
end

% pollute with noise
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(x0));

p1 = ellipsefit(x0,y0);
%p2 = ellipsefit(x,y);
p3 = quad2dfit_koopmans(x,y,sigma_x,sigma_y);
p4 = quad2dfit_cals(x,y,sigma_x,sigma_y);

figure;
hold all;
line = plot(x,y,'k.');
legend_add(line, 'Data');
line = imconic(p1);
legend_add(line, 'Original');
%line = imconic(p2);
%setlinestyle(line, '--');
%legend_add(line, 'ML');
line = imconic(p3);
setlinestyle(line, ':');
legend_add(line, 'Koopmans');
line = imconic(p4);
setlinestyle(line, '-.');
legend_add(line, 'CALS');
hold off;

if 0
    sigma_x = 2*sigma_x;
    x = 2*(x + 1000);
    y = y + 500;

    p3 = quad2dfit_koopmans(x,y,sigma_x,sigma_y);
    p4 = quad2dfit_cals(x,y,sigma_x,sigma_y);

    figure;
    hold all;
    line = plot(x,y,'k.');
    legend_add(line, 'Data');
    %line = imconic(p1);
    %legend_add(line, 'Original');
    %line = imconic(p2);
    %setlinestyle(line, '--');
    %legend_add(line, 'ML');
    line = imconic(p3);
    setlinestyle(line, ':');
    legend_add(line, 'Koopmans');
    line = imconic(p4);
    setlinestyle(line, '-.');
    legend_add(line, 'CALS');
    hold off;
end

function setlinestyle(line, style)

set(findobj(line, '-property', 'LineStyle'), 'LineStyle', style);

function legend_add(varargin)
% Adds a new legend entry to an existing legend.

narginchk(2,3);
n = 1;

h = varargin{n};
validateattributes(h, {'numeric'}, {'real','scalar'}, n);
if ishandle(h) && strcmp('axes', get(h, 'Type'))
    ax = h;
    n = n + 1;
else
    ax = get(gcf,'CurrentAxes');
end

h = varargin{n};
validateattributes(h, {'numeric'}, {'real','scalar'}, n);
if ishandle(h) && (strcmp('line', get(h, 'Type')) || strcmp('hggroup', get(h, 'Type')))
    line = h;
    n = n + 1;
else
    error('legend:add','A line object expected.');
end

text = varargin{n};
validateattributes(text, {'char'}, {'nonempty','row'}, n);

% get handle of existing legend to add new entry to
h = legend(ax);
if isempty(h) 
    % if the figure has no legend, create a new legend
    legend(ax,'show');
    
    % do not use the automatically generated text strings
    handles = [];
    strings = {};
else
    % get object handles
    [~,~,handles,strings] = legend(ax);
end

% add object with new handle and new legend string to legend
legend(ax, [handles;line], strings{:}, text);
