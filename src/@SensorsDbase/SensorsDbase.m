classdef SensorsDbase < DataBase
    %SensorsDbase Implements a database with sensors parameters
    %   (inertial sensors,gyroscopes, FT sensors)
    
    properties(Constant = true, Access = protected)
        sensorCADtypes  = ...
            {'mtb_acc','mtb_gyro',...
            'ems_acc','ems_gyro',...
            'acc','gyro',...
            'imu_acc','ft_sensor'};
        cadType2idyn = containers.Map(SensorsDbase.sensorCADtypes,...
            {iDynTree.ACCELEROMETER,iDynTree.GYROSCOPE,...
            iDynTree.ACCELEROMETER,iDynTree.GYROSCOPE,...
            iDynTree.ACCELEROMETER,iDynTree.GYROSCOPE,...
            iDynTree.ACCELEROMETER,iDynTree.SIX_AXIS_FORCE_TORQUE});
        % Accelerometer (raw fullscale to m/s^2 conversion):
        % (fullscale in m/s^2)/(fullscale in raw) = (2*g)/(2^15) ~= 5.9855e-04
        % Gyroscope (raw fullscale to deg/s conversion):
        % (fullscale in dps)/(fullscale in raw) = (250)/(2^15) ~= 7.6274e-03
        % 
        % refer to http://wiki.icub.org/wiki/Distributed_Inertial_sensing
        cadType2gain = containers.Map(SensorsDbase.sensorCADtypes,...
            {5.9855e-04,7.6274e-03,...
            5.9855e-04,7.6274e-03,... % TO BE REVIEWED
            1,1,...
            1,1});                    % TO BE REVIEWED
    end
    
    properties(Access = protected)
        iDynTreeSensors;
    end
    
    methods(Access = public)        % Constructor
        function obj = SensorsDbase(iDynTreeSensorsFromURDF,link2partH)
            % create database
            propKeyList = {'sensorLabel','sensorHwId','sensorFrameName'};
            propNameList = {...
                'sensorLabel','sensorHwId','sensorFrameName',...
                'iDynObject','cadType','parentLink','parentLinkIdx','sensorFramePose','part','fullscaleGain'};
            nbAccs = iDynTreeSensorsFromURDF.getNrOfSensors(iDynTree.ACCELEROMETER);
            nbGyros = iDynTreeSensorsFromURDF.getNrOfSensors(iDynTree.GYROSCOPE);
            propValueList = cell(nbAccs+nbGyros,length(propNameList));
            
            % Set 'propValueList' with the properties from the iDynTree model
            propValueLineIdx = 1;
            for sensorTypeC = {iDynTree.ACCELEROMETER,iDynTree.GYROSCOPE}
                % Get type, number of sensors, and init list
                sensorType = cell2mat(sensorTypeC);
                nbSensors = iDynTreeSensorsFromURDF.getNrOfSensors(sensorType);
                % loop over sensors of same type
                for sensorIdx = 0:nbSensors-1
                    % get native parameters
                    [iDynObject,sensorFrameName,parentLink,parentLinkIdx,sensorFramePose] = ...
                        SensorsDbase.getSensorProps(iDynTreeSensorsFromURDF,sensorType,sensorIdx);
                    
                    % post-process parameters
                    sensorHwId = SensorsDbase.frame2hwId(sensorFrameName);
                    cadType = SensorsDbase.frame2cadType(sensorFrameName);
                    sensorLabel = [cadType '_' sensorHwId];
                    fullscaleGain = SensorsDbase.cadType2gain(cadType);
                    part = link2partH(parentLink); % part to witch the parent link is attached
                    
                    % fill the properties list
                    propValueList(propValueLineIdx,:) = {...
                        sensorLabel,sensorHwId,sensorFrameName,...
                        iDynObject,cadType,parentLink,parentLinkIdx,sensorFramePose,part,fullscaleGain};
                    
                    % increment pointer
                    propValueLineIdx = propValueLineIdx+1;
                end
            end
            clear propValueLineIdx; % clear counter
            
            % create and build database
            obj = obj@DataBase('keys',propKeyList,'names',propNameList,'values',propValueList);
            obj.build();
            
            % save iDynTree sensors object
            obj.iDynTreeSensors = iDynTreeSensorsFromURDF;
        end
        
        % Get sensor labels identified by the set <part,sensorUiIDlist>.
        % 'sensorUiIDlist', along with part, is the UI set of parameters
        % identifying a unique sensor.
        % ex of returned sensor label: [11b3_acc]
        sensorLabelList = getSensorlabels(obj,part,sensorUiIDlist);
        
        % Get the sensor frame (sensor ID within iDynTree context) from a
        % given sensor unique label.
        % ex of returned sensor frame: 'r_upper_leg_mtb_acc_11b3'
        sensorFrameList = getSensorFrames(obj,sensorLabelList);
        
        % Get the sensor type from a given sensor unique label.
        % Known returned sensor types:
        % 'mtb_acc','imu_acc','ems_acc','mtb_gyro','ems_gyro'.
        sensorTypeList = getSensorCadTypes(obj,sensorLabelList);
        
        % Get the sensor gain from a given sensor unique label. Even if we
        % usually get the same gain for all sensors of a given type, we
        % consider the possibiity to have  specific gain for each sensor
        % (for instance each IMU).
        fullscaleGainList = getSensorFullscaleGains(obj,sensorLabelList);
    end
    
    methods(Static=true, Access=public)
        sensorHwId = frame2hwId(sensorFrameName);
    end
    
    methods(Static=true, Access=protected)
        [iDynObject,sensorFrameName,parentLink,sensorFramePose,fullscaleGain] = ...
            getSensorProps(iDynTreeSensorsFromURDF,sensorType,sensorIndex);
        
        cadType = frame2cadType(sensorFrameName);
    end
end

