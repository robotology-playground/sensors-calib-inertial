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
        nSamples  = 0; %number of samples
        plot      = 0;
        tInit     = 0;    %seconds to be skipped at the start
        tEnd      = 0;    %seconds to reach the end of the movement
        diff_imu  = 0;    %derivate the angular velocity of the IMUs
        diff_q    = 0;    %derivate the angular velocity of the IMUs
        calibrationMap;
        filtParams;
        
        %% parsed parameters from files and model
        parts       = {};
        labels      = {};
        frames      = {};
        ndof        = {};
        index       = {};
        
        %<For mapping MTB pos ids (as they appear in the YARP port
        % metadata) to MTB labels. These tables are built when loading the
        % sensor data.
        mapMTBpos2code = {};
        mapMTBlabel2position = {}; %>
        mapIMUlabel2position = {}; % for parsing IMU data
        
        type        = {};
        calib       = {};
        visualize   = {};
        parsedParams    ;
        
        nrOfMTBAccs = 0; % total number of activated MTB acc. or IMU acc.
    end
    
    methods
        function obj = SensorsData(dataPath, nSamples, tInit, tEnd, plot, varargin)
            % conditional parameter varargin:
            % calibrationMap, filtParams
            %
            if nargin>6 && length(varargin{1})>0
                obj.calibrationMap = varargin{1};
            else
                obj.calibrationMap = containers.Map('KeyType','char','ValueType','any');
            end
            if nargin>7 && length(varargin{2})>0
                obj.filtParams = varargin{2};
            else
                filtParams.type = 'sgolay';
                filtParams.sgolayK = 5;
                filtParams.sgolayF = 601;
                obj.filtParams = filtParams;
            end
            % main input parameters
            obj.path = dataPath;
            obj.nSamples = nSamples;
            obj.tInit = tInit;
            obj.tEnd = tEnd;
            obj.plot = plot;
        end
        
        function addMTXsensToData(obj, sensorsDbase, part, sensorLabels, visualize)
            % Number of activated sensors for current part
            obj.nrOfMTBAccs = obj.nrOfMTBAccs + numel(sensorLabels);
            
            for cLabel = sensorLabels(:)'
                % Get sensor label frame and type. There is no naming
                % convention yet.
                % ex of sensor frame: [r_upper_leg_mtb_acc_11b3]
                % ex of sensor label: [11b3_acc]
                sensorLabel = cell2mat(cLabel);
                sensorFrame = cell2mat(sensorsDbase.getSensorFrames(sensorLabel));
                sensorType = cell2mat(sensorsDbase.getSensorCadTypes(sensorLabel));
                % WORKAROUND begin
                switch sensorType
                    case 'mtb_acc'
                        sensorType = 'inertialMTB';
                    case 'imu_acc'
                        sensorType = 'inertial';
                    case {'ems_acc','mtb_gyro','ems_gyro'}
                        error('Not yet supported type!');
                    otherwise
                        error('Unsupported type!');
                end
                % WORKAROUND end
                
                % get calibration for this sensor
                if isKey(obj.calibrationMap,sensorFrame)
                    calibMap = obj.calibrationMap(sensorFrame);
                else
                    calibMap.centre=[0 0 0]'; calibMap.radii=[1 1 1]';
                    calibMap.quat=[1 0 0 0]'; calibMap.R=eye(3);
                    calibMap.C=eye(3); % calibration matrix
                end
                
                % Get the fullscale gain (raw fullscale to m/s^2 conversion)
                calibMap.gain=cell2mat(sensorsDbase.getSensorFullscaleGains(sensorLabel));
                
                % Add a sensor to the data structure.
                obj.addSensToData(  part, ...
                    sensorFrame, ...
                    sensorLabel, ...
                    3, ...
                    [], ...
                    sensorType, ...
                    calibMap, ...
                    visualize && obj.plot);
            end
        end

        function addEncSensToData(obj, ~, part, jointsNdofs, ctrledJointsIdxes, visualize)
            % define joint calibration string
            mapKey = strcat('jointsOffsets_',part);
            % get calibration for the joint encoders of this part
            if isKey(obj.calibrationMap,mapKey)
                calibMap = obj.calibrationMap(mapKey);
            else
                calibMap = 0;
            end
            
            obj.addSensToData(part, ...
                              '', ...
                              strcat(part,'_state'), ...
                              jointsNdofs, ...
                              ctrledJointsIdxes, ...
                              'stateExt:o', ...
                              calibMap, ...
                              visualize && obj.plot);
        end
        
        function setCalibrationMap(obj, calibrationMap)
            obj.calibrationMap = calibrationMap;
        end
        
    end
end
