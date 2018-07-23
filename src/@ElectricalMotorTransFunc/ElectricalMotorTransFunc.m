classdef ElectricalMotorTransFunc < handle
    %This class groups all the electrical motor transfer function parameters
    %   The transfer function parameters are:
    %   - Kpwm
    %   - Kbemf
    %   - offset
    %   The motor current equation is:
    %   i_m = kpwm * PWM + kbemf * dq_m'
    
    properties(GetAccess=public, SetAccess=protected)
        name@char;
        Kpwm = 0;
        Kbemf = 0;
        offset = 0;
    end
    
    methods(Access=protected)
        % Constructor
        function obj = ElectricalMotorTransFunc(motorName)
            obj.name = motorName;
        end
    end
    
    methods(Static=true, Access=public)
        function transFunc = GetMotorTransFunc(motorName,calibrationMap)
            if ~isKey(calibrationMap,motorName)
                calibrationMap(motorName) = ElectricalMotorTransFunc(motorName);
            end
            % Return the handle on the newly created or already existing
            % ElectricalMotorTransFunc object.
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
        
        function setKbemf(obj, Kbemf), obj.Kbemf = Kbemf; end
        
        function setOffset(obj,offset), obj.offset = offset; end
    end
    
end

