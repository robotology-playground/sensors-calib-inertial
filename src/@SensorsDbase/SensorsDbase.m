classdef SensorsDbase < DataBase
    %SensorsDbase Implements a database with sensors parameters
    %   (inertial sensors,gyroscopes, FT sensors)
    
    properties
    end
    
    methods(Access = public)        % Constructor
        function obj = SensorsDbase(iDynTreeModelFromURDF)
            % create database
            propKeyList = {'sensorLabel','sensorHwId','sensorFrameName'};
            propNameList = {...
                'sensorLabel','sensorHwId','sensorFrameName',...
                'parentLink','framePose','part','fullscaleGain','calib'};
            % ...
        end
        
        % Get sensor labels identified by the set <part,sensorUiIDlist>.
        % 'sensorUiIDlist', along with part, is the UI set of parameters
        % identifying a unique sensor.
        % ex of returned sensor label: [11b3_acc]
        sensorLabelList = getSensorlabels(part,sensorUiIDlist);
        
        % Get the sensor frame (sensor ID within iDynTree context) from a
        % given sensor unique label.
        % ex of returned sensor frame: 'r_upper_leg_mtb_acc_11b3'
        sensorFrame = getSensorFrame(sensorLabel);
        
        % Get the sensor type from a given sensor unique label.
        % ex of returned sensor type: 'mtb_acc'
        sensorFrame = getSensorType(sensorLabel);
    end
    
end

