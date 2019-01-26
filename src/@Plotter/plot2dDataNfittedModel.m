function plot2dDataNfittedModel(...
    figuresHandler,aTitle,aLabel,...
    xData,yData,xModel,yModel,...
    xLabel,yLabel,...
    dataLegend,modelLegend,highlightHysteresis)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% create figure
figH = figure('Name',aTitle,'WindowStyle', 'docked');

if ~isempty(figuresHandler)
    figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler
end

% Save fugure label
figH.UserData = aLabel;

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'FontSize',30,'FontWeight','bold');
hold on

% Legend
lg=legend('Location','BestOutside');
lg.set('Interpreter','latex');

% Select increasing/decreasing x samples and plot them
if (exist('highlightHysteresis','var') && ~isempty(highlightHysteresis))
    % identify increasing X samples
    bitmapUp = [0; diff(xData(:))]>=0;
    bitmapDown = ~bitmapUp;
    % plot and update the legend
    pUp = scatter(xData(bitmapUp),yData(bitmapUp),10,'red','filled');
    pDown = scatter(xData(bitmapDown),yData(bitmapDown),10,'blue','filled');
    pUp.DisplayName = [dataLegend ' $x$ up'];
    pDown.DisplayName = [dataLegend ' $x$ down'];
else
    % plot and update the legend
    p = scatter(xData,yData,10,'blue','filled');
    p.DisplayName = dataLegend;
end

if ~isempty(xModel)
    pModel = plot(xModel,yModel,'r','lineWidth',4.0);
    pModel.DisplayName = modelLegend;
end

hold off
grid ON;

xlabel(xLabel,'FontSize',30);
ylabel(yLabel,'FontSize',30);

set(gca,'FontSize',30);

end
