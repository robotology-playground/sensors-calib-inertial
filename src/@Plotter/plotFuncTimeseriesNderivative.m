function plotFuncTimeseriesNderivative(...
    figuresHandler,aTitle,aLabel,...
    time,y,dtFrac,dy,...
    yLabel,yLegend,dydtLegend)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% compute dt component of the derivative dq/dt
dt = 0.2*dtFrac*mean(diff(time));
Dt = repmat(dt,size(dy));
Dy = dy*dt;

% create figure
figH = figure('Name',aTitle,'WindowStyle', 'docked');

% Save figure label
figH.UserData = aLabel;

if ~isempty(figuresHandler)
    figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler
end

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'FontSize',30,'FontWeight','bold');
hold on

plot(time,y,'r','lineWidth',2.0);
quiver(time,y,Dt,Dy,'b','lineWidth',1.0);

hold off
grid ON;
xlabel('Time (sec)','FontSize',30);
ylabel(yLabel,'FontSize',30);
legend('Location','BestOutside',yLegend,dydtLegend);
set(gca,'FontSize',30);

end
