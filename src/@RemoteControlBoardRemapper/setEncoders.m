function [ ok ] = setEncoders(obj,desiredPosMat,refType,refParamsMat,wait,varargin)

% refType: 'refVel','refAcc'
% refParamsMat: reference velocities or accs
% depending on refType
% wait: if 'true' wait for the motion to be completed
% varargin: waitMotionDone() input parameters
% return value (ok): 'true' if joints reach the targetted position
% before timeout.
% Check desired positions size

% Concatenate desired positions matrices, as per IPositionControl interface 
% specification. Same for velocities.
desiredPosMat = [desiredPosMat{:}];
refParamsMat = [refParamsMat{:}];

if isempty(refParamsMat)
    switch refType
        case 'refVel'
            refParamsMat = repmat(obj.defaultSpeed,size(desiredPosMat));
        case 'refAcc'
            refParamsMat = repmat(obj.defaultAcc,size(desiredPosMat));
        otherwise
            error('Unsupported reference type');
    end
end

ok = true; % default value

if length(desiredPosMat) ~= length(obj.jointsList)
    error('wrong input vector size!');
end
% Configure positions
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
        obj.ipos.setRefSpeeds(refParams.data());
    case 'refAcc'
        % Set ref accelerations
        obj.ipos.setRefAccelerations(refParams.data());
    otherwise
        error('Unsupported reference type');
end
% Run the motion
obj.ipos.positionMove(desiredPositions.data());

% Wait for motion completion
if wait
    ok = obj.waitMotionDone(varargin{:});
end

end
