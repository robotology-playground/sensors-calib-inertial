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
        ax;
        ay;
        az;
    end
    
    methods
        function obj = FilterContext(K,F,time,sensMeas)
            obj.SgolayK = K;
            obj.SgolayF = F;
            obj.time = time;
            obj.sensMeas = sensMeas;
            obj.lastFilteredSensMeas = sensMeas;
            obj.deltaF = 1;
            obj.adjustedDeltaF = 2;
        end
        
        function regSubPlots(obj,ax,ay,az)
            obj.ax = ax;
            obj.ay = ay;
            obj.az = az;
        end
    end
    
end

