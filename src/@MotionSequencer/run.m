function acqSensorDataAccessor = run(obj)

import System.Const;

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
    % Skip this sequence if we are not actually acquiring data.
    if ~isempty(sequence.seqDataFolderPath)
        loggedSeqs = [loggedSeqs sequence];
    end
    
    for stepIdx = 1:size(sequence.ctrl.pos,1)
        % Get acquire flag from the sequence.
        % Stop logging of parts for which 'acquire' flag is off
        % Start logging of parts for which 'acquire' flag is on
        [sensors,partsToStop,partsToStart] = getSensorsParts4Pos(sequence,stepIdx);
        sequence.logCmd.stop(sensors,partsToStop);
        sequence.logCmd.start(sensors,partsToStart);
        
        % The following processing depends on the control mode
        switch sequence.mode{stepIdx}
            case 'ctrl'    % position control
                % Set joints in position control mode
                [jointsIdxList,~] = obj.ctrlBoardRemap.getJointsMappedIdxes(obj.ctrlBoardRemap.jointsList);
                obj.ctrlBoardRemap.setJointsControlMode(jointsIdxList,'ctrl');
                
                % get next position, velocity and acquire flag from the
                % sequence. Get concatenated matrices for all parts
                pos = sequence.ctrl.pos(stepIdx,:);
                vel = sequence.ctrl.vel(stepIdx,:);
                
                % run the sequencer step, while waiting for user
                % confirmation to proceed, or for motion to complete.
                promptString = sequence.prpt{stepIdx}();
                if isempty(promptString)
                    % run the sequencer step
                    waitMotionDone = true; timeout = 120; % in seconds
                    if ~obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel,waitMotionDone,timeout)
                        error('Waiting for motion done timeout!');
                    end
                else
                    % run the sequencer step
                    waitMotionDone = false; timeout = 0; % in seconds
                    if ~obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel,waitMotionDone,timeout)
                        error('Error while setting position!');
                    end
                    % Notify the user about ongoing step and prompt for
                    % completion confirmation before proceeding to next step
                    fprintf(promptString);
                    pause;
                end
                
            case 'pwmctrl' % PWM control
                % Only setting 1 motor or 1 set of coupled motors in PWM
                % control mode is supported.
                % Get name of motor to set in PWM control mode, as well as
                % the PWM value.
                motorName = sequence.pwmctrl.motor;
                pwm = sequence.pwmctrl.pwm{stepIdx};
                
                % Set the motor in PWM control mode and handle the coupled
                % motors keeping their control mode and state unchanged. If
                % this is not supported by the YARP remoteControlBoardRemapper,
                % emulate it. We can only emulate position control.
                pwmController = MotorPWMcontroller(motorName,obj.ctrlBoardRemap,Const.ThreadON);
                
                % Set the desired PWM level (0-100%) for the named motor
                ok = pwmController.setMotorPWM(pwm);
                
                % Prompt the user to proceed
                promptString = sequence.prpt{stepIdx}();
                if ~isempty(promptString)
                    fprintf(promptString);
                    pause;
                end
                
                % Stop the controller. This also restores the previous
                % control mode for the named motor and eventual coupled
                % motors.
                ok = pwmController.stop();
                
            otherwise
                error('Unknown control mode!');
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
% collected (or not, depending on the 'acquire' flag). An acquire set and
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
