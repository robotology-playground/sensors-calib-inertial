function sgolayFilterParamsTuning( time_1xN_vector,Y_dxN_vector,funcName,funcLabelUnits_dx1,filterParamsSavePath )

%% Main Tuning default parameters ==============================================

filterParams = struct(...
    'type','sgolay',...
    'SgolayK',5,...
    'SgolayF',601);

%% Plot data, apply sgolay filter and tune its parameters
%
Ydim = size(Y_dxN_vector,1);
time = time_1xN_vector;
Yvec = Y_dxN_vector;
labelUnits = funcLabelUnits_dx1;

% init filter parameter and referenced object
filterContext = FilterContext(filterParams.SgolayK,filterParams.SgolayF,time,Yvec,filterParamsSavePath);

% create figure and press-key handler
figure('Name',['{x,y,z} Components of raw sensor ' funcName],...
    'WindowKeyPressFcn',{@FilterContext.tuneFilter,filterContext});
set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);

% Plot original signal components Y_1, Y_2, ... , Y_d
ax = cell(1,Ydim);
for figIdx = 1:Ydim
    ax{figIdx} = subplot(Ydim,1,figIdx);
    title('X component','Fontsize',16,'FontWeight','bold');
    grid ON;
    hold on;
    plot(time,Yvec(figIdx,:),'r-','lineWidth',2.0);
    xlabel('Time (sec)','Fontsize',12);
    ylabel(labelUnits{figIdx},'Fontsize',12);
    hold off;
end

% register the subplot axis for allowing the callback function to plot
% the filtered components
filterContext.regSubPlots(ax);

end

