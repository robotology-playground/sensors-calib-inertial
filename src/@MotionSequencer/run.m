function run(obj)

% process each sequence
for seqIdx = 1:size(obj.sequences,1)
    % get next sequence to run
    sequence = obj.sequences{seqIdx};
    
    % open ctrl board remapper driver
    obj.ctrlBoardRemap.open(sequence.ctrl.part);
    
    % request new log creation for current sequence
    logInfo = struct('ctrlApp',obj.ctrlApp,'seqIdx',seqIdx);
    [sensors,parts] = getSensorsParts4fullSeq(sequence);
    obj.logCmd.new(logInfo,sensors,parts);
    
    for posIdx = 1:size(sequence.ctrl.pos,1)
        % get next position, velocity and acquire flag from the
        % sequence. Get concatenated matrices for all parts
        pos = sequence.ctrl.pos(posIdx,:);
        vel = sequence.ctrl.vel(posIdx,:);
        
        % Stop logging of parts for which 'acquire' flag is off
        % Start logging of parts for which 'acquire' flag is on
        [sensors,partsToStop,partsToStart] = getSensorsParts4Pos(sequence,posIdx);
        obj.logCmd.stop(sensors,partsToStop);
        obj.logCmd.start(sensors,partsToStart);
        
        % run the sequencer step
        waitMotionDone = true; timeout = 120; % in seconds
        if ~obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel,waitMotionDone,timeout)
            error('Waiting for motion done timeout!');
        end
    end
    
    % Stop logging of last step and close log
    obj.logCmd.close();
    
    % close ctrl board remapper driver
    obj.ctrlBoardRemap.close();
end

end

function [sensors,parts] = getSensorsParts4fullSeq(sequence)

% return sensors and respective parts
sensors = sequence.meas.sensor;
parts = sequence.meas.part;

end

function [sensors,partsToStop,partsToStart] = getSensorsParts4Pos(sequence,posIdx)

sensors = sequence.meas.sensor;

[partsToStop,partsToStart] = cellfun(...
    @(partList,acquireList) [partList{acquireList{posIdx}},partList{~acquireList{posIdx}}],...
    sequence.meas.part,sequence.meas.acquire,...
    'UniformOutput',false);

end
