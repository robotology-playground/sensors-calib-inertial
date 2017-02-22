function acqSensorDataAccessor = run(obj)

% init logged sequences. These information will be needed by the calibrators for 
% retrieving the acquired data they require.
loggedSeqs = {};

% Schedule the logging of a new calibration iteration (for handling data
% logger counters)
obj.logCmd.sched();

% process each sequence
for seqIdx = 1:numel(obj.sequences)
    % get next sequence to run
    sequence = obj.sequences{seqIdx};
    
    % open ctrl board remapper driver
    obj.ctrlBoardRemap.open(sequence.ctrl.part);
    
    % request new log creation for current sequence
    
    % This info specifies for which calibration procedure the log can be
    % used for. Each calibedPart/calibedSensors pair points to a folder name
    % where to find the files for calibrating the sensors of modality
    % 'calibedSensor' on the part 'calibedPart'.
    logInfo = struct(...
        'calibApp',obj.calibApp,'calibedSensorList',{sequence.calib.sensor},...
        'calibedPartsList',{sequence.calib.part},'sequence',sequence);
    [sensors,parts] = getSensorsParts4fullSeq(sequence);
    % As the logger triggers a new data acquisition, it returns the
    % respective created folder. The folder path, along with the 'sequence'
    % information will be returned to the caller function for further use
    % by the calibrators.
    sequence.seqDataFolderPath = sequence.logCmd.new(logInfo,sensors,parts);
    % Skip this sequence if we are not actuall acquiring data.
    if ~isempty(sequence.seqDataFolderPath)
        loggedSeqs = [loggedSeqs sequence];
    end
    
    for posIdx = 1:size(sequence.ctrl.pos,1)
        % get next position, velocity and acquire flag from the
        % sequence. Get concatenated matrices for all parts
        pos = sequence.ctrl.pos(posIdx,:);
        vel = sequence.ctrl.vel(posIdx,:);
        
        % Stop logging of parts for which 'acquire' flag is off
        % Start logging of parts for which 'acquire' flag is on
        [sensors,partsToStop,partsToStart] = getSensorsParts4Pos(sequence,posIdx);
        sequence.logCmd.stop(sensors,partsToStop);
        sequence.logCmd.start(sensors,partsToStart);
        
        % run the sequencer step
        waitMotionDone = true; timeout = 120; % in seconds
        if ~obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel,waitMotionDone,timeout)
            error('Waiting for motion done timeout!');
        end
    end
    
    % Stop logging of last step and close log
    sequence.logCmd.close();
    
    % close ctrl board remapper driver
    obj.ctrlBoardRemap.close();
end

% Return sensor stored data information for the calibrators
acqSensorDataAccessor = AcqSensorDataAccessor(loggedSeqs);

end

function [sensors,parts] = getSensorsParts4fullSeq(sequence)

% return sensors and respective parts
sensors = sequence.meas.sensor;
parts = sequence.meas.part;

end

function [sensors,partsToStop,partsToStart] = getSensorsParts4Pos(sequence,posIdx)

% lists to be processed:
% each sensor is associated to a set of parts from where the sensor data is
% collected (or not depending on the 'acquire' flag). An acquire set and
% the parts set have the same dimensions.
sensorList = sequence.meas.sensor;
partSetList = sequence.meas.part;
acquireSetList = sequence.meas.acquire;

% process the lists
[sensors,partsToStop,partsToStart] = cellfun(...
    @(sensor,partSet,acquireSet) deal(...
    sensor,...                                 % 2-sensor (modality)
    partSet(~acquireSet(posIdx,:)),...           % 3-stop acquiring data from sensors on those parts
    partSet(acquireSet(posIdx,:))),...           % 4-start  acquiring data from sensors on those parts
    sensorList,partSetList,acquireSetList,...  % 1-for each sensor...
    'UniformOutput',false);                    % 5-don't concatenate lists from iterations
end
