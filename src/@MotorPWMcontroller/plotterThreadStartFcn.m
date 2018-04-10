function plotterThreadStartFcn( obj )
%Creates the figure for plotting Tau vs dq
%    Required for friction calibration only.

% Figure parameters
figTitle = 'Motor velocity to torque model';
xLabel = 'Motor velocity (degrees/s)';
yLabel = 'Motor torque (N.m)';
obj.tempPlot.units = System.Const.Degrees;
xRange = [-90,90]; % degrees
yRange = [-10,10]; % degrees

% units conversion
obj.tempPlot.convertFromRad = Math.convertFromRadians(obj.tempPlot.units);

% create figure
obj.tempPlot.figH = figure('Name',figTitle);

% This is a temporary figure and won't be docked, so display it full screen.
set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);

% title, axes labels, legend
title(figTitle,'Fontsize',16,'FontWeight','bold');
xlabel(xLabel,'Fontsize',12);
ylabel(yLabel,'Fontsize',12);
set(gca,'FontSize',12);
obj.tempPlot.figH.CurrentAxes.XLim = xRange;
obj.tempPlot.figH.CurrentAxes.YLim = yRange;

% grid and hold the figure open for further data input
hold on;
grid on;

end
