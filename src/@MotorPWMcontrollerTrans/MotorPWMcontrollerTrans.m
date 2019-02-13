classdef MotorPWMcontrollerTrans < MotorPWMcontroller
    %Controller for emulating position or velocity control through PWM settings.
    %   The function parameters are defined through the class constructor.
    
    properties (GetAccess=public, SetAccess=protected)
        mainMotorCtrllerThread@RateThread;
        pattern@MotionPatternGenerator;
    end
    
    properties
    end
    
    methods
        % Constructor
        function obj = MotorPWMcontrollerTrans(motorName,shape,freq,maxPwm,remCtrlBoardRemapper,threadActivation)
            obj@MotorPWMcontroller(motorName,remCtrlBoardRemapper,threadActivation);
            % Create the PWM transition function
            obj.pattern = MotionPatternGenerator();
            switch shape
                case 'triangle'
                    obj.pattern.setupTriangleNderivatives(0,freq,maxPwm,0);
                case 'offtrgle'
                    obj.pattern.setupTriangleNderivatives(5,freq,maxPwm,0);
                otherwise
                    error('Unknown trajectory pattern!!');
            end
        end
        
        % Destructor
        function delete(~)
        end
        
        % Start the controller. Refer to the method description in the parent class.
        % This method extends the parent class method by running the PWM pattern for the calibrated motor.
        ok = start(obj,plotterType);
    end
    methods (Access=protected)
        % Rate thread function for the main motor controller
        ok = runMainMotorController(obj,threadPeriod,threadTimeout);
        
        function ok = mainMotorCtrllerThreadStartFcn(obj)
            obj.pwmCtrledMotor.t0 = yarp.now();
            disp('Started!');
            ok = true;
        end
        
        function ok = mainMotorCtrllerThreadStopFcn(obj)
            obj.pwmCtrledMotor.pwm = 0;
            disp('Stoped!');
            ok = true;
        end
        
        function ok = mainMotorCtrllerThreadUpdateFcn(obj)
            pwm = obj.pattern.x(yarp.now()-obj.pwmCtrledMotor.t0);
            % Sets the PWM, either directly through the robot interface, or through the `ctrllerThread` thread handling
            % the coupled motors.
            ok = obj.setMotorPWM(pwm);
        end
    end
end
