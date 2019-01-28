classdef FullMotorTransFunc < handle
    %This class groups all the motor transfer function parameters
    %   The transfer function parameters are:
    %   - Kpwm
    %   - KcP, KcN
    %   - KvP, KvN
    %   - stictionP, stictionN
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        Kpwm = 0; % pwm to torque [Nm / dutycycle]
        Kc = 0; % Coulomb Friction [Nm]
        Kv = 0; % back-emf + mechanical friction [Nm * (rad/s)^-1]
        stictionP = 0;
        stictionN = 0;
        currOffset = 0; % current offset [A]
        Kcurr = 0; % pwm to current [A / dutycycle]
        Kbemf = 0; % back-emf [A * (rad/s)^-1]
        Ktau = 0; % current to torque [Nm / A]
        Kvmech = 0; % mechanical friction [Nm * (rad/s)^-1]
    end
    
    methods(Access=protected)
        % Constructor
        function obj = FullMotorTransFunc(motorName)
            obj.name = motorName;
        end
    end
    
    methods(Static=true, Access=public)
        function transFunc = GetMotorTransFunc(motorName,calibrationMap)
            if ~isKey(calibrationMap,motorName)
                calibrationMap(motorName) = FullMotorTransFunc(motorName);
            end
            % Return the handle on the newly created or already existing
            % FullMotorTransFunc object.
            transFunc = calibrationMap(motorName);
        end
        
        function isEq = eq(aTransFunc,anotherTransFunc)
            isEq = true;
            for field = fieldnames(aTransFunc)'
                if ischar(aTransFunc.(field{1}))
                    isEq = isEq && strcmp(aTransFunc.(field{1}),anotherTransFunc.(field{1}));
                elseif isnumeric(aTransFunc.(field{1}))
                    isEq = isEq && aTransFunc.(field{1}) == anotherTransFunc.(field{1});
                end
            end
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
        
        function setKcurr(obj,Kcurr), obj.Kcurr = Kcurr; end
        
        function setKbemf(obj, Kbemf), obj.Kbemf = Kbemf; end
        
        function setCurrOffset(obj,currOffset), obj.currOffset = currOffset; end
        
        function setKtau(obj,Ktau), obj.Ktau = Ktau; end
        
        function setKvmech(obj,Kvmech), obj.Kvmech = Kvmech; end
        
        function computeKtau(obj)
            if not(obj.Kcurr == 0)
                obj.Ktau = obj.Kpwm / obj.Kcurr;
            else
                warning('FullMotorTransFunc: Impossible to compute Ktau, Kcurr=0');
            end
        end
        
        function computeKvmech(obj, GDqM2Jratio)
            obj.Kvmech = obj.Kv * GDqM2Jratio - obj.Ktau * obj.Kbemf;
        end
    end
    
end

