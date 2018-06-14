classdef map2robotConfFile
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function kbemf = getKbemf(kvMat,gearboxMat)
            %Conputes the Kbemf as per the definition in the robots code
            %and configuration files (motorcontrol)
            kbemf = -kvMat(:)'./gearboxMat(:)';
        end
        
        function ktau = getKtau(kpwmMat)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            ktau = kpwmMat(:)'.^-1;
        end
    end
end

