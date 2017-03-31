function angleList = checkSensorMeasVsEst(...
    data,sensorsIdxListFile,...
    sensMeasCell,sensEstCell,...
    figuresHandler,logtag)

% number of measurement samples
subSamplingSize = size(sensMeasCell,1);

% select accelerometers to check and plot
accIter = 1:length(sensorsIdxListFile);

% time series
time = data.ac.tInit + data.ac.parsedParams.time(:);

%% ============ 3D vectors ===============================================
%
figH = figure('Name', '3D vectors sensor measurement VS sensor estimation',...
    'WindowStyle', 'docked');
title('3D vectors of sensors measurement VS estimation','Fontsize',16,'FontWeight','bold');

% Add figure to the figure handler
figLabel = [logtag '_v3dAccEstVSaccMeas'];
figuresHandler.addFigure(figH,figLabel);

% origin of the vectors = origin of the sensor frame
origin=zeros(size(sensMeasCell,1),3);

subplotIdx = 0;
for acc_i = accIter
    subplotIdx = subplotIdx+1;
    subplot(max(1,ceil(length(accIter)/4)),min(4,length(accIter)),subplotIdx);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
    
    title(data.ac.labels{sensorsIdxListFile(acc_i)});
    axis vis3d;
    % axis square;
    daspect([1 1 1]);
    grid ON;
    xlabel('Acc X (m/s^2)','Fontsize',12);
    ylabel('Acc Y (m/s^2)','Fontsize',12);
    zlabel('Acc Z (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','measured acc.','estimated acc.');
    hold off;
end

%% ============ vector components ========================================
%
figH = figure('Name', 'components of sensor measurement VS sensor estimation',...
    'WindowStyle', 'docked');
title('components of sensors measurement VS estimation','Fontsize',16,'FontWeight','bold');

% Add figure to the figure handler
figLabel = [logtag '_xyzAccEstVSaccMeas'];
figuresHandler.addFigure(figH,figLabel);

subplotIdx = 0;
for acc_i = accIter
    subplotIdx = subplotIdx+1;
    subplot(max(1,ceil(length(accIter)/4)),min(4,length(accIter)),subplotIdx);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    plot(time,Vmeas(:,1),'r-');
    plot(time,Vmeas(:,2),'rV:');
    plot(time,Vmeas(:,3),'r^:');
    plot(time,Vest(:,1),'b-');
    plot(time,Vest(:,2),'bV:');
    plot(time,Vest(:,3),'b^:');
    
    title(data.ac.labels{sensorsIdxListFile(acc_i)});
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc X|Y|Z (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','measured x','measured y','measured z',...
        'estimated x','estimated y','estimated z');
    hold off;
end

%% ============ vector norms =============================================
%
figH = figure('Name', 'Norm of sensor measurement VS sensor estimation',...
    'WindowStyle', 'docked');
title('Norm of sensors measurement VS estimation','Fontsize',16,'FontWeight','bold');

% Add figure to the figure handler
figLabel = [logtag '_normAccEstVSaccMeas'];
figuresHandler.addFigure(figH,figLabel);

subplotIdx = 0;
for acc_i = accIter
    subplotIdx = subplotIdx+1;
    subplot(max(1,ceil(length(accIter)/4)),min(4,length(accIter)),subplotIdx);
    hold on;
    
    [Vmeas,Vest,Vcost] = deal(zeros(subSamplingSize,1));
    for ts = 1:subSamplingSize
        Vmeas(ts) = norm(sensMeasCell{ts,acc_i},2);
        Vest(ts) = norm(sensEstCell{ts,acc_i},2);
        Vcost(ts) = norm(sensMeasCell{ts,acc_i}-sensEstCell{ts,acc_i},2);
    end
    
    plot(time,Vmeas,'r','lineWidth',2.0);
    plot(time,Vest,'b','lineWidth',2.0);
    plot(time,Vcost,'g','lineWidth',2.0);
    
    title(data.ac.labels{sensorsIdxListFile(acc_i)});
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','norm(measured)','norm(estimated)','norm(measured-estimated)');
    hold off;
end

%% ============ angle between vectors ====================================
%
figH = figure('Name', 'Angle of sensor measurement VS sensor estimation',...
    'WindowStyle', 'docked');
title('Angle of sensors measurement VS estimation','Fontsize',16,'FontWeight','bold');

% Add figure to the figure handler
figLabel = [logtag '_angleAccEstVSaccMeas'];
figuresHandler.addFigure(figH,figLabel);

% each iteration of the for loop will feed a subplot
subplotIdx = 0;
% at each iteration, save the computed angle for the function output
angleList = zeros(subSamplingSize,length(accIter));
% compute the angles
for acc_i = accIter
    % define subplot for the current selected sensor
    subplotIdx = subplotIdx+1;
    subplot(max(1,ceil(length(accIter)/4)),min(4,length(accIter)),subplotIdx);
    hold on;
    
    % compute angles for the current selected sensor
    angleMat = zeros(subSamplingSize,1);
    for ts = 1:subSamplingSize
        angleMat(ts) = Angle.va2vb(sensEstCell{ts,acc_i},sensMeasCell{ts,acc_i});
    end
    
    % plot angles
    plot(time,angleMat*180/pi,'r','lineWidth',2.0);
    title(data.ac.labels{sensorsIdxListFile(acc_i)});
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Angle (degrees)','Fontsize',12);
    hold off
    
    % save angles for the function output
    angleList(:,acc_i) = angleMat(:);
end

