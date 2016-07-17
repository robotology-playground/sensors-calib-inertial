function plotNprintDistrb(FID,dOrient,fitGaussian,axbc,axac)
% Plots data in the active figure
%
hold on
%histogram(dOrient,200,'Normalization','probability');
%histogram(dOrient,'Normalization','probability','DisplayStyle','stairs','BinMethod','auto');
%histfit(dOrient,200,'kernel');
histogram(dOrient,'Normalization','pdf','EdgeColor','none');

if nargin==4
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
    mu = mean(dOrient,1); sigma = std(dOrient,0,1);
    x_pm_sigma = linspace(mu-sigma,mu+sigma,round(1000*2*sigma/(xmax-xmin)))'
    f = @(t) exp(-(t-mu).^2/(2*sigma^2))/(sigma*sqrt(2*pi));
    pfit = plot(x,f(x),'r-','Linewidth',2);
    parea = area(x_pm_sigma,f(x_pm_sigma),...
        'Linewidth',1,'EdgeColor','red','LineStyle',':','ShowBaseLine','off');
    xmean = repmat(mu,[100,1]);
    fmean = linspace(0,f(mu),100);
    pmean = plot(xmean,fmean,'r-','Linewidth',1);
    legend([pmean,parea],['mean: ' num2str(mean(dOrient,1))],['std: ' num2str(std(dOrient,1,1))]);
    drawnow; pause(0.05);
    parea.Face.ColorType = 'truecoloralpha';
    parea.Face.ColorData(4) = 255 * 0.3;
end
xlabel('Oriented distance to surface','Fontsize',12);
ylabel('Normalized number of occurence','Fontsize',12);
hold off
fprintf(FID,['distribution of distances to a centered sphere\n'...
    'mean:%d\n'...
    'standard deviation:%d\n'],mean(dOrient,1),std(dOrient,0,1));

end

