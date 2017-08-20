classdef JointMotorCoupling < handle
    %This class hold the coupling info for a set of joints/motors
    %   - coupling.T : the coupling matrix 3x3 or just the integer 1
    %   - coupling.cpldJoints : ordered list of coupled joint names
    %   - coupling.cpldMotors : ordered list of coupled motor names
    
    properties(GetAccess=public, SetAccess=protected)
        label@char = ''; % unique id of the coupling
        T = 0;           % coupling matrix
        cpldJoints = {}; % cell array of strings
        cpldMotors = {}; % cell array of motor names
        part = '';       % parent part of the coupled joints/motors
    end
    
    methods
        function obj = JointMotorCoupling(T, cpldJoints, cpldMotors, part)
            obj.T = T;
            obj.cpldJoints = cpldJoints;
            obj.cpldMotors = cpldMotors;
            obj.part = part;
            obj.label = [cpldJoints{:}];
        end
    end
    
end
