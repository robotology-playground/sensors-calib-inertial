classdef MotorTransFunc < handle
    %This class groups all the motor transfer function parameters
    %   The transfer function parameters are:
    %   - Kpwm
    %   - KcP, KcN
    %   - KvP, KvN
    %   - stictionP, stictionN
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        % Kpwm, Kc and Kv actually already include the gearbox rate
        Kpwm = 0;
        Kc = 0;
        Kv = 0;
        stictionP = 0;
        stictionN = 0;
    end
    
    methods(Access=public)
        % Constructor
        function obj = MotorTransFunc(motorName)
            obj.name = motorName;
        end
        
        function setKpwm(obj,Kpwm), obj.Kpwm = Kpwm; end
        
        function setFriction(obj, Kc, Kv)
            obj.Kc = Kc;
            obj.Kv = Kv;
        end
        
        function setStiction(obj,stictionP, stictionN)
            obj.tictionP = stictionP;
            obj.stictionN = stictionN;
        end
    end
    
end

