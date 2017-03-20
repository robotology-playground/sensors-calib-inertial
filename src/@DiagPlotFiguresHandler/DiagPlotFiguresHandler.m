classdef DiagPlotFiguresHandler < handle
    %DiaPlotFiguresList Holds all properties and methods for handling the
    %figures created by the diagnosis process
    
    properties(SetAccess = protected, GetAccess = public)
        dataFolder = '';
        figsFolder = '';
        figuresMap = [];
        distribLogMap = [];
    end
    
    methods(Access = public)
        function obj = DiagPlotFiguresHandler(dataFolder)
            obj.dataFolder = dataFolder;
            obj.figuresMap = containers.Map('KeyType','char','ValueType','any');
            obj.distribLogMap = containers.Map('KeyType','char','ValueType','any');
        end
        
        function addFigure(obj,figH,figLabel)
            obj.figuresMap(figLabel) = figH;
        end
        
        function addDistribLog(obj,ditribLogString,distribLogLabel)
            obj.distribLogMap(distribLogLabel) = ditribLogString;
        end
        
        function [figsFolder,iterator] = saveFigures(obj,export)
            % create data folder
            if ~exist(obj.dataFolder,'dir')
                mkdir(obj.dataFolder);
            end
            
            % handle iterator and return its value to the caller
            iterator = obj.updateIterator();
            
            % create figures folder and return its name to the caller
            obj.figsFolder = [obj.dataFolder '/log_' num2str(iterator)];
            mkdir(obj.figsFolder);
            figsFolder = obj.figsFolder;
            
            % save figures
            figuresList = obj.figuresMap.values;
            savefig([figuresList{:}],[obj.figsFolder '/allFigures.fig']);
            savedObj = obj;
            save([obj.figsFolder '/allFigures.mat'],'savedObj');
            % save the log string with the distribution parameters
            for logLabel = obj.distribLogMap.keys
                label = logLabel{:};
                FID = fopen([obj.figsFolder '/' label '.txt'],'w');
                fprintf(FID,obj.distribLogMap(label));
            end
            % export figures in PNG format
            if export
                obj.exportFigures();
            end
        end
        
        function figureHandleList = loadFigures(obj)
            figureHandleList = loadFig('allFigures.fig');
            load('allFigures.mat','savedObj');
            for prop = properties(savedObj)
                obj.(prop) = savedObj.(prop);
            end
            clear savedObj;
        end
        
        function exportFigures(obj)
            for figLabel = obj.figuresMap.keys
                label = figLabel{:};
                figure(obj.figuresMap(label));
                set(obj.figuresMap(label),'PaperPositionMode','auto');
                print('-dpng','-r300','-opengl',[obj.figsFolder '/' label]);
            end
        end
    end
    
    methods(Access = protected)
        function iterator = updateIterator(obj)
            % First iterator definition
            iterator = 0;
            % If an iterator has already been created and saved,
            % load it, overwriting the default one.
            if exist([obj.dataFolder '/iterator.mat'],'file')
                load([obj.dataFolder '/iterator.mat'],'iterator');
            end
            % increment it and save it back
            iterator = iterator+1;
            save([obj.dataFolder '/iterator.mat'],'iterator');
        end
    end
    
end

