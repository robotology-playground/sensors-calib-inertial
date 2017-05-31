function jointNameList = getJointNamesFromUIidxes(obj,init,model)
% Get joint names from indexes as they are defined in the app UI
% 
% Fine selection of joint encoders:
% Select the joints to calibrate through the respective indexes. These indexes match 
% the joint names listed below, as per the joint naming convention described in 
% 'http://wiki.icub.org/wiki/ICub_Model_naming_conventions', except for the torso.
%
%      shoulder pitch roll yaw   |   elbow   |   wrist prosup pitch yaw   |  
% arm:          0     1    2     |   3       |         4      5     6     |
%
%      hip      pitch roll yaw   |   knee    |   ankle pitch  roll       |  
% leg:          0     1    2     |   3       |         4      5          |
%
%               yaw   roll pitch |
% torso:        0     1    2     |
%
%               pitch roll yaw   |
% head:         0     1    2     |
%

% Init tank list
jointNameList = {};

% unwrap the parameters specific to the calibration task
% - calibedParts
% - taskSpecificParams
% - ...
Init.unWrap(init.(obj.initSection));

for cPart = calibedParts
    part = cell2mat(cPart);
    % Get the full joint list from model (aligned with the order specified
    % above), for calibrated part
    jointsFromPart = model.jointsDbase.getJointNames(part);
    
    % get the joint indexes to calibrate from the init parameters
    jointsCalibIdxes = taskSpecificParams.calibedJointsIdxes.(part)+1;
    
    % Add selected joints to final list
    jointNameList =  [jointNameList jointsFromPart(jointsCalibIdxes)];
end

end

