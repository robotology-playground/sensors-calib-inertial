function [seqHomeParams,seqEndParams,selector] = getSeqProfile(task,taskSpecificParams)
%getSeqProfile Loads the sequence profile parameters from a script ini file
%   The script holding the sequence parameters is selected by the tag 'seqProfileTag' 

% default output
seqHomeParams = {};
seqEndParams = struct();
selector = struct();

switch task
    case jointEncodersCalibrator.task
        run jointsCalibratorSequenceProfileWOsuspend;
    case accelerometersCalibrator.task
        run accelerometersCalibratorSequenceProfileWOsuspend;
    case SensorDataAcquisition.task
        run(taskSpecificParams.motionSeqProfile);
    case LowlevTauCtrlCalibrator.task
        % init joint/motors group label variable for the profile script
        jtmotGrp = taskSpecificParams.jointMotorGroupLabel;
        % run the profile script
        run lowLevTauCtrlCalibratorSequenceProfile;
    otherwise
        error('Unknown task (sequence profile) !!');
end

end

