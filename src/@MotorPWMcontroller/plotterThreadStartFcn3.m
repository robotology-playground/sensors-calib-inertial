function plotterThreadStartFcn3( obj )
%Creates the figure for plotting Tau vs dq
%    Required for friction calibration only.

% Figure parameters
figTitle = 'Motor PWM/position to Current model';
xLabel = 'Motor position (degrees)';
yLabel = 'Motor PWM (dutycycle%)';
zLabel = 'Motor Current (A)';
obj.tempPlot.units = System.Const.Degrees;
xRange = [-180,180]; % degrees
yRange = [-100,100]; % dutycycle%
zRange = [-10,10]; % A

% units conversion
obj.tempPlot.convertFromRad = Math.convertFromRadians(obj.tempPlot.units);
obj.tempPlot.convertFromDeg = Math.convertFromDegrees(obj.tempPlot.units);

% create figure
obj.tempPlot.figH = figure('Name',figTitle,'WindowStyle','docked');

% For displaying an undocked figure in full screen, uncomment the line below.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);

% title, axes labels, legend
title(figTitle,'Fontsize',16,'FontWeight','bold');
xlabel(xLabel,'Fontsize',12);
ylabel(yLabel,'Fontsize',12);
zlabel(zLabel,'Fontsize',12);
set(gca,'FontSize',12);
% obj.tempPlot.figH.CurrentAxes.XLim = xRange;
% obj.tempPlot.figH.CurrentAxes.YLim = yRange;
% obj.tempPlot.figH.CurrentAxes.ZLim = zRange;

view(45,30); % view(az,el)
% axis vis3d;
% axis image;

% grid and hold the figure open for further data input
grid on;

% define the animated line (the actual plot of the data)
an = animatedline;
an.LineStyle = 'none';
an.Marker = 'o';
an.MarkerFaceColor = 'b';
an.Visible = 'on';
an.Selected = 'off';

obj.tempPlot.an = an;

end
