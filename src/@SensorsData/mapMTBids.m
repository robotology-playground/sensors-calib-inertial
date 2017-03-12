function mapMTBids(obj,yBuff)
% Builds the map between the MTB ids from the inertialMTB metadata into MTB sensor codes

%% ==== EMS Data format ====
%
% The network interface is a single Port for a whole limb/part
% (left_leg, left_arm, rught_arm, torso, ...)
%
% [n  VER  (a1 b1 t1 x1 y1 z1)   .... (an bn tn xn yn zn)]
% n  = number of sensors
% VER= current format version: 6.0
% ai = pos of sensor ... see enum type
% bi = accel (1) or gyro (2)
% ti = time stamp.
% xi,yi,zi = the 3 measurement channels of the accelerometer (non calibrated)
%
header_length = 2;
version = 6;
sensorDataLength = 6;
sensorDataStartOffset = 3;
sensorDataStopOffset = 5;
sensorTypeOffset = 1;
sensorIdxOffset = 0;
sensorTimestpNmeasOffset = 2;

% Below tables are populated according to enums defined in icub-firmware-shared/eth/embobj/plus/comm-v2/icub/EoAnalogSensors.h

% Matches sensorTypeT
% type_none          = 0;
% type_accelerometer = 1;
% type_gyroscope     = 2;
mtbType = {'_none','_acc','_gyro'};

% unique id for every possible inertial sensor positioned on iCub. So far we can host
% up to 63 different positions. The actual positions on iCub are documented on
% http://wiki.icub.org/wiki/Distributed_Inertial_sensing
%     eoas_inertial_pos_max_numberof = 63;
%
%     enum { eoas_inertial_pos_offsetleft = 0, eoas_inertial_pos_offsetright = 24, eoas_inertial_pos_offsetcentral = 48 };
%
%     typedef enum
%     {
%         eoas_inertial_pos_none                  = 0,
%
%         // left arm
%         eoas_inertial_pos_l_hand                = 1+eoas_inertial_pos_offsetleft,       // label 1B7    canloc = (CAN2, 14)
%         eoas_inertial_pos_l_forearm_1           = 2+eoas_inertial_pos_offsetleft,       // label 1B8    canloc = (CAN2, 12)
%         eoas_inertial_pos_l_forearm_2           = 3+eoas_inertial_pos_offsetleft,       // label 1B9    canloc = (CAN2, 13)
%         eoas_inertial_pos_l_upper_arm_1         = 4+eoas_inertial_pos_offsetleft,       // label 1B10   canloc = (CAN2,  9)
%         eoas_inertial_pos_l_upper_arm_2         = 5+eoas_inertial_pos_offsetleft,       // label 1B11   canloc = (CAN2, 11)
%         eoas_inertial_pos_l_upper_arm_3         = 6+eoas_inertial_pos_offsetleft,       // label 1B12   canloc = (CAN2, 10)
%         eoas_inertial_pos_l_upper_arm_4         = 7+eoas_inertial_pos_offsetleft,       // label 1B13   canloc = (CAN2,  8)
%         // left leg
%         eoas_inertial_pos_l_foot_1              = 8+eoas_inertial_pos_offsetleft,       // label 10B12  canloc = (CAN2, 13)
%         eoas_inertial_pos_l_foot_2              = 9+eoas_inertial_pos_offsetleft,       // label 10B13  canloc = (CAN2, 12)
%         eoas_inertial_pos_l_lower_leg_1         = 10+eoas_inertial_pos_offsetleft,      // label 10B8   canloc = (CAN2,  8)
%         eoas_inertial_pos_l_lower_leg_2         = 11+eoas_inertial_pos_offsetleft,      // label 10B9   canloc = (CAN2,  9)
%         eoas_inertial_pos_l_lower_leg_3         = 12+eoas_inertial_pos_offsetleft,      // label 10B10  canloc = (CAN2, 10)
%         eoas_inertial_pos_l_lower_leg_4         = 13+eoas_inertial_pos_offsetleft,      // label 10B11  canloc = (CAN2, 11)
%         eoas_inertial_pos_l_upper_leg_1         = 14+eoas_inertial_pos_offsetleft,      // label 10B1   canloc = (CAN1,  1)
%         eoas_inertial_pos_l_upper_leg_2         = 15+eoas_inertial_pos_offsetleft,      // label 10B2   canloc = (CAN1,  2)
%         eoas_inertial_pos_l_upper_leg_3         = 16+eoas_inertial_pos_offsetleft,      // label 10B3   canloc = (CAN1,  3)
%         eoas_inertial_pos_l_upper_leg_4         = 17+eoas_inertial_pos_offsetleft,      // label 10B4   canloc = (CAN1,  4)
%         eoas_inertial_pos_l_upper_leg_5         = 18+eoas_inertial_pos_offsetleft,      // label 10B5   canloc = (CAN1,  5)
%         eoas_inertial_pos_l_upper_leg_6         = 19+eoas_inertial_pos_offsetleft,      // label 10B6   canloc = (CAN1,  6)
%         eoas_inertial_pos_l_upper_leg_7         = 20+eoas_inertial_pos_offsetleft,      // label 10B7   canloc = (CAN1,  7)
%
%         // right arm
%         eoas_inertial_pos_r_hand                = 1+eoas_inertial_pos_offsetright,      // label 2B7    canloc = (CAN2, 14)
%         eoas_inertial_pos_r_forearm_1           = 2+eoas_inertial_pos_offsetright,      // label 2B8    canloc = (CAN2, 12)
%         eoas_inertial_pos_r_forearm_2           = 3+eoas_inertial_pos_offsetright,      // label 2B9    canloc = (CAN2, 13)
%         eoas_inertial_pos_r_upper_arm_1         = 4+eoas_inertial_pos_offsetright,      // label 2B10   canloc = (CAN2,  9)
%         eoas_inertial_pos_r_upper_arm_2         = 5+eoas_inertial_pos_offsetright,      // label 2B11   canloc = (CAN2, 11)
%         eoas_inertial_pos_r_upper_arm_3         = 6+eoas_inertial_pos_offsetright,      // label 2B12   canloc = (CAN2, 10)
%         eoas_inertial_pos_r_upper_arm_4         = 7+eoas_inertial_pos_offsetright,      // label 2B13   canloc = (CAN2,  8)
%         // right leg
%         eoas_inertial_pos_r_foot_1              = 8+eoas_inertial_pos_offsetright,      // label 11B12  canloc = (CAN2, 13)
%         eoas_inertial_pos_r_foot_2              = 9+eoas_inertial_pos_offsetright,      // label 11B13  canloc = (CAN2, 12)
%         eoas_inertial_pos_r_lower_leg_1         = 10+eoas_inertial_pos_offsetright,     // label 11B8   canloc = (CAN2,  8)
%         eoas_inertial_pos_r_lower_leg_2         = 11+eoas_inertial_pos_offsetright,     // label 11B9   canloc = (CAN2,  9)
%         eoas_inertial_pos_r_lower_leg_3         = 12+eoas_inertial_pos_offsetright,     // label 11B10  canloc = (CAN2, 10)
%         eoas_inertial_pos_r_lower_leg_4         = 13+eoas_inertial_pos_offsetright,     // label 11B11  canloc = (CAN2, 11)
%         eoas_inertial_pos_r_upper_leg_1         = 14+eoas_inertial_pos_offsetright,     // label 11B1   canloc = (CAN1,  1)
%         eoas_inertial_pos_r_upper_leg_2         = 15+eoas_inertial_pos_offsetright,     // label 11B2   canloc = (CAN1,  2)
%         eoas_inertial_pos_r_upper_leg_3         = 16+eoas_inertial_pos_offsetright,     // label 11B3   canloc = (CAN1,  3)
%         eoas_inertial_pos_r_upper_leg_4         = 17+eoas_inertial_pos_offsetright,     // label 11B5   canloc = (CAN1,  5)
%         eoas_inertial_pos_r_upper_leg_5         = 18+eoas_inertial_pos_offsetright,     // label 11B4   canloc = (CAN1,  4)
%         eoas_inertial_pos_r_upper_leg_6         = 19+eoas_inertial_pos_offsetright,     // label 11B6   canloc = (CAN1,  6)
%         eoas_inertial_pos_r_upper_leg_7         = 20+eoas_inertial_pos_offsetright,     // label 11B7   canloc = (CAN1,  7)
%
%         // central parts
%         eoas_inertial_pos_chest_1               = 1+eoas_inertial_pos_offsetcentral,    // 9B7
%         eoas_inertial_pos_chest_2               = 2+eoas_inertial_pos_offsetcentral,    // 9B8
%         eoas_inertial_pos_chest_3               = 3+eoas_inertial_pos_offsetcentral,    // 9B9
%         eoas_inertial_pos_chest_4               = 4+eoas_inertial_pos_offsetcentral,    // 9B10
%
%         eOas_inertial_pos_jolly_1               = 60,
%         eOas_inertial_pos_jolly_2               = 61,
%         eOas_inertial_pos_jolly_3               = 62,
%         eOas_inertial_pos_jolly_4               = 63
%
%     } eOas_inertial_position_t;

