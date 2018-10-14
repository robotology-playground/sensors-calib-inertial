function [figH,ditribLogString] = plotNprintDistrb(aTitle,Y,xLegend,units,fitGaussian,color,alpha,axbc,axac)
% Plots data in the active figure
%

figH = figure('Name',aTitle,'WindowStyle', 'docked');
title(aTitle,'FontWeight','bold','Interpreter','latex');
set(gca,'FontSize',24);
grid on;
hold on;
lg=legend('Location','BestOutside');
lg.set('Interpreter','latex');

%histogram(dOrient,200,'Normalization','probability');
%histogram(dOrient,'Normalization','probability','DisplayStyle','stairs','BinMethod','auto');
%histfit(dOrient,200,'kernel');
h = histogram(Y,'Normalization','pdf','EdgeColor','none','FaceColor',color,'FaceAlpha',alpha);
h.DisplayName = ['$' xLegend '$'];

if nargin==8
    xmin = min([axbc.XLim(1) axac.XLim(1)]);
    xmax = max([axbc.XLim(2) axac.XLim(2)]);
    axbc.XLim = [xmin xmax];
    axac.XLim = [xmin xmax];
else
    % get the matrix of X limits from gca (current subplot).
    % transform it to a list
    xLimits = num2cell(get(gca,'XLim'));
    [xmin,xmax] = xLimits{:}; % split list
end

% Fit a gaussian distribution
if fitGaussian
    x = linspace(xmin,xmax,1000)' ;
    mu = mean(Y,1); sigma = std(Y,0,1);
    x_pm_sigma = linspace(mu-sigma,mu+sigma,round(1000*2*sigma/(xmax-xmin)))';
    if ~isempty(x_pm_sigma)
        f = @(t) exp(-(t-mu).^2/(2*sigma^2))/(sigma*sqrt(2*pi));
        pfit = plot(x,f(x),'r-','Linewidth',2);
        parea = area(x_pm_sigma,f(x_pm_sigma),...
            'Linewidth',1,'EdgeColor','red','FaceColor','none',...
            'LineStyle',':','ShowBaseLine','off');
        xmean = repmat(mu,[100,1]);
        fmean = linspace(0,f(mu),100);
        pmean = plot(xmean,fmean,'r-','Linewidth',1);
        pfit.DisplayName = 'probability distribution fit';
        pmean.DisplayName = ['mean: ' num2str(mean(Y,1)) '$' units '$'];
        parea.DisplayName = ['std: ' num2str(std(Y,1,1)) '$' units '$'];
        %     drawnow; pause(0.05);
        %     parea.Face.ColorType = 'truecoloralpha';
        %     parea.Face.ColorData(4) = 255 * 0.3;
    end
end
xlabel(['$' xLegend units '$'],'Interpreter','latex');
ylabel('Normalized number of occurence');
hold off

% Return string with the distribution parameters for logging purposes
ditribLogString = sprintf(...
    ['distribution of distances to a centered sphere\n'...
    'mean:%d m/s^2\n'...
    'standard deviation:%d m/s^2\n'],mean(Y,1),std(Y,0,1));

end

