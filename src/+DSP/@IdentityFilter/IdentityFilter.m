classdef IdentityFilter < DSP.ILowPassFilter
    %This class defines an identity filter for testing purposes
    
    methods
        function obj = IdentityFilter(Fc)
            obj.Fc = Fc;
        end
        
        function sigVecOut = procSig(~,sigVecIn)
            sigVecOut = sigVecIn;
        end
        
        function setCutoffFreq(obj,Fc)
            obj.Fc = Fc;
        end
    end
    
end

