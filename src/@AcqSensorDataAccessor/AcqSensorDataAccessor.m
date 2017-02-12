classdef AcqSensorDataAccessor < handle
    %AcqSensorDataAccessor Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected)
        sequences = {};
    end
    
    methods(Access = public)
        function obj = AcqSensorDataAccessor(sequences)
            obj.sequences = sequences;
        end
    end
    
end

