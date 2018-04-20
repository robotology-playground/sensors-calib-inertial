classdef Regressors < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static=true)
        [thetaPos,thetaNeg] = normalEquationAsym(x,y);
        
        model = pwmModel1Sym(x,y);
        
        model = frictionModel1Sym(x,y);
        
        model = frictionModel2(x,y);
        
        [xs,ys] = resampleDataAsym(thetaPos,thetaNeg,x,nSamples);
        
        [xs,ys] = resampleDataSym(theta,x,nSamples);
        
        [xs,ys] = resampleDataModel(model,x,nSamples);
        
        resVec = residuals(thetaPos,thetaNeg,x,y);
    end
    
end
