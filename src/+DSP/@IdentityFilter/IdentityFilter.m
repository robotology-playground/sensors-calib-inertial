classdef IdentityFilter < DSP.ILowPassFilter
    %This class defines an identity filter for testing purposes
    
    methods
        function obj = IdentityFilter(Fc)
            obj.Fc = Fc;
        end
        
        function filteredMeas = process(~,rawMeas)
            filteredMeas = rawMeas;
        end
        
        function setCutoffFreq(obj,Fc)
            obj.Fc = Fc;
        end
        
        function objCpy = copy(obj)
            objCpy = DSP.IdentityFilter(obj.Fc);
        end
    end
    
end

