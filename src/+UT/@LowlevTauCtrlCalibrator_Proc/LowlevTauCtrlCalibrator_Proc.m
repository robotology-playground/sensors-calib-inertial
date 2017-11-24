classdef LowlevTauCtrlCalibrator_Proc < LowlevTauCtrlCalibrator
    %For unit testing the class 'LowlevTauCtrlCalibrator' state transitions.
    %   Detailed explanation goes here
    
    properties(Constant=true, Access=protected)
        UT_singletonObj = UT.LowlevTauCtrlCalibrator_Proc();
    end
    
    methods(Access=protected)
        function obj = LowlevTauCtrlCalibrator_Proc()
            obj.savePlotCallback = @() disp('savePlot');
            % Debug mode
            obj.isDebugMode = true;
        end
        
        % state machine methods
        function discardAcqFriction(obj)
            disp(['discardAcqFriction']);
            disp(obj.state);
        end
        
        function discardAcqKtau(obj)
            disp(['discardAcqKtau']);
            disp(obj.state);
        end
        
        function plotTrainingData(obj,path,sensors,parts,model,taskSpec)
            disp('plotTrainingData() with parameters:');
            celldisp({obj,path,sensors,parts,model,taskSpec});
        end
        
        function plotModel(obj,frictionOrKtau,data,calibList)
            disp('plotModel() with parameters:');
            celldisp({obj,frictionOrKtau,data,calibList});
        end
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handle to the caller
        function theInstance = instance()
            theInstance = UT.LowlevTauCtrlCalibrator_Proc.UT_singletonObj;
        end
    end
    
    methods(Static=true, Access=protected)
        function calibrateSensors(...
            dataPath,~,measedSensorList,measedPartsList,...
            model,taskSpecificParams)
            disp('calibrateSensors() with parameters:');
            celldisp({dataPath,measedSensorList,measedPartsList,model,taskSpecificParams});
        end
        
        function savePlot(figuresHandler,savePlot,exportPlot,dataPath)
            disp('savePlot() with parameters:');
            celldisp({figuresHandler,savePlot,exportPlot,dataPath});
        end
    end
end
