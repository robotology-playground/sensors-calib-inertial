function start( obj )
% Inits the state machine
% 
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

% Get the joint list to calibrate from UI
jointNameList = obj.getJointNamesFromUIidxes(obj.init,obj.model);

% Get the list of joint/motor couplings
obj.jointMotorCouplings = obj.model.jointsDbase.getJMcouplings(jointNameList);

% Select first group to calibrate
obj.state.currentJMcplgIdx = 1;

end
