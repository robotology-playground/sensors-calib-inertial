classdef FilterContext < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SgolayK;
        SgolayF;
        time;
        sensMeas;
        lastFilteredSensMeas = [];
        deltaF;
        adjustedDeltaF; % always even
        ax@cell;
        contextPath = '';
    end
    
    methods
        function obj = FilterContext(K,F,time,sensMeas,contextPath)
            obj.SgolayK = K;
            obj.SgolayF = F;
            obj.time = time;
            obj.sensMeas = sensMeas;
            obj.lastFilteredSensMeas = sensMeas;
            obj.deltaF = 1;
            obj.adjustedDeltaF = 2;
            obj.contextPath = contextPath;
        end
        
        function regSubPlots(obj,ax)
            obj.ax = ax;
        end
    end
    
    methods(Static)
        tuneFilter(hObject,callbackdata,filterContext)
    end
    
end

