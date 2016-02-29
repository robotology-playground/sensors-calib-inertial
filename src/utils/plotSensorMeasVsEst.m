%% clear all variables and close all previous figures
clear
close all
clc

%% Plot sensor measurements against estimations as 3D vectors

% load all variables
load('../EncodersAutoCalib/logSensorMeasVsEst.mat');

origin=zeros(size(sensMeasCell,1),3);

figure('Name', '3D vectors sensor_meas (red) & sensor_est (blue)');

for acc_i = 1:size(sensMeasCell,2)
    subplot(3,round(size(sensMeasCell,2)/3),acc_i);
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
    hold on;
    Vest=cell2mat(sensEstCell(:,acc_i));
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
    title(['acc. ' num2str(acc_i)]);
    axis equal;
    axis vis3d;
    hold off;
end

%% try to find a new combination matching meas. and est.

% compute all variances
variance = zeros(size(sensMeasCell,2),size(sensMeasCell,2));
for i = 1:size(sensMeasCell,2)
    for j = 1:size(sensMeasCell,2)
        diff = cell2mat(sensMeasCell(:,i)')-cell2mat(sensEstCell(:,j)');
        variance(i,j) = diff*diff';
    end
end

% find the best match
varMax=max(max(variance));
idxVarMin=zeros(size(variance,1),1);

figure('Name', 'REORDERED 3D vectors sensor_meas (red) & sensor_est (blue)');

for k = 1:size(variance,1)
    [lineOfMins,iMins] = min(variance,[],1);
    [~,jMin] = min(lineOfMins);
    idxVarMin(iMins(jMin)) = jMin; % final vector with sorting of indices
    variance(iMins(jMin),:) = varMax; % erase line 'iMins(jMin)'
    variance(:,jMin) = varMax; % erase column 'jMin'
end

% display sorting
idxVarMin

% Plot again re-ordered meas-est matches: sensMeasCell(:,acc_i) <=> sensEstCell(:,idxVarMin(acc_i))
for acc_i = 1:size(sensMeasCell,2)
    subplot(3,round(size(sensMeasCell,2)/3),acc_i);
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
    hold on;
    Vest=cell2mat(sensEstCell(:,idxVarMin(acc_i)));
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
    title(['acc. ' num2str(acc_i)]);
    axis equal;
    axis vis3d;
    hold off;
end

