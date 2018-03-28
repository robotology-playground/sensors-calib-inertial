classdef MotorPWMcontroller < handle
    %Controller for emulating position or velocity control through PWM settings.
    %   The function and execution rate is defined through the class constructor.
    
    properties (Access=protected)
    end
    
    properties (GetAccess=public, SetAccess=protected)
        % control board remapper
        remCtrlBoardRemap@RemoteControlBoardRemapper;
        % controlled motor and respective coupling info
        pwmCtrledMotor@struct;
        posCtrledMotors@struct;
        coupling@JointMotorCoupling;
        couplingMotorIdxes@double;
        % Last state before switching to PWM control emulating Pos control
        couplingPrevMode@char;
        lastMotorsPosInPrevMode@double;
        lastMotorsPwmInPrevMode@double;
        % PID gains and real time synchronization
        ctrllerThread@RateThread;
        ctrllerThreadPeriod@double;
        pidGains@struct;
        % Running flag for avoiding state inconsistencies
        running@bool;
        % Previous time of motor encoders measurement
        prevMotorsTime@double;
    end
    
    methods
        % Constructor
        function obj = MotorPWMcontroller(motorName,remCtrlBoardRemapper)
            % controller not running
            obj.running = false;
            obj.ctrllerThread = nan;
            obj.ctrllerThreadPeriod = nan;
            
            % Set control board remapper
            obj.remCtrlBoardRemap = remCtrlBoardRemapper;
            
            % Get coupled motors/joints
            couplings = remCtrlBoardRemapper.robotModel.jointsDbase.getJMcouplings('motors',{motorName});
            obj.coupling = couplings{1};
            
            % Get indices of coupled motors
            [obj.couplingMotorIdxes,~] = ...
                obj.remCtrlBoardRemap.getMotorsMappedIdxes(ob.coupling.coupledMotors);
            
            % set position (emulated) and PWM controlled motor settings
            obj.pwmCtrledMotor.name = motorName;
            obj.pwmCtrledMotor.idx = remCtrlBoardRemapper.getMotorsMappedIdxes({motorName});
            obj.pwmCtrledMotor.pwm = 0;
            obj.posCtrledMotors.idx = setdiff(obj.couplingMotorIdxes,obj.pwmCtrledMotor.idx,'stable');
            obj.posCtrledMotors.pwm = zeros(size(obj.posCtrledMotors.idx));
            
            % Previous time of motor encoders measurement
            obj.prevMotorsTime = nan;
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
        
        % Select new motor to control in explicit PWM mode. The position
        % control emulation is turned off for this motor.
        ok = switchCtrlledMotor(obj,motorName);
        
        % Set the desired PWM level (Duty cycle) for the currently
        % controlled motor.
        ok = setMotorPWM(obj,pwm);
    end
    
    methods (Access=protected)
        % Emulate position control on all the coupled motors except the
        % motor 'obj.pwmCtrledMotor.name' which is explicitely controlled
        % through PWM.
        ok = runPwmEmulPosCtrlMode(obj,samplingPeriod);
        
        % Rate thread functions
        ok = ctrllerThreadStartFcn(obj);
        ok = ctrllerThreadStopFcn(obj);
        ok = ctrllerThreadUpdateFcn(timerObj,thisEvent,timerStopFcn,rateThreadPeriod,PIDCtrller);
    end
    
end
