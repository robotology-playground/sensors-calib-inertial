classdef SensorsData < handle
    % A SensorsData class object holds all the data capture and sensors parameters
    % like:
    % - data start and end timestamps
    % - number of samples
    % - data capture file path
    % - sensors (accelerometers) ids as per iDynTree name convention
    % - sensor frame invertion and sensor activation flags
    % - type of sensors (encoder, accelerometer, FT sensor, ...)
    % - measurements dimensions
    %
        
    properties (SetAccess = public, GetAccess = public)
        %% main input parameters
        path         ;
        dataSetNb    ;
        nSamples  = 0; %number of samples
        plot      = 0;
        tInit     = 0;    %seconds to be skipped at the start
        tEnd      = 0;    %seconds to reach the end of the movement
        diff_imu  = 0;    %derivate the angular velocity of the IMUs
        diff_q    = 0;    %derivate the angular velocity of the IMUs
        %% parsed parameters from files and model
        parts       = {};
        labels      = {};
        frames      = {};
        sensorAct   = {};
        isInverted  = {};
        ndof        = {};
        index       = {};
        type        = {};
        gain        = {};
        visualize   = {};
        parsedParams    ;
        %% parsers for each type of sensor
        offsetMTB   = [2 6 4 6];
        offsetMTI   = [0 12 4 6];
    end
    
    methods
        function obj = SensorsData(dataPath, dataSetNb, nSamples, tInit, tEnd, plot)
            %% main input parameters
            obj.path = dataPath;
            obj.dataSetNb = dataSetNb;
            obj.nSamples = nSamples;
            obj.tInit = tInit;
            obj.tEnd = tEnd;
            obj.plot = plot;
            %% parsed parameters from files and model
        end
        
        function addMTXsensToData(obj, part, frames, mtbSensorCodes, mtbSensorLinks, sensorActs, invertedFrames, mtxSensorTypes, visualize)
            %% define offsets for parsing Linear Acceleration data from MTB accelerometers
            %
            % Refer to wiki:
            % https://github.com/robotology/codyco-modules/wiki/External-Inertial-Sensors-for-iCubGenova02
            %
            % a = (n  6.0  (a1  b1 t1 x1 y1 z1)   .... (an  bn tn xn yn xn))
            % n  = number of sensors published on the port
            % ai = pos of sensor ... see enum type
            % bi = accel (1) or gyro (2)
            % ti = ?
            %
            % | size  | 1 |  1  |   6  |            6           | ...
            % | offset| 1 |  2  | 3..8 |2+6*(i-1)+1..2+6*(i-1)+6| ...
            % | Field | n | 6.0 |a1..z1| ai  bi  ti  xi  yi  zi | ...
            % 
            % header_length = 2;
            % full_acc_size = 6;
            % lin_acc_first_idx = 4;
            % lin_acc_last_idx = 6;
            %
            % => defined in offsetMTB[]
            %
            %
            %% define offsets for parsing Linear Acceleration data from the Head IMU
            %
            % Refer to wiki:
            % http://eris.liralab.it/wiki/Inertial_Sensor
            %
            % The output consists in 12 double, organized as follows:
            % 
            % euler angles [3]: deg
            % linear acceleration [3]: m/s^2
            % angular speed [3]: deg/s (* see note1)
            % magnetic field [3]: arbitrary units
            %
            % header_length = 0;
            % full_acc_size = 12;
            % lin_acc_first_idx = 4;
            % lin_acc_last_idx = 6;
            %
            % => defined in offsetMTI[]
            %
            %% offsets selectors:
            HEADER_LENGTH = 1;
            FULL_ACC_SIZE = 2;
            LIN_ACC_1RST_IDX = 3;
            LIN_ACC_LAST_IDX = 4;

            for iter = frames
                %ADDSENSTODATA Add a sensor to the data structure
                % there is no naming convention yet. ex of sensor frame: [r_upper_leg_mtb_acc_11b3]
                % ex of sensor label: [11b3_acc]
                switch mtxSensorTypes{iter}
                    case 'inertialMTI'
                        offset = obj.offsetMTI;
                        frameTag = '_mti_acc_';
                        acc_gain = 1;
                    case 'inertialMTB'
                        offset = obj.offsetMTB;
                        frameTag = '_mtb_acc_';
                        acc_gain = 5.9855e-04;
                    otherwise
                        disp('Unknown sensor type !!')
                end
                
                indexList = strcat(num2str(offset(HEADER_LENGTH)+offset(FULL_ACC_SIZE)*(iter-1)+offset(LIN_ACC_1RST_IDX)), ...
                    ':',num2str(offset(HEADER_LENGTH)+offset(FULL_ACC_SIZE)*(iter-1)+offset(LIN_ACC_LAST_IDX)));
                
                obj.addSensToData(part, ...
                                  strcat(mtbSensorLinks{iter},frameTag,mtbSensorCodes{iter}), ...
                                  strcat(mtbSensorCodes{iter},'_acc'), ...
                                  sensorActs{iter}, ...
                                  invertedFrames{iter}, ...
                                  3, ...
                                  indexList, ...
                                  mtxSensorTypes{iter}, ...
                                  acc_gain, ...
                                  visualize && obj.plot);
            end
        end

        function addEncSensToData(obj, part, jointsNdofs, jointsIdxes, visualize)
            obj.addSensToData(part, ...
                              '', ...
                              strcat(part,'_state'), ...
                              true, ...
                              false, ...
                              jointsNdofs, ...
                              jointsIdxes, ...
                              'stateExt:o', ...
                              1, ...
                              visualize && obj.plot);
        end
        
    end
end