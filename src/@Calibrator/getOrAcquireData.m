function getOrAcquireData(obj,init,lastAcqSensorDataAccessorMap)
% Gets stored sensor data or triggers a sensor data acquisition
% 
% Gets stored sensor data or triggers a sensor data acquisition for the
% scheduled task: acquisition of test data; data for calibrating the joint
% encoders, the accelerometers, or other sensors
% 
% [in] init :    application script init config parameters
% [in/out] lastAcqSensorDataAccessorMap :    last instances of acquired data accessors

% unwrap the parameters specific to joint encoders calibration
Init.unWrap(init.(obj.initSection));

switch sensorDataAcq{1}
    case 'new'
        % Acquire sensor measurements while moving the joints following
        % a profile defined by the task
        obj.acqSensorDataAccessorMap(obj.task) = SensorDataAcquisition.acquireSensorData(...
            obj.task,taskSpecificParams,init.robotName,init.dataPath,calibedParts);
        % save the acquired data info
        lastAcqSensorDataAccessorMap(obj.task) = obj.acqSensorDataAccessorMap(obj.task);
        
    case 'last'
        if isempty(lastAcqSensorDataAccessorMap)...
                || ~isKey(lastAcqSensorDataAccessorMap,obj.task)
            error(['No data has been acquired yet for the task ' obj.task ' !!']);
        end
        obj.acqSensorDataAccessorMap(obj.task) = lastAcqSensorDataAccessorMap(obj.task);
        
    otherwise
        load([init.dataPath '/dataLogInfo.mat'],'dataLogInfoMap');
        obj.acqSensorDataAccessorMap(obj.task) = dataLogInfoMap.get(sensorDataAcq{:});
end

end