%% LUT of MTB IDs (LUT output) indexed by the MTB pos defined as the above enum (LUT input).
obj.mapMTBpos2code = {'none',...
    '1b7','1b8','1b9','1b10','1b11','1b12','1b13',...
    '10b12','10b13','10b8','10b9','10b10','10b11','10b1','10b2','10b3','10b4','10b5','10b6','10b7',...
    'none','none','none','none',...
    '2b7','2b8','2b9','2b10','2b11','2b12','2b13',...
    '11b12','11b13','11b8','11b9','11b10','11b11','11b1','11b2','11b3','11b5','11b4','11b6','11b7',...
    'none','none','none','none',...
    '9b7','9b8','9b9','9b10'};

%% check metadata is constant
%
% Get number of published sensor on the YARP port
nbSensors = yBuff(1,1);

% set of metadata offsets
sensorMetaOffsets = header_length+([1:nbSensors]-1)*sensorDataLength;

% check that metadata is constant through all the samples
allMetaDataIdx = [1:2 sensorMetaOffsets+1 sensorMetaOffsets+2];
if sum(yBuff(:,allMetaDataIdx) ~= yBuff(1,allMetaDataIdx)) > 0
    error('Metadata changed in MTB sensor YARP port stream !!!');
end

%% check and parse metadata fields
%
% version
if yBuff(1,2) ~= version
    error(['Wrong version (should be ' version ')']);
end

% Parse the MTB sensor pos. IDs and build the mapping to sensor labels.
obj.mapMTBlabel2position = containers.Map('KeyType','char','ValueType','any');
for offset = sensorMetaOffsets
    % parse the sensor position id
    mtbPos = yBuff(1,1+offset+sensorIdxOffset);
    % map it to the sensor code (ex: '10b1')
    mtbCode = obj.mapMTBpos2code{mtbPos+1}; % +1 because of matlab indexing
    % parse the sensor type '_acc' or '_gyro' then build the sensor label.
    mtbLabel = [mtbCode mtbType{yBuff(1,1+offset+sensorTypeOffset)+1}]; % +1 because of matlab indexing
    obj.mapMTBlabel2position(mtbLabel) = [num2str(1+offset+sensorDataStartOffset) ':' num2str(1+offset+sensorDataStopOffset)];
end

end
