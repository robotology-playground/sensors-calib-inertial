classdef ILowPassFilter < DSP.IDiscreteFilter
    %This class defines the interface of a low pass filter
    %   This shall be the interface of any discrete filters like
    %   Butterworth, Chebyshev, Chebyshev type II, etc...
    
    properties(GetAccess=public, SetAccess=protected)
        Fc@double; % cut-off frequency
    end
    
    methods(Abstract=true)
        setCutoffFreq(obj,Fc);
    end
    
end

