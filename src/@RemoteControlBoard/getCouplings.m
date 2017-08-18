function [ couplingList ] = getCouplings( obj )
%This method retrieves the coupling parameters through the IRemoteVariables debug interface
%   For each set of actually coupled joints, a structure is built, holding:
%   - coupling.T : the coupling matrix 3x3 or just the integer 1
%   - coupling.cpldJoints : ordered list of coupled joint names
%   - coupling.cpldMotors : ordered list of coupled motor names

couplingList = JointMotorCoupling(); % TO BE IMPLEMENTED

end
