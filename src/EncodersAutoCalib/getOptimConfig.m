function [optimFunc,options] = getOptimConfig()

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% SELECT HERE THE ALGORITHM FOR OPTIMIZING THE COST FUNCTION
% fminunc, fmincon, lsqnonlin
% DEBUG: use 'fminsearch' for deactivating optimization
optimFunc = @lsqnonlin;

funcProps = functions(optimFunc);
funcName = funcProps.function;

switch funcName
    case 'fminunc'
        % Optimization options: we won't provide the gradient for now
        %
        Display = 'iter';
        TolFun = 1e-7;
        TolX = 0.1; % Encoders accuracy => 12 bits for 360 deg 
        % => 1 tick = 0.087 deg ~ 0.1 deg * pi/180 ~ 0.002 rad.
        FunValCheck = 'on';
        Algorithm = 'interior-point';
        PlotFcns = {@optimplotx, @optimplotfval, @optimplotstepsize};
        % ActiveConstrTol:
        % MaxFunEvals:
        % MaxIter:
        % AlwaysHonorConstraints:
        % GradConstr:
        % GradObj:
        % InitTrustRegionRadius:
        % LargeScale:
        % ScaleProblem:
        % SubproblemAlgorithm:
        % UseParallel:
        %
        dfltOptions = optimset('fminunc');
        options = optimset(dfltOptions,'TolFun', TolFun, 'TolX', TolX, 'FunValCheck', FunValCheck, ...
           'Algorithm', Algorithm, 'Display', Display, 'PlotFcns', PlotFcns);
        
    case 'lsqnonlin'
        % Optimization options:
        %
        Display = 'iter';
        TolFun = 1e-7;
        TolX = 2e-3; % 0.1 deg
        FunValCheck = 'on';
%        Algorithm = 'levenberg-marquardt';
        Algorithm = 'trust-region-reflective';
        PlotFcns = {@optimplotx, @optimplotresnorm, @optimplotstepsize};
        %
        dfltOptions = optimset('lsqnonlin'); % Algorithm = 'trust-region-reflective'
        options = optimset(dfltOptions,'TolFun', TolFun, 'TolX', TolX, 'FunValCheck', FunValCheck, ...
            'Algorithm', Algorithm, 'Display', Display, 'PlotFcns', PlotFcns);
        
    otherwise
        options = optimset(funcName);
end

