classdef MotorPWMcontrollerTrans < MotorPWMcontroller
    %Controller for emulating position or velocity control through PWM settings.
    %   The function parameters are defined through the class constructor.
    
    properties (Access=protected)
        pattern@MotionPatternGenerator;
    end
    
    properties
    end
    
    methods
        % Constructor
        function obj = MotorPWMcontrollerTrans(motorName,freq,maxPwm,remCtrlBoardRemapper,threadActivation)
            obj@MotorPWMcontroller(motorName,remCtrlBoardRemapper,threadActivation);
            % Create the PWM transition  function
            obj.pattern = MotionPatternGenerator();
            obj.pattern.setupTriangleNderivatives(freq,maxPwm,0);
        end
        
        % Destructor
        function delete(obj)
        end
    end
    methods (Access=protected)
        % Rate thread function for the controller
        ok = ctrllerThreadUpdateFcn(obj,ctrllerThreadStop,rateThreadPeriod,PIDCtrller);
    end
end
