% Add main folders in Matlab path
run generatePaths.m;

%% clear all variables and close all previous figures
clear all
%close all
clc

%Clear static data
clear classes;

ax=gca
axesObjs=ax.Children
% scatter plot: axesObjs(2), fitted model: axesObjs(1)
X = axesObjs(2).XData;
Y = axesObjs(2).YData;

set(gca,'Nextplot','replacechildren');

plot(0,0);

% define the animated line (the actual plot of the data)
an = animatedline(gca);
an.LineStyle = 'none';
an.Marker = 'o';
an.MarkerFaceColor = 'b';
an.Visible = 'on';
an.Selected = 'off';

nPoints = numel(X);
M(1,1:nPoints) = struct('cdata',[],'colormap',[]);

figH = gcf;
for k = 1:nPoints
    addpoints(an,X(k),Y(k));
    drawnow;
    M(k) = getframe(figH);
end

figure
axes('Position',[0 0 1 1])
movie(M,5)
