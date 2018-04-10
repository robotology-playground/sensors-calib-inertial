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
        couplingJointIdxes@double;
        % Last state before switching to PWM control emulating Pos control
        couplingPrevMode@char;
        lastMotorsPosInPrevMode@double;
        lastMotorsPwmInPrevMode@double;
        % PID gains and real time synchronization
        ctrllerThread@RateThread;
        ctrllerThreadPeriod@double;
        pidGains@struct;
        % Position Emulator mode running (for avoiding state
        % inconsistencies)
        running@logical;
        % Controller ready for setting PWM (couplings checked and position
        % control emulator activated if necessary)
        controllerReady@logical;
        % Previous time of motor encoders measurement
        prevMotorsTime@double;
        % test mode
        testMode@logical;
        % plotter thread (slave)
        plotterThread@RateThread;
        % temporary plot parameters
        tempPlot@struct;
    end
    
    methods
        % Constructor
        function obj = MotorPWMcontroller(motorName,remCtrlBoardRemapper,threadActivation)
            % default init values. Controller not running...
            obj.running = false;
            obj.ctrllerThreadPeriod = nan;
            obj.controllerReady = false;
            obj.tempPlot = struct('figH',[],'units',[],'convertFromRad',[]);
            
            % Set control board remapper
            obj.remCtrlBoardRemap = remCtrlBoardRemapper;
            
            % Get coupled motors/joints
            couplings = remCtrlBoardRemapper.robotModel.jointsDbase.getJMcouplings('motors',{motorName});
            obj.coupling = couplings{1};
            
            % Get indices of joints and coupled motors
            [obj.couplingMotorIdxes,~] = ...
                obj.remCtrlBoardRemap.getMotorsMappedIdxes(obj.coupling.coupledMotors);
            [obj.couplingJointIdxes,~] = ...
                obj.remCtrlBoardRemap.getJointsMappedIdxes(obj.coupling.coupledJoints);
            
            % set position (emulated) and PWM controlled motor settings
            obj.pwmCtrledMotor = struct(...
                'name',motorName,...
                'idx',remCtrlBoardRemapper.getMotorsMappedIdxes({motorName}),...
                'pwm',0);
            
            posCtrledMotorsIdxes = setdiff(obj.couplingMotorIdxes,obj.pwmCtrledMotor.idx,'stable');
            
            obj.posCtrledMotors = struct(...
                'idx',posCtrledMotorsIdxes,...
                'pwm',zeros(size(posCtrledMotorsIdxes)));
            
            % Previous time of motor encoders measurement
            obj.prevMotorsTime = nan;
            
            % start the controller. Check for test mode
            switch threadActivation
                case System.Const.ThreadON
                    obj.testMode = false; obj.start();
                case System.Const.ThreadTEST
                    obj.testMode = true; obj.start();
                otherwise
            end
        end
        
        % Destructor
        function delete(obj)
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
        ok = runPwmEmulPosCtrlMode(obj,samplingPeriod,timeout);
        ok = runRealtimePlotter(obj,threadPeriod,threadTimeout);
        
        % Rate thread functions for the controller
        ok = ctrllerThreadStartFcn(obj,PIDCtrller);
        ok = ctrllerThreadStopFcn(obj);
        ok = ctrllerThreadUpdateFcn(obj,ctrllerThreadStop,rateThreadPeriod,PIDCtrller);
        
        % Rate thread functions for the real-time plotter
        plotterThreadStartFcn(obj);
        plotterThreadStopFcn(obj);
        plotterThreadUpdateFcn(obj);
    end
    
end
