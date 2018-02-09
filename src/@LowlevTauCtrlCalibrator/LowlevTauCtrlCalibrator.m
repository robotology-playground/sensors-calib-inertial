classdef LowlevTauCtrlCalibrator < Calibrator
    %LowlevTauCtrlCalibrator Holds all methods for low level joint torque control calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   low level parameters. These parameters include the PWM voltage to
    %   torque rate, the viscuous and Coulomb friction parameters.
    
    properties(Constant=true, Access=protected)
        % 'singletonObj' has to be a unique name among all constant
        % properties of this class, parent classes and derived classes. So
        % for each of these classes we need to redefine (override) a static
        % method 'instance()' that returns this specific constant handle.
        singletonObj = LowlevTauCtrlCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'LowlevTauCtrlCalibrator';
        
        initSection@char = 'lowLevelTauCtrlCalib';
        
        calibedSensorType@char = 'LLTctrl';
        
        statesNextState = {...
            'restart'         ,'proceed'         ,'skip'          ,'end'     ;...
            []                ,S.stateAcqFriction,[]              ,[]        ;...  % stateStart
            S.stateAcqFriction,S.stateFitFriction,S.stateAcqKtau  ,S.stateEnd;...  % stateAcqFriction
            S.stateAcqFriction,S.stateAcqKtau    ,S.stateAcqKtau  ,S.stateEnd;...  % stateFitFriction
            S.stateAcqKtau    ,S.stateFitKtau    ,S.stateNextGroup,S.stateEnd;...  % stateAcqKtau
            S.stateAcqKtau    ,S.stateNextGroup  ,S.stateNextGroup,S.stateEnd;...  % stateFitKtau
            []                ,S.stateAcqFriction,[]              ,S.stateEnd};    % stateNextGroup
        
        statesCurrentProcessing = {...
            'currentProc'      ,'transition'          ,;...
            @(o) @o.start      ,@(varargin) 'proceed' ,;... % stateStart
            @(o) @o.acqFriction,@(o) @o.promptUser    ,;... % stateAcqFriction
            @(o) @o.fitFriction,@(o) @o.promptUser    ,;... % stateFitFriction
            @(o) @o.acqKtau    ,@(o) @o.promptUser    ,;... % stateAcqKtau
            @(o) @o.fitKtau    ,@(o) @o.promptUser    ,;... % stateFitKtau
            @(varargin) []     ,@(o) @o.nextGroupTrans,};   % stateNextGroup
        
        statesTransitionProcessing = {...
            'restartProc'             ,'proceedProc'           ,'skipProc'                ,'endProc'                 ;...
            @(varargin) []            ,@(varargin) []          ,@(varargin) []            ,@(varargin) []            ;...  % stateStart
            @(o) @o.discardAcqFriction,@(varargin) []          ,@(o) @o.discardAcqFriction,@(o) @o.discardAcqFriction;...  % stateAcqFriction
            @(o) @o.discardAcqFriction,@(o) @o.savePlotCallback,@(o) @o.discardAcqFriction,@(o) @o.discardAcqFriction;...  % stateFitFriction
            @(o) @o.discardAcqKtau    ,@(varargin) []          ,@(o) @o.discardAcqKtau    ,@(o) @o.discardAcqKtau    ;...  % stateAcqKtau
            @(o) @o.discardAcqKtau    ,@(o) @o.savePlotCallback,@(o) @o.discardAcqKtau    ,@(o) @o.discardAcqKtau    ;...  % stateFitKtau
            @(varargin) []            ,@(varargin) []          ,@(varargin) []            ,@(varargin) []            };    % stateNextGroup
        
        stateArray = LowlevTauCtrlCalibrator.defStatesFromDesc([...
            LowlevTauCtrlCalibrator.statesNextState ...
            LowlevTauCtrlCalibrator.statesCurrentProcessing ...
            LowlevTauCtrlCalibrator.statesTransitionProcessing]);
    end
    
    properties(Access=protected)
        init@struct;
        model@RobotModel;
        lastAcqSensorDataAccessorMap@containers.Map;
        expddMotorList = {};
        timeStart = 0;
        timeStop = 0;
        subSamplingSize = 0;
        filtParams@struct;
        savePlotCallback = @() [];
        
        % Main state of the state machine:
        % - 'state.current' gives the current state indexing the 'stateArray'
        % - 'state.transition' hold the transition to the next state
        %    through the field values 'restart', 'proceed', 'skip', 'end'.
        %    Actually, storing the transition label to 'state.transition'
        %    is only for debug purpose.
        % - 'state.currentMotorIdx' indexes the current joint/motor group to
        %    process.
        state@struct = struct(...
            'current',S.stateStart,...
            'transition',[],...
            'currentMotorIdx',0);
        
        % Debug mode
        isDebugMode = false;
    end
    
    methods(Access=protected)
        function obj = LowlevTauCtrlCalibrator()
        end
        
        % state machine methods
        transition = promptUser(obj);
        
        transition = nextGroupTrans(obj);
        
        start(obj);
        
        acquire(obj,frictionOrKtau);
        
        fit(obj,frictionOrKtau);
        
        function acqFriction(obj), obj.acquire('friction'); end
        
        function acqKtau(obj), obj.acquire('ktau'); end
        
        function fitFriction(obj), obj.fit('friction'); end
        
        function fitKtau(obj), obj.fit('ktau'); end
        
        function discardAcqFriction(obj), []; end
        
        function discardAcqKtau(obj), []; end
        
        plotTrainingData(obj,path,sensors,parts,model,taskSpec);
        
        plotModel(obj,frictionOrKtau,theta,xVar,nbSamples);
        
        calibrateSensors(obj,...
            dataPath,~,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handle to the caller
        function theInstance = instance()
            theInstance = LowlevTauCtrlCalibrator.singletonObj;
        end
    end
    
    methods(Access=public)
        run(obj,init,model,lastAcqSensorDataAccessorMap);
    end
    
    methods(Static=true, Access=protected)
        % Each line of 'statesDesc' is converted to a struct which fields
        % are listed in the first line of 'statesDesc'.
        stateStructList = defStatesFromDesc(statesDesc);
        
        % Parameters used for loading and parsing the acquired data
        dataLoadingParams = buildDataLoadingParams(...
            model,measedSensorList,measedPartsList,...
            calibedJointOrderedList);
        
        % Save plot with some context parameters
        savePlot(figuresHandler,savePlot,exportPlot,dataPath);
    end
    
end

