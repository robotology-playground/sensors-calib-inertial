function setEncoders(obj,desiredPosMat,refType,refParamsMat)

% refType: 'refVel','refAcc'
% refParamsMat: reference velocities or accs
% depending on refType

% Check desired positions size
if length(desiredPosMat) ~= length(obj.jointsList)
    error('wrong input vector size!');
end
% Configure positions
ipos = obj.driver.viewIPositionControl();
desiredPositions = yarp.Vector(length(obj.jointsList));
desiredPositions.zero();
RemoteControlBoardRemapper.fromMatlab(desiredPositions,desiredPosMat);
% Set the reference vel or acc
refParams = yarp.Vector(length(obj.jointsList));
refParams.zero();
RemoteControlBoardRemapper.fromMatlab(refParams,refParamsMat);
switch refType
    case 'refVel'
        % Set ref speeds
        ipos.setRefSpeeds(refParams.data());
    case 'refAcc'
        % Set ref accelerations
        ipos.setRefAccelerations(refParams.data());
    otherwise
        error('Unsupported reference type');
end
% Run the motion
ipos.positionMove(desiredPositions.data());

end
