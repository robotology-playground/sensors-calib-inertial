classdef MotorTransFunc < handle
    %This class groups all the motor transfer function parameters
    %   The transfer function parameters are:
    %   - Ktau, gearboxRatio
    %   - KcP, KcN
    %   - KvP, KvN
    %   - stictionP, stictionN
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        Kpwm = 0;
        gearboxRatio = 1;
        KcP = 0;
        KcN = 0;
        KvP = 0;
        KvN = 0;
        stictionP = 0;
        stictionN = 0;
    end
    
    methods(Access=public)
        % Constructor
        function obj = MotorTransFunc(motorName)
            obj.name = motorName;
        end
        
        function setKpwm(obj,Kpwm), obj.Kpwm = Kpwm; end
        
        function setRatio(obj,ratio), obj.gearboxRatio = ratio; end
        
        function setFriction(obj,KcP, KcN, KvP, KvN)
            obj.KcP = KcP;
            obj.KcN = KcN;
            obj.KvP = KvP;
            obj.KvN = KvN;
        end
        
        function setStiction(obj,stictionP, stictionN)
            obj.tictionP = stictionP;
            obj.stictionN = stictionN;
        end
    end
    
end

