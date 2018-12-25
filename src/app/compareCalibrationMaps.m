% Compare calibrationMaps
clear all;

load('calibrationMap_06-12-2018-17-19.mat','calibrationMap');
calibrationMap1 = calibrationMap;
load('calibrationMap_06-12-2018-17-49.mat','calibrationMap');
calibrationMap2 = calibrationMap;
% load('calibrationMap_14-12-2018-21-20.mat','calibrationMap');
% calibrationMap3 = calibrationMap;
% load('calibrationMap_14-12-2018-21-34.mat','calibrationMap');
% calibrationMap4 = calibrationMap;
clear calibrationMap;

diffCentre = containers.Map();
diffCentreMax = 0;

accNames(1,1:8) = {...
    'l_upper_leg_mtb_acc_10b1'
    'l_upper_leg_mtb_acc_10b2'
    'l_upper_leg_mtb_acc_10b3'
    'l_upper_leg_mtb_acc_10b4'
    'l_lower_leg_mtb_acc_10b8'
    'l_lower_leg_mtb_acc_10b9'
    'l_lower_leg_mtb_acc_10b10'
    'l_lower_leg_mtb_acc_10b11'}';

for acc = accNames
    disp(acc);
    calib1 = calibrationMap1(cell2mat(acc));
    calib2 = calibrationMap2(cell2mat(acc));
%     calib3 = calibrationMap3(cell2mat(acc));
%     calib4 = calibrationMap4(cell2mat(acc));
    diffCentre(cell2mat(acc)) = calib1.centre-calib2.centre;
%     meanCentre = (calib1.centre+calib2.centre+calib3.centre+calib4.centre)/4;
%     diffCentre(cell2mat(acc)) = [calib1.centre,calib2.centre,calib3.centre,calib4.centre]...
%         - repmat(meanCentre,[1,4]);
end

% distribution of offsets
diffCentreList = diffCentre.values;
diffCentreArray = [diffCentreList{:}];
% Display average and deviation
disp('Distribution of offsets:');
mean(diffCentreArray,2)
std(diffCentreArray,1,2)
max(max(diffCentreArray));

