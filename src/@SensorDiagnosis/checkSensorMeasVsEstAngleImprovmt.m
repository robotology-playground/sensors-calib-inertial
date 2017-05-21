function checkSensorMeasVsEstAngleImprovmt(...
    data,sensorsIdxListFile,...
    angleList_bc,angleList_ac,...
    figuresHandler)

% convert angles from radians to degrees
angleList_bc = angleList_bc*180/pi;
angleList_ac = angleList_ac*180/pi;

% check the size of 'sensorsIdxListFile'
if length(sensorsIdxListFile)~=size(angleList_bc,2)
    error('Wrong number of sensors doesn''t match the size of angles list');
end

% Create figure and add it to the figure handler
figH = figure('Name','Mean and STD of Angle of sensors measurement VS estimation','WindowStyle', 'docked');
figuresHandler.addFigure(figH,'meanSTDmeasVSestAngleBefNAftCalibration');
title('Mean and STD of Angle of sensors measurement VS estimation','Fontsize',16,'FontWeight','bold','Fontsize',16,'FontWeight','bold');
hold on;

% plot mean values
bar([mean(angleList_bc,1)' mean(angleList_ac,1)']);
set(gca,'XTick',1:length(sensorsIdxListFile),'XTickLabel',data.ac.labels(sensorsIdxListFile));
xlabel('MTB board labels','Fontsize',20);
ylabel('angle (degrees)','Fontsize',20);
grid on;

% plot standard deviations
errorbar((1:size(angleList_bc,2))-0.15,mean(angleList_bc,1)',...
    std(angleList_bc,0,1)',...
    'r*','lineWidth',2.5);
errorbar((1:size(angleList_bc,2))+0.15,mean(angleList_ac,1)',...
    std(angleList_ac,0,1)',...
    'b*','lineWidth',2.5);

legend('mean before calibration','mean after calibration',...
    '\sigma before calibration','\sigma after calibration');
hold off

end

