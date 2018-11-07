function plot2dDataNfittedModel(...
    figuresHandler,aTitle,aLabel,...
    xData,yData,xModel,yModel,...
    xLabel,yLabel,...
    dataLegend,modelLegend)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% create figure
figH = figure('Name',aTitle,'WindowStyle', 'docked');

if ~isempty(figuresHandler)
    figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler
end

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'FontSize',30,'FontWeight','bold');
hold on

scatter(xData,yData,10,'blue','filled');
if ~isempty(xModel)
    plot(xModel,yModel,'r','lineWidth',4.0);
end

hold off
grid ON;

xlabel(xLabel,'FontSize',30);
ylabel(yLabel,'FontSize',30);

if ~isempty(xModel)
    legend('Location','BestOutside',dataLegend,modelLegend);
else
    legend('Location','BestOutside',dataLegend);
end

set(gca,'FontSize',30);

end
