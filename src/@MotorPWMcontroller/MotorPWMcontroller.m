classdef MotorPWMcontroller < handle
    %Controller for emulating position or velocity control through PWM settings.
    %   The function and execution rate is defined through the class constructor.
    
    properties (Access=protected)
    end
    
    properties (GetAccess=public, SetAccess=protected)
        % control board remapper
        remCtrlBoardRemap@RemoteControlBoardRemapper;
        % controlled motor and respective coupling info
        ctrledMotor@struct;
        coupling@JointMotorCoupling;
        % Last state before switching to PWM control emulating Pos control
        couplingPrevMode@char;
        lastMotorsPos@double;
        lastMotorsPwm@double;
        % PID gains and real time synchronization
        ctrllerThread@RateThread;
        ctrllerThreadPeriod@double;
        pidGains@struct;
        % Mask to de/activate position control emulation motor wise
        posCtrlMotorsMask@double;
    end
    
    methods
        % Constructor
        function obj = MotorPWMcontroller(motorName,remCtrlBoardRemapper)
            % set properties
            obj.ctrledMotor.name = motorName;
            obj.ctrledMotor.idx = remCtrlBoardRemapper.getMotorsMappedIdxes({motorName});
            obj.ctrledMotor.pwm = 0;
            obj.remCtrlBoardRemap = remCtrlBoardRemapper;
            % Get coupled motors/joints
            couplings = remCtrlBoardRemapper.robotModel.jointsDbase.getJMcouplings('motors',{motorName});
            obj.coupling = couplings{1};
        end
        
        % Destructor
        function delete(obj)
            delete(obj.ctrllerThread);
        end
        
        % Set the motor in PWM control mode and handle the coupled
        % motors keeping their control mode and state unchanged. If
        % this is not supported by the YARP remoteControlBoardRemapper,
        % emulate it. We can only emulate position control.
        ok = start(obj);
        
        % Stop the controller. This also restores the previous
        % control mode for the named motor and eventual coupled
        % motors.
        ok = stop(obj);
                
        % Emulate position control on all the coupled motors except the
        % motor 'obj.ctrledMotorName' which is explicitely controlled
        % through PWM.
        ok = runPwmEmulPosCtrlMode(obj,samplingPeriod);
        
        % Restore the control mode that was set previous the position
        % control emulator setting, on all coupled motors of
        % 'obj.coupling'.
        ok = restorePrevCtrlMode(obj);
        
        % Select new motor to control in explicit PWM mode. The position
        % control emulation is turned off for this motor.
        ok = switchCtrlledMotor(obj,motorName);
        
        % Set the desired PWM level (Duty cycle) for the currently
        % controlled motor.
        ok = setMotorPWM(obj,pwm);
    end
    
    methods (Access=protected)
        ok = ctrllerThreadStartFcn(obj,motorsIdxList);
        ok = ctrllerThreadStopFcn(obj,motorsIdxList);
        ok = ctrllerThreadUpdateFcn(timerObj,thisEvent,timerStopFcn,rateThreadPeriod,PIDCtrller);
    end
    
end
