function run(obj,init,model,lastAcqSensorDataAccessorMap)
% Calibrates the sensors using the data accessed through 'lastAcqSensorDataAccessorMap'

% Debug mode
if obj.isDebugMode
    dispParamsNstate = @(calibrator,messageCompl) debugDisp(calibrator,messageCompl);
else
    dispParamsNstate = @(calibrator,messageCompl) [];
end

% Init the state machine context
obj.init = init;
obj.model = model;
obj.lastAcqSensorDataAccessorMap = lastAcqSensorDataAccessorMap;

% Advanced interface parameters:
% - timeStart, timeStop, subSamplingSize
run lowLevCtrlCalibratorDevConfig;
obj.timeStart = timeStart;
obj.timeStop = timeStop;
obj.subSamplingSize = subSamplingSize;
obj.filtParams = filtParams;

% state machine starting state
obj.state.current = S.stateStart;

% The calibration requires a mapping between the joint names and a
% structure containing:
% - a cell array of references to `MotorFriction` objects. Each joint is associated
%   to a list of coupled motors, and the respective friction `MotorFriction` object.
%
% - a list containing the name of the other joints coupled with the element-joint
%
% - the coupling matrix T (which can be eventually 1 in case of decoupled joints).
%
% The class RobotModel already provides model parameters extracted from
% the URDF model file and iDynTree library API. It shall also provide the
% coupled joints and motor friction information described above, as a list
% of joint groups. Each group can either hold a single joint or a list of
% coupled joints and respective motors:
%
% group(i).coupledJoints : list of joint names (size 1 or n)
% group(i).coupledMotors : list of MotorFriction object handles (same size)
% group(i).T             : 3x3 matrix or integer 1
%

%% For each joint/motor group do the following 2 phases
%

% PHASE 1 - Calibrating back electromotive force friction parameter
%
% 1 - set PWM to 0 for the selected joints/motors group
%
% 2 - move selected joints and acquire data:
% 	  => selected motors velocity
% 	  => selected joints measured currents
% 	  The data is expected to have as many ROWS as the number of joints.
%     The order MUST be the same as in jointMotorCoupling.coupledJoints (dim 1)
%     and jointMotorCoupling.coupledMotors (dim 2).
%
% 3 - Plot acquired data
%
% 4 - fit the friction model
%
% 5 - Plot fitted model over acquired data.
%
%
% PHASE 2 - Calibrating Kcurr (PWM -> current)
%
% 1 - reset calibrated joints/motors to position control
%
% 2 - move selected joints and acquire data:
% 	  => selected motors velocity
% 	  => selected motors PWM
% 	  => selected joints measured currents
%
% 3 - Plot acquired data
%
% 4 - fit the kcurr model
%
% 5 - Plot fitted model over acquired data.

% Run state machine until reaching "end" state
while (obj.state.current ~= S.stateEnd)
    % select current state structure with all respective functions
    currentState = obj.stateArray(obj.state.current);
    
    % Select and run function for processing current state actions
    currentProcH = currentState.currentProc(obj);
    currentProcH();
    
    % Compute state dependant transition. Result will be among the
    % following: restart, proceed, skip, end, abort
    transitionH = currentState.transition(obj);
    transition = transitionH();
    obj.state.transition = transition;
    
    % In debug mode, display init params and state before the transition
    dispParamsNstate(obj,'before transition');
    
    % Move to next state
    switch transition
        case 'ABORT'
            return;
        otherwise
            % Do transition dependent processing
            transitionProcH = currentState.([transition 'Proc'])(obj);
            transitionProcH();
            % Compute new state
            obj.state.current = currentState.(transition);
    end
    
    % In debug mode, display init params and state after the processing
    dispParamsNstate(obj,'after transition');
end

end

%============================================================

function debugDisp(calibrator,messageCompl)

initSection = calibrator.init.(calibrator.initSection);

if [...
        isfield(initSection.taskSpecificParams,{'motorName','frictionOrKcurr'}), ...
        isfield(initSection,'calibedParts')]
    fprintf([...
        '========== input params ==========\n'...
        '%s\n%s\n'],...
        initSection.taskSpecificParams.motorName,...
        initSection.taskSpecificParams.frictionOrKcurr);
    disp(initSection.calibedParts);
end

fprintf('========== state %s ==========\n',messageCompl);

disp(calibrator.state);

pause;

end
