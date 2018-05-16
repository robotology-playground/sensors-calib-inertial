function plotNFuncTimeseries(...
    figuresHandler,aTitle,aLabel,...
    time,Y,...
    yLabel,yLegends)
%Plots y1(t), y2(t),...,yn(t) on the same axis.
%   Plots several timeseries functions y(time) with a single y axis,
%   using a default set of colors.
%   figuresHandler: class object handling all the figures (figure list
%   tracking, saving figures,...)
%   aTitle: figure title
%   aLabel: figure label for the figures handler
%   Y: each column j defines all the samples of a function yj(t)
%   yLabel: y axis units
%   yLegends: legends for all the functions

% create figure
figH = figure('Name',aTitle,'WindowStyle', 'docked');

if ~isempty(figuresHandler)
    figuresHandler.addFigure(figH,aLabel); % Add figure to the figure handler
end

% Define the line colors
lineColors = {'b','g','r','c','m','y','k','w'};
timeYnColorsRaw(1,1:size(Y,2)) = {time};
timeYnColorsRaw(2,:) = num2cell(Y,1); % Y is supposed to have the format NsamplesXnFunctions
timeYnColorsRaw(3,:) = lineColors(1,1:size(Y,2));
timeYnColors = timeYnColorsRaw(:)';
yLegends = yLegends(1:size(Y,2));

% If the figure is not docked, use the below command to display it full
% screen.
%set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title(aTitle,'Fontsize',16,'FontWeight','bold');
hold on

% plot(X1,Y1,S1,X2,Y2,S2,X3,Y3,S3,...) combines the plots defined by
% the (X,Y,S) triples, where the X's and Y's are vectors or matrices 
% and the S's are strings.
plot(timeYnColors{:},'lineWidth',1.0);

hold off
grid ON;
xlabel('Time (sec)','Fontsize',12);
ylabel(yLabel,'Fontsize',12);
legend('Location','BestOutside',yLegends{:});
set(gca,'FontSize',12);

end

