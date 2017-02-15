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
            [dataFolderPathList,calibedPartsList] = cellfun(...
                @(sequence) deal(...           % 1-for each sequence...
                sequence.seqDataFolderPath,... % 2-get the respective data folder
                ... % 3-get parts holding the calibrated sensors of modality 'sensor'
                sequence.calib.part{ismember(sequence.calib.sensor,sensor)}),...
                obj.sequences,'UniformOutput',false);
        end
        
        function [measedSensorLists,measedPartsLists] = getMeasedSensorsParts(obj)
            [measedSensorLists,measedPartsLists] = cellfun(...
                @(sequence) deal(...        % 1-for each sequence...
                sequence.meas.sensor,...    % 2-get the list of sensors
                sequence.meas.part),...      % 3-get the list of parts for each sensor
                obj.sequences,'UniformOutput',false);
        end
    end
    
end

