classdef LowlevCurrCtrlCalibrator < Calibrator
    %LowlevCurrCtrlCalibrator Holds all methods for low level joint current control calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   low level parameters. These parameters include the PWM voltage to
    %   current rate and the back electromotive friction force parameter.
    
    properties(Constant=true, Access=protected)
        % 'singletonObj' has to be a unique name among all constant
        % properties of this class, parent classes and derived classes. So
        % for each of these classes we need to redefine (override) a static
        % method 'instance()' that returns this specific constant handle.
        singletonObj = LowlevCurrCtrlCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'LowlevCurrCtrlCalibrator';
        
        initSection@char = 'lowLevelCurrCtrlCalib';
        
        calibedSensorType@char = 'LLCctrl';

        statesNextState = {...
            'restart'         ,'proceed'         ,'skip'            ,'end'     ;...
            []                ,S.stateAcqKtau    ,[]                ,[]        ;...  % stateStart
            S.stateAcqFriction,S.stateFitFriction,S.stateNextGroup  ,S.stateEnd;...  % stateAcqFriction
            S.stateAcqFriction,S.stateNextGroup  ,S.stateNextGroup  ,S.stateEnd;...  % stateFitFriction
            S.stateAcqKtau    ,S.stateFitKtau    ,S.stateAcqFriction,S.stateEnd;...  % stateAcqKcurr
            S.stateAcqKtau    ,S.stateAcqFriction,S.stateAcqFriction,S.stateEnd;...  % stateFitKcurr
            []                ,S.stateAcqKtau    ,[]                ,S.stateEnd};    % stateNextGroup
        
        statesCurrentProcessing = {...
            'currentProc'      ,'transition'          ,;...
            @(o) @o.start      ,@(varargin) 'proceed' ,;... % stateStart
            @(o) @o.acqFriction,@(o) @o.promptUser    ,;... % stateAcqFriction
            @(o) @o.fitFriction,@(o) @o.promptUser    ,;... % stateFitFriction
            @(o) @o.acqKcurr   ,@(o) @o.promptUser    ,;... % stateAcqKcurr
            @(o) @o.fitKcurr   ,@(o) @o.promptUser    ,;... % stateFitKcurr
            @(varargin) []     ,@(o) @o.nextGroupTrans,};   % stateNextGroup
        
        statesTransitionProcessing = {...
            'restartProc'             ,'proceedProc'           ,'skipProc'                ,'endProc'                 ;...
            @(varargin) []            ,@(varargin) []          ,@(varargin) []            ,@(varargin) []            ;...  % stateStart
            @(o) @o.discardAcqFriction,@(varargin) []          ,@(o) @o.discardAcqFriction,@(o) @o.discardAcqFriction;...  % stateAcqFriction
            @(o) @o.discardAcqFriction,@(o) @o.savePlotCallback,@(o) @o.discardAcqFriction,@(o) @o.discardAcqFriction;...  % stateFitFriction
            @(o) @o.discardAcqKcurr   ,@(varargin) []          ,@(o) @o.discardAcqKcurr   ,@(o) @o.discardAcqKcurr   ;...  % stateAcqKcurr
            @(o) @o.discardAcqKcurr   ,@(o) @o.savePlotCallback,@(o) @o.discardAcqKcurr   ,@(o) @o.discardAcqKcurr   ;...  % stateFitKcurr
            @(varargin) []            ,@(varargin) []          ,@(varargin) []            ,@(varargin) []            };    % stateNextGroup
        
        stateArray = LowlevCurrCtrlCalibrator.defStatesFromDesc([...
            LowlevCurrCtrlCalibrator.statesNextState ...
            LowlevCurrCtrlCalibrator.statesCurrentProcessing ...
            LowlevCurrCtrlCalibrator.statesTransitionProcessing]);
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
        function obj = LowlevCurrCtrlCalibrator()
        end
        
        % state machine methods
        transition = promptUser(obj);
        
        transition = nextGroupTrans(obj);
        
        start(obj);
        
        acquire(obj,frictionOrKcurr);
        
        fit(obj,frictionOrKcurr);
        
        function acqFriction(obj), obj.acquire('friction'); end
        
        function acqKcurr(obj), obj.acquire('kcurr'); end
        
        function fitFriction(obj), obj.fit('friction'); end
        
        function fitKcurr(obj), obj.fit('kcurr'); end
        
        function discardAcqFriction(obj), []; end
        
        function discardAcqKcurr(obj), []; end
        
        plotTrainingData(obj,path,sensors,parts,model,taskSpec);
        
        plotModel(obj,frictionOrKcurr,model,xVar,nbSamples);
        
        calibrateSensors(obj,...
            dataPath,~,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handle to the caller
        function theInstance = instance()
            theInstance = LowlevCurrCtrlCalibrator.singletonObj;
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

