function run(obj)

% process each sequence
for seqIdx = 1:size(obj.sequences,1)
    % get next sequence to run
    sequence = obj.sequences{seqIdx};
    
    % open ctrl board remapper driver
    obj.ctrlBoardRemap.open(sequence.part);
    
    % request new log creation if current sequence logs any data
    if isLogRequired(sequence)
        obj.logCmd.new(sequence.part);
    end
    
    for posIdx = 1:size(sequence.pos,1)
        % get next position, velocity and acquire flag from the
        % sequence. Get concatenated matrices for all parts
        pos = cell2mat(sequence.pos(posIdx,:));
        vel = cell2mat(sequence.vel(posIdx,:));
        acquire = cell2mat(sequence.acquire(posIdx,:));
        
        % Stop logging of parts for which 'acquire' flag is off
        % Start logging of parts for which 'acquire' flag is on
        obj.logCmd.stop(sequence.part(~acquire));
        obj.logCmd.start(sequence.part(acquire));
        
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

function logRequired = isLogRequired(sequence)

% convert acquire cell array to 1-D matrix
acquireMat = cell2mat(sequence.acquire(:));
% count occurences of true
logRequired = sum(acquireMat)>0;

end
