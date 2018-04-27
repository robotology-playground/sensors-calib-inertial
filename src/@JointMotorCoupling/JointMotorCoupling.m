classdef JointMotorCoupling < handle
    %This class hold the coupling info for a set of joints/motors
    %   - coupling.T : the coupling matrix 3x3 or just the integer 1
    %   - coupling.coupledJoints : ordered list of coupled joint names
    %   - coupling.coupledMotors : ordered list of coupled motor names
    
    properties(GetAccess=public, SetAccess=protected)
        label@char = ''; % unique id of the coupling
        Tm2j = 1;           % coupling matrix
        Tj2m = 1;           % inverted coupling matrix
        coupledJoints = {}; % cell array of strings
        coupledMotors = {}; % cell array of motor names
        gearboxDqM2Jratios = []; % array of motors gearbox ratios
        fullscalePWMs = [];  % array of motors PWM fullscale values
        part = '';       % parent part of the coupled joints/motors
    end
    
    methods
        function obj = JointMotorCoupling(...
                Tm2j, cpldJoints, cpldMotors, ...
                cpldGearboxDqM2Jratios, cpldFullscalePWMs, part)
            
            obj.Tm2j = Tm2j;
            obj.Tj2m = inv(Tm2j);
            obj.coupledJoints = cpldJoints(:)';
            obj.coupledMotors = cpldMotors(:)';
            obj.gearboxDqM2Jratios = cpldGearboxDqM2Jratios(:)';
            obj.fullscalePWMs = cpldFullscalePWMs(:)';
            obj.part = part;
            obj.label = [obj.coupledJoints{:}];
        end
    end
    
    methods(Static)
        % Get all motor names from the couplings list
        motorNameList = getMotorsFromList(jmCouplings);
        
        % Get part name from each joint/motor coupling
        parts = getPartsFromList(jmCouplings);
    end
    
end
