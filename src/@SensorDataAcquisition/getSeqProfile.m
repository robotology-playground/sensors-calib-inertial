function [seqHomeParams,seqEndParams,selector] = getSeqProfile(task,taskSpecificParams)
%getSeqProfile Loads the sequence profile parameters from a script ini file
%   The script holding the sequence parameters is selected by the tag 'seqProfileTag' 

% default output
seqHomeParams = {};
seqEndParams = struct();
selector = struct();

switch task
    case 'jointEncodersCalibrator'
        run jointsCalibratorSequenceProfile;
    case 'accelerometersCalibrator'
        run accelerometersCalibratorSequenceProfile;
    case 'sensorsTestDataAcquisition'
        run(taskSpecificParams.motionSeqProfile);
    otherwise
        error('Unknown task (sequence profile) !!');
end

end

