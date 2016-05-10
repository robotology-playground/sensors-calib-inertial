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
        visualize   = {};
        parsedParams    ;
        
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
        
        function addMTBsensToData(obj, part, frames, mtbSensorCodes, mtbSensorLinks, sensorActs, invertedFrames, visualize)
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
            HEADER_LENGTH = 2;
            FULL_ACC_SIZE = 6;
            LIN_ACC_1RST_IDX = 4;
            LIN_ACC_LAST_IDX = 6;
            
            for iter = frames
                %ADDSENSTODATA Add a sensor to the data structure
                % there is no naming convention yet. ex of sensor frame: [r_upper_leg_mtb_acc_11b3]
                % ex of sensor label: [11b3_acc]
                obj.addSensToData(part, ...
                                  strcat(mtbSensorLinks{iter},'_mtb_acc_',mtbSensorCodes{iter}), ...
                                  strcat(mtbSensorCodes{iter},'_acc'), ...
                                  sensorActs{iter}, ...
                                  invertedFrames{iter}, ...
                                  3, ...
                                  strcat(num2str(HEADER_LENGTH+FULL_ACC_SIZE*(iter-1)+LIN_ACC_1RST_IDX), ...
                                  ':',num2str(HEADER_LENGTH+FULL_ACC_SIZE*(iter-1)+LIN_ACC_LAST_IDX)), ...
                                  'inertialMTB', ...
                                  visualize && obj.plot);
            end
        end

        function addEncSensToData(obj, part, visualize)
            obj.addSensToData(part, ...
                              '', ...
                              strcat(part,'_state'), ...
                              true, ...
                              false, ...
                              6, ...
                              '1:6', ...
                              'stateExt:o', ...
                              visualize && obj.plot);
        end
        
    end
end
