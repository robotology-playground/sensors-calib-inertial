classdef SequenceParams < handle
    %MotionSequencer input sequence parameters
    %   This class shapes parameters from a calibrator (part calibration
    %   motion and measurement parameters, calibration sequences
    %   definitions) into the format used by the MotionSequencer class.
    
    properties(Constant)
        % Dictionary translating any part sequence key to a set of labels
        % <calib|ctrl|meas>.<joint|acc|imu>.<part>
        % (Static property accessible from any object of the class)
        labelKeys2ActSensPart = containers.Map('KeyType','char','ValueType','any');
    end
    
    properties(SetAccess = protected, GetAccess = public)
        filteredSelector = struct();
        seqHomeParams = {};
        seqEndParams = struct();
        sequences = {};
    end
    
    methods(Access = public)
        function obj = SequenceParams(calibedParts,selector,seqHomeParams,seqEndParams)
            
            % Check that requested calibrated parts are handled
            if sum(~ismember(calibedParts,selector.calibedParts))>0
                error('...the part list is empty or at least one part in the list is not handled!');
            end
            
            % ==== Use selector for filtering sequence parameters of requested parts:
            % Filter selector tables keeping only parts requested for calibration
            filter = ismember(selector.calibedParts,calibedParts);
            filteredSelector = structfun(@(list) list(filter),selector,'UniformOutput',false);
            filteredSelector.seqParamsMap = cell(size(filteredSelector.seqParams));
            
            % From this point on, the list of parts to be calibrated is irrelevant. We
            % will index parameters by pos/part,vel/part and sensor/part keys, actually
            % required for feeding the control board driver and opening the right yarp
            % ports for dumping the sensor data (joints, accelerometers, gyros,
            % etc...).

            % save input parameters
            obj.filteredSelector = filteredSelector;
            obj.seqHomeParams = seqHomeParams;
            obj.seqEndParams = seqEndParams;
        end
        
        % Builds sequences in the MotionSequencer format
        sequences = buildMapSequences(obj);
    end
    
    methods(Access = protected)
        % Merges all maps into macro maps (1 macro map per sequence)
        seqParamsMapMerged = mergeMapSequences(obj);
    end
    
    methods(Static = true, Access = protected)
        seqMap = seqParams2map(calibedPart,calibedSensors,seqParams);
    end
    
end

