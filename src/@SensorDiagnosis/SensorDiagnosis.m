classdef SensorDiagnosis
    %SensorDiagnosis Holds all methods for running a diagnosis on sensor data
    %   'runDiagnosis()' is the main procedure for checking the inertial
    %   sensors data and plotting the key performance indicators related to
    %   the sensors calibration.
    
    methods(Static = true, Access = public)
        runDiagnosis(...
            modelPath,calibrationMap,...
            calibedParts,calibedJointsIdxes,dataPath,...
            measedSensorList,measedPartsList);
    end
    
    methods(Static = true, Access = protected)
        checkAccelerometersAnysotropy(...
            data_bc,data_ac,sensorsIdxListFile,...
            sensMeasCell_bc,sensMeasCell_ac,...
            figsFolder,savePlot,loadJointPos);
        
        [pVec,dVec,dOrient,d] = ellipsoid_proj_distance_fromExp(x,y,z,centre,radii,R);
        
        checkSensorMeasVsEst(...
            data,sensorsIdxListFile,...
            sensMeasCell,sensEstCell,...
            figsFolder,savePlot,logtag);
        
        plotFittingEllipse(centre,radii,R,sensMeasCell);
        
        plotJointTrajectories(data,ModelParams,figsFolder,savePlot);
        
        h = plotNprintDistrb(FID,dOrient,fitGaussian,color,alpha,prevh,axbc,axac);
    end
    
end
