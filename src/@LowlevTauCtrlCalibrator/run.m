function run(obj,init,model,lastAcqSensorDataAccessorMap)
% Calibrates the sensors using the data accessed through 'lastAcqSensorDataAccessorMap'

% Init the state machine context
obj.init = init;
obj.model = model;
obj.lastAcqSensorDataAccessorMap = lastAcqSensorDataAccessorMap;

% Advanced interface parameters:
% - timeStart, timeStop, subSamplingSize
run lowLevTauCtrlCalibratorDevConfig;
obj.timeStart = timeStart;
obj.timeStop = timeStop;
obj.subSamplingSize = subSamplingSize;

% state machine starting state
obj.state.current = obj.stateStart;

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

% PHASE 1 - Calibrating Viscuous and Coulomb friction parameters
%
% 1 - set PWM to 0 for the selected joints/motors group
%
% 2 - move selected joints and acquire data:
% 	  => selected motors velocity
% 	  => selected joints measured torques
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
% PHASE 2 - Calibrating Ktau (PWM -> torque)
%
% 1 - reset calibrated joints/motors to position control
%
% 2 - move selected joints and acquire data:
% 	  => selected motors velocity
% 	  => selected motors PWM
% 	  => selected joints measured torques
%
% 3 - Plot acquired data
%
% 4 - fit the ktau model
%
% 5 - Plot fitted model over acquired data.

% Run state machine until reaching "end" state
while (obj.state.current ~= obj.stateEnd)
    % select current state structure with all respective functions
    currentState = obj.stateArray(obj.state.current);
    
    % Select and run function for processing current state actions
    currentState.currentProc();
    
    % Compute state dependant transition. Result will be among the
    % following: restart, proceed, skip, end, abort
    transition = currentState.transition();
    
    % Move to next state
    switch transition
        case 'ABORT'
            return;
        otherwise
            obj.state.current = currentState.(transition);
    end
end

end

