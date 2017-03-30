function plot_results(x, Y, name)
% Plot several data series against a single data series.
%
% Input arguments:
% x:
%    the data series to plot other data series against (i.e. "independent axis")
% Y:
%    the several data series to plot against the same ("independent") series (i.e. "dependent axis")
% name:
%    the title of the figure

% Copyright 2013 Levente Hunyadi

validateattributes(x, {'numeric'}, {'nonempty','vector'});
validateattributes(Y, {'numeric'}, {'nonempty','2d','size',[NaN,numel(x)]});
colors = {'k','b','g','r','c','m'};
% markers = {'+','o','*','x','^','v','<','>'};
styles = {'-','--','-.',':'};

figure('Name', name);
hold('all');
for i = 1 : size(Y,1)
    plot(x, Y(i,:), ...
        'Color', colors{mod(i-1,numel(colors))+1}, ...   % cycle through available colors
        ... % 'Marker', markers{mod(i-1,numel(markers))+1}, ...  % cycle through available markers
        'LineStyle', styles{mod(i-1,numel(styles))+1}, ...  % cycle through available line styles
        'LineWidth', 2 ...
    );
end
hold('off');
