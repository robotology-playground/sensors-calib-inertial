classdef MotorTransFunc < handle
    %This class groups all the motor transfer function parameters
    %   The transfer function parameters are:
    %   - Kpwm
    %   - KcP, KcN
    %   - KvP, KvN
    %   - stictionP, stictionN
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        Kpwm = 0;
        Kc = 0;
        Kv = 0;
        stictionP = 0;
        stictionN = 0;
    end
    
    methods(Access=protected)
        % Constructor
        function obj = MotorTransFunc(motorName)
            obj.name = motorName;
        end
    end
    
    methods(Static=true, Access=public)
        function transFunc = GetMotorTransFunc(motorName,calibrationMap)
            if ~isKey(calibrationMap,motorName)
                calibrationMap(motorName) = MotorTransFunc(motorName);
            end
            % Return the handle on the newly created or already existing
            % MotorTransFunc object.
            transFunc = calibrationMap(motorName);
        end
    end
    
    methods(Access=public)
        function setKpwm(obj,Kpwm), obj.Kpwm = Kpwm; end
        
        function setFriction(obj, Kc, Kv)
            obj.Kc = Kc;
            obj.Kv = Kv;
        end
        
        function setStiction(obj,stictionP, stictionN)
            obj.stictionP = stictionP;
            obj.stictionN = stictionN;
        end
    end
    
end

