classdef AcqSensorDataAccessor < handle
    %AcqSensorDataAccessor Retrieves the path to acquired data for its use in a calibrator
    %   We assume that the sensors of a given modality, from a given set of
    %   parts, are being calibrated and data from those sensors have been
    %   stored as N data sets through N acquisition sequences (MotionSequencer runner
    %   sequences). This class stores the sequences information required
    %   by the calibrators. For each sensor modality, 'getFolderPaths()'
    %   returns the list of data set folders and respective calibrated
    %   parts.
    
    properties(Access = protected)
        sequences = {}; % sequences information required by the calibrators
    end
    
    methods(Access = public)
        function obj = AcqSensorDataAccessor(sequences)
            obj.sequences = sequences;
        end
        
        % 'getFolderPaths()' returns the list of data set folders and respective
        % calibrated parts.
        function [dataFolderPathList,calibedPartsList] = getFolderPaths4calibedSensor(obj,sensor)
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

