function pidPlotterThreadStartFcn( obj )
%Creates the figure for plotting Tau vs dq
%    Required for friction calibration only.

% Figure parameters
figTitle = 'PID output';
xLabel = 'Motor position (degrees)';
yLabel = 'PID output (% fullscale)';
obj.tempPlot.units = System.Const.Degrees;
xRange = [-60,60]; % degrees
yRange = [-10,10]; % percent fullscale

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
set(gca,'FontSize',12);
% obj.tempPlot.figH.CurrentAxes.XLim = xRange;
% obj.tempPlot.figH.CurrentAxes.YLim = yRange;

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
