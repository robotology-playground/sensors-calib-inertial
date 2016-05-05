%% clear all variables and close all previous figures
clear
close all
clc

%% Plot sensor measurements against estimations as 3D vectors

% load all variables
load('../EncodersAutoCalib/data/logSensorMeasVsEst.mat');
load('../EncodersAutoCalib/data/minimResult.mat');

origin=zeros(size(sensMeasCell,1),3);

activeAccs = mtbSensorCodes_list{1}(cell2mat(mtbSensorAct));

listAccPlotted = 1:size(sensMeasCell,2);
%listAccPlotted = 1;

figure('Name', '3D vectors sensor_meas (red) & sensor_est (blue)');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
    
    title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    axis vis3d;
    hold off;
end

figure('Name', 'coordinates of sensor_meas (red) & sensor_est (blue)');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    plot(Vmeas(:,1),'r-');
    plot(Vmeas(:,2),'rV:');
    plot(Vmeas(:,3),'r^:');
    plot(Vest(:,1),'b-');
    plot(Vest(:,2),'bV:');
    plot(Vest(:,3),'b^:');
    
    title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    hold off;
end

figure('Name', 'Norm of sensor_meas (red) & sensor_est (blue)');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=sensMeasNormMat(:,acc_i);
    Vest=sensEstNormMat(:,acc_i);
    Vcost=costNormMat(:,acc_i);
    
    plot(Vmeas,'r');
    plot(Vest,'b');
    plot(Vcost,'g');
    
    title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    hold off;
end

figure('Name', 'Angle of sensor_est VS sensor_meas');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    
    plot(angleMat(:,acc_i)*180/pi,'r');
    
    title(['acc. ' activeAccs(acc_i)]);
    axis equal;
end

% figure('Name', 'Distribution of sensor_meas Norm');
% 
% for acc_i = listAccPlotted
%     subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
%     hold on;
%     
%     Vcost=costNormMat(:,acc_i);
%     
%     histfit(Vmeas/max(Vmeas+0.1),20,'beta');
%     
%     title(['acc. ' activeAccs(acc_i)]);
%     axis equal;
%     hold off;
% end

% figure('Name', 'Distribution of sensor_meas Angle');
% 
% for acc_i = listAccPlotted
%     subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
%     hold on;
%     
%     Vangle=angleMat(:,acc_i);
%     
%     histfit(Vangle/max(Vangle+0.1),20,'beta');
%     
%     title(['acc. ' activeAccs(acc_i)]);
%     axis equal;
%     hold off;
% end

figure('Name', 'chain configuration q');

hold on
myColors = {'b','g','r','c','m','y'};
for qIdx = 1:6
    plot(qiMat(:,qIdx)*180/pi,myColors{qIdx});
end
hold off
legend('q1','q2','q3','q4','q5','q6');

% %% try to find a new combination matching meas. and est.
% 
% % compute all variances
% variance = zeros(size(sensMeasCell,2),size(sensMeasCell,2));
% for i = activeAccs
%     for j = activeAccs
%         diff = cell2mat(sensMeasCell(:,i)')-cell2mat(sensEstCell(:,j)');
%         variance(i,j) = diff*diff';
%     end
% end
% 
% % find the best match
% varMax=max(max(variance));
% idxVarMin=zeros(size(variance,1),1);
% 
% figure('Name', 'REORDERED 3D vectors sensor_meas (red) & sensor_est (blue)');
% 
% for k = 1:size(variance,1)
%     [lineOfMins,iMins] = min(variance,[],1);
%     [~,jMin] = min(lineOfMins);
%     idxVarMin(iMins(jMin)) = jMin; % final vector with sorting of indices
%     variance(iMins(jMin),:) = varMax; % erase line 'iMins(jMin)'
%     variance(:,jMin) = varMax; % erase column 'jMin'
% end
% 
% % display sorting
% idxVarMin
% 
% % Plot again re-ordered meas-est matches: sensMeasCell(:,acc_i) <=> sensEstCell(:,idxVarMin(acc_i))
% for acc_i = listAccPlotted
%     subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
%     Vmeas=cell2mat(sensMeasCell(:,acc_i));
%     quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
%     hold on;
%     Vest=cell2mat(sensEstCell(:,idxVarMin(acc_i)));
%     quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
%     title(['acc. ' mtbSensorCodes_list{1}(cell2mat(mtbSensorAct))]);
%     axis equal;
%     axis vis3d;
%     hold off;
% end

