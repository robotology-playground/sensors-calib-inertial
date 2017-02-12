function [seqHomeParams,seqEndParams,selector] = getSeqProfile(seqProfileTag)
%getSeqProfile Loads the sequence profile parameters from a script ini file
%   The script holding the sequence parameters is selected by the tag 'seqProfileTag' 

% default output
seqHomeParams = {};
seqEndParams = struct();
selector = struct();

switch seqProfileTag
    case 'jointsCalibrator'
        run jointsCalibratorSequenceProfile;
    otherwise
        error('Unknown sequence profile !!');
end

end

