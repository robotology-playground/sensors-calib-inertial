classdef SensorDataAcquisition
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static = true, Access = public)
        acqSensorDataAccessor = ...
            acquireSensorData(task,taskSpecificParams,robotName,dataPath,calibedParts);
        
        seqParams = setValFromGrid(gridParams,acqVel,transVel,labels);
    end
    
    methods(Static = true, Access = protected)
        [seqHomeParams,seqEndParams,selector] = getSeqProfile(task,taskSpecificParams);
    end
end

