function plot2funcTimeseriesYY(...
    figuresHandler,aTitle,aLabel,...
    time1,y1,time2,y2,...
    yLabel1,yLabel2,y1Legend,y2Legend)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% create figure
figH = figure('Name',aTitle,'WindowStyle', 'docked');

% Save fugure label
figH.UserData = aLabel;

if ~isempty(figuresHandler)
    figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler
end

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'FontSize',30,'FontWeight','bold');
hold on

[hAx,~,~] = plotyy(time1,y1,time2,y2);

hold off
grid ON;
xlabel('Time (sec)','FontSize',30);
ylabel(hAx(1),yLabel1,'FontSize',30);
ylabel(hAx(2),yLabel2,'FontSize',30);
if exist('y1Legend') && exist('y2Legend')
    legend('Location','BestOutside',y1Legend,y2Legend);
end
set(gca,'FontSize',30);

end
