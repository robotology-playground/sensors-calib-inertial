classdef Regressors < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static=true)
        [thetaPos,thetaNeg] = normalEquationAsym(x,y);
        
        theta = normalEquationSym(x,y);
        
        [xs,ys] = resampleDataAsym(thetaPos,thetaNeg,x,nSamples);
        
        [xs,ys] = resampleDataSym(theta,x,nSamples);
    end
    
end
