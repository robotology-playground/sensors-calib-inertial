function [ ok, coupling, couplingPrevMode ] = setMotorPWMcontrolMode( obj,motorName )
%Set the motor in PWM control mode and handle the coupled motors.
%   handle the coupled motors keeping their control mode and state unchanged.
%   If this is not supported by the YARP remoteControlBoardRemapper, emulate
%   it. We can only emulate position control.

% Procedure success
ok = true;

% Get coupled motors/joints
couplings = obj.robotModel.jointsDbase.getJMcouplings('motors',{motorName});
coupling = couplings{1};

% Get current mode of coupled joints
[jointsIdxList,~] = obj.getJointsMappedIdxes(coupling.coupledJoints);
[ok,modes] = obj.getJointsControlMode(jointsIdxList);
couplingPrevMode = modes{1}; % All modes from a coupling are identical

% Set all coupled motors to PWM control mode.
ok = obj.setJointsControlMode(jointsIdxList,'pwmctrl');

% Processing depending on the mode
switch couplingPrevMode
    case 'TBD' % ctrl, but not fully implemented yet
        % Get the selected motor index
        jointName = obj.robotModel.jointsDbase.getCpldJointSharingIdx({motorName});
        motorIdx = obj.getJointsMappedIdxes(jointName);
        % Apply a high-level position control loop to these 2 motors
        % ...
    otherwise
        warningMessage = [...
            'setMotorPWMcontrolMode: previous mode was %s. For that mode we ' ...
            'don''t  support setting one single motor to PWM control while ' ...
            'emulating the previous mode for the others!'];
        warning(warningMessage,couplingPrevMode);
end

end
