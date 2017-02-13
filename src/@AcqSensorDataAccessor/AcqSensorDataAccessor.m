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
        
        function [dataFolderPathList,calibedPartsList] = getFolderPaths(obj,sensor)
            for seqIdx = 1:numel(obj.sequences)
                % select next sequence
                sequence = obj.sequences{seqIdx};
                % get parts holding the calibrated sensors of modality 'sensor'
                calibedPartsList{seqIdx} = sequence.calib.part{ismember(sequence.calib.sensor,sensor)};
                % get the respective data folder
                dataFolderPathList{seqIdx} = sequence.seqDataFolderPath;
            end
        end
    end
    
end

