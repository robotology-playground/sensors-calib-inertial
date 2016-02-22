%jointsToCalibrate.parts = {'left_arm','right_arm','left_leg','right_leg'};

%% macros for repetitive names and codes between left and right parts
%
jointsToCalibrate_arm = @(side) {[side '_shoulder_pitch'],[side '_shoulder_roll'],[side '_shoulder_yaw'],[side '_elbow']};

jointsToCalibrate_leg = @(side) {[side '_hip_pitch'],[side '_hip_roll'],[side '_hip_yaw'], ...
                                 [side '_knee'],[side '_ankle_pitch'],[side '_ankle_roll']};

mtbSensorCodes_arm = @(mtbNum) {[mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12'],[mtbNum 'b13'], ...
                                [mtbNum 'b8'],[mtbNum '1b9'], ...
                                [mtbNum 'b7']};

mtbSensorCodes_leg = @(mtbNum) {[mtbNum 'b1'],[mtbNum 'b2'], ...
                                [mtbNum 'b3'],[mtbNum 'b4'], ...
                                [mtbNum 'b5'], ...
                                [mtbNum 'b6'],[mtbNum 'b7'], ...
                                [mtbNum 'b8'],[mtbNum 'b9'], ...
                                [mtbNum 'b10'],[mtbNum 'b11'], ...
                                [mtbNum 'b12']};

mtbSensorLink_arm = @(side) {[side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_upper_arm'],[side '_upper_arm'], ...
                             [side '_forearm'],[side '_forearm'] ...
                             [side '_hand']};

mtbSensorLink_leg = @(side) {[side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_upper_leg'], ...
                             [side '_upper_leg'],[side '_upper_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_lower_leg'],[side '_lower_leg'], ...
                             [side '_foot']};

%% define the joints to calibrate
%
jointsToCalibrate_left_arm = jointsToCalibrate_arm('l');
jointsToCalibrate_right_arm = jointsToCalibrate_arm('r');
jointsToCalibrate_left_leg = jointsToCalibrate_leg('l');
jointsToCalibrate_right_leg = jointsToCalibrate_leg('r');
jointsToCalibrate_torso = {'torso_pitch','torso_roll','torso_yaw'};

jointsInitOffsets_left_arm = [0 0 0 0];
jointsInitOffsets_right_arm = [0 0 0 0];
jointsInitOffsets_left_leg = [0 0 0 0 0 0];
jointsInitOffsets_right_leg = [0 0 0 0 0 0];
jointsInitOffsets_torso = [0 0 0];

%% define the sensor codes and links they are attached to
%
mtbSensorCodes_left_arm =  mtbSensorCodes_arm('1');

mtbSensorCodes_right_arm = mtbSensorCodes_arm('2');

mtbSensorCodes_left_leg =  mtbSensorCodes_leg('10');

mtbSensorCodes_right_leg = mtbSensorCodes_leg('11');

mtbSensorCodes_torso =  {'9b7','9b8', ...
                         '9b9','9b10'};

mtbSensorLink_left_arm = mtbSensorLink_arm('l');

mtbSensorLink_right_arm = mtbSensorLink_arm('r');

mtbSensorLink_left_leg = mtbSensorLink_leg('l');

mtbSensorLink_right_leg = mtbSensorLink_leg('r');


%% Build access lists
%
% jointsToCalibrate.partJoints = {};
% jointsToCalibrate.partJointsInitOffsets = {};
% mtbSensorCodes_list = {};
% mtbSensorLink_list = {};

for i = 1:length(jointsToCalibrate.parts)
    eval(['jointsToCalibrate.partJoints{' num2str(i) '} = jointsToCalibrate_' jointsToCalibrate.parts{i} ';']);
    eval(['jointsToCalibrate.partJointsInitOffsets{' num2str(i) '} = jointsInitOffsets_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorCodes_list{' num2str(i) '} = mtbSensorCodes_' jointsToCalibrate.parts{i} ';']);
    eval(['mtbSensorLink_list{' num2str(i) '} = mtbSensorLink_' jointsToCalibrate.parts{i} ';']);
end

