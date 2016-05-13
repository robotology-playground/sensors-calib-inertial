%% clear all variables and close all previous figures
clear
close all
clc

%% Plot sensor measurements against estimations as 3D vectors

% load all variables
load('../EncodersAutoCalib/data/logSensorMeasVsEst.mat');
load('../EncodersAutoCalib/data/minimResult.mat');

origin=zeros(size(sensMeasCell,1),3);

%activeAccs = mtbSensorCodes_list{1}(cell2mat(mtbSensorAct));
activeAccs = 'imu';

listAccPlotted = 1:size(sensMeasCell,2);
%listAccPlotted = 1;

% time scale
time = data.tInit + data.parsedParams.time(subsetVec_idx);

figure('Name', '3D vectors sensor measurement VS sensor estimation');
title('3D vectors of IMU measurement VS estimation','Fontsize',16,'FontWeight','bold');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vmeas(:,1),Vmeas(:,2),Vmeas(:,3),'color',[1 0 0]);
    quiver3(origin(:,1),origin(:,2),origin(:,3),Vest(:,1),Vest(:,2),Vest(:,3),'color',[0 0 1]);
    
    % title(['acc. ' activeAccs(acc_i)]);
    axis vis3d;
    % axis square;
    daspect([1 1 1]);
    d = daspect;
    grid ON;
    xlabel('Acc X (m/s^2)','Fontsize',12);
    ylabel('Acc Y (m/s^2)','Fontsize',12);
    zlabel('Acc Z (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','measured acc.','estimated acc.');
    hold off;
end
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','../EncodersAutoCalib/figs/demo_imu_headOnly/v3dAccEstVSaccMeas');


figure('Name', 'components of sensor measurement VS sensor estimation');
title('components of IMU measurement VS estimation','Fontsize',16,'FontWeight','bold');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=cell2mat(sensMeasCell(:,acc_i));
    Vest=cell2mat(sensEstCell(:,acc_i));
    
    plot(time,Vmeas(:,1),'r-');
    plot(time,Vmeas(:,2),'rV:');
    plot(time,Vmeas(:,3),'r^:');
    plot(time,Vest(:,1),'b-');
    plot(time,Vest(:,2),'bV:');
    plot(time,Vest(:,3),'b^:');
    
    % title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc X|Y|Z (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','measured x','measured y','measured z',...
        'estimated x','estimated y','estimated z');
    hold off;
end
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','../EncodersAutoCalib/figs/demo_imu_headOnly/xyzAccEstVSaccMeas');

figure('Name', 'Norm of sensor measurement VS sensor estimation');
title('Norm of IMU measurement VS estimation','Fontsize',16,'FontWeight','bold');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    Vmeas=sensMeasNormMat(:,acc_i);
    Vest=sensEstNormMat(:,acc_i);
    Vcost=costNormMat(:,acc_i);
    
    plot(time,Vmeas,'r','lineWidth',2.0);
    plot(time,Vest,'b','lineWidth',2.0);
    plot(time,Vcost,'g','lineWidth',2.0);
    
    % title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    legend('Location','BestOutside','norm(measured)','norm(estimated)','norm(measured-estimated)');
    hold off;
end
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','../EncodersAutoCalib/figs/demo_imu_headOnly/normAccEstVSaccMeas');

figure('Name', 'Angle of sensor measurement VS sensor estimation');
title('Angle of IMU measurement VS estimation','Fontsize',16,'FontWeight','bold');

for acc_i = listAccPlotted
    subplot(max(1,round(length(listAccPlotted)/3)),min(3,length(listAccPlotted)),acc_i);
    hold on;
    
    plot(time,angleMat(:,acc_i)*180/pi,'r','lineWidth',2.0);
    
    % title(['acc. ' activeAccs(acc_i)]);
    axis equal;
    grid ON;
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Angle (degrees)','Fontsize',12);
    hold off
end
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','../EncodersAutoCalib/figs/demo_imu_headOnly/angleAccEstVSaccMeas');

figure('Name', 'chain joint positions q');
title('torso,head joints positions q','Fontsize',16,'FontWeight','bold');

hold on
myColors = {'b','g','r','c','m','y'};
colorIdx = 1;
for qIdx = modelJointsList
    plot(time,qiMat(:,qIdx)*180/pi,myColors{colorIdx},'lineWidth',2.0);
    colorIdx = colorIdx+1;
end
hold off
grid ON;
xlabel('Time (sec)','Fontsize',12);
ylabel('Joints positions (degrees)','Fontsize',12);
legend('Location','BestOutside',[jointsToCalibrate.partJoints{1} jointsToCalibrate.partJoints{2}]);
set(gca,'FontSize',12);
print('-dpng','-r300','-opengl','../EncodersAutoCalib/figs/demo_imu_headOnly/jointPositions');


%%
%
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
%     title(['acc. ' mtbSensorCodes_list{1}(cell2mat(mtbSensorAct_list{1}))]);
%     axis equal;
%     axis vis3d;
%     hold off;
% end

