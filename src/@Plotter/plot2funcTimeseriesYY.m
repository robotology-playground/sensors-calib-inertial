function plot2funcTimeseriesYY(...
    figuresHandler,aTitle,aLabel,...
    time1,y1,time2,y2,...
    yLabel1,yLabel2)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%% Plot joint trajectories
figH = figure('Name',aTitle,'WindowStyle', 'docked');

figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'Fontsize',16,'FontWeight','bold');
hold on

[hAx,~,~] = plotyy(time1,y1,time2,y2);

hold off
grid ON;
xlabel('Time (sec)','Fontsize',12);
ylabel(hAx(1),yLabel1,'Fontsize',12);
ylabel(hAx(2),yLabel2,'Fontsize',12);
set(gca,'FontSize',12);

end
