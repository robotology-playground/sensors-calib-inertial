classdef PIDcontroller < handle
    %This class implements a PID correction controller
    %   Its properties are
    %   - P,I, and D gains
    %   - filter for the input signal pre-processing
    %   - cumulative I(ntegral) term
    
    properties(GetAccess=public, SetAccess=protected)
        Kp@double; % P gains column vector
        Kd@double; % D gains column vector
        Ki@double; % I gains column vector
        max_int@double;    % maximum integral component value
        max_output@double; % maximum overall PID output value
        scale@double % overall scale factor
        I@double;  % current integral term vector
        nbChannels@uint8; % number of input channels
        filter@DSP.IDiscreteFilter; % filter coefficients (same filter for every channel)
    end
    
    methods
        function obj = PIDcontroller(Kp,Kd,Ki,max_int,max_output,scale,aFilter)
            obj.nbChannels = uint8(numel(Kp));
            % check dimensions. Input params have to be line or column
            % vectors of dimension "nbChannels"
            inSizes = sort(cell2mat(sizes(Kp,Kd,Ki,max_int,max_output,scale)),2);
            if ~isequal(inSizes,repmat([1,obj.nbChannels],[6 1]))
                error('Kp, Kd, Ki, max integral, max output and scale sizes don''t match!! Please use evenly sized column vectors.');
            end
            % save properties
            [obj.Kp,obj.Kd,obj.Ki,obj.max_int,obj.max_output,obj.scale,obj.filter] = ...
                deal(Kp(:),Kd(:),Ki(:),max_int(:),max_output(:),scale(:),aFilter);
            obj.I = zeros(obj.nbChannels,1);
        end
        
        function reset(obj,integralTermVecInit)
            % check dimensions
            if ~isequal(size(integralTermVecInit),[obj.nbChannels,1])
                error(['Input doesn''t match expected dimensions (' num2str(obj.nbChannels) 'x1)!!']);
            end
            % Initialize the integral term
            obj.I = integralTermVecInit;
        end
        
        function [intSat,outSat,nextCorr] = step(obj,timeStep,desiredX,currentX,currentDx)
            % Reshape inputs as column vectors
            [desiredX,currentX,currentDx] = deal(desiredX(:),currentX(:),currentDx(:));
            % Filter current position measurement
            filteredCurrX = obj.filter.process(currentX);
            % Error to desired position
            epsilon = filteredCurrX - desiredX;
            depsilon = currentDx - 0;
            % proportional and derivative terms
            PD = obj.Kp.*epsilon + obj.Kd.*depsilon;
            % integral term
            obj.I = obj.I + obj.Ki.*epsilon.*timeStep;
            obj.I = min(obj.I,obj.max_int);
            obj.I = max(obj.I,-obj.max_int);
            intSat = any([obj.I==obj.max_int,obj.I==-obj.max_int]);
            % output total term
            pidOut = obj.scale.*(PD + obj.I);
            nextCorr = min(pidOut,obj.max_output);
            nextCorr = max(nextCorr,-obj.max_output);
            outSat = any([nextCorr==obj.max_output,nextCorr==-obj.max_output]);
        end
    end
end

