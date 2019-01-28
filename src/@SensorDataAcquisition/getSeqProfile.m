function [seqHomeParams,seqEndParams,selector] = getSeqProfile(task,taskSpecificParams,robotModel)
%getSeqProfile Loads the sequence profile parameters from a script ini file
%   The script holding the sequence parameters is selected by the tag 'seqProfileTag' 

% default output
seqHomeParams = {};
seqEndParams = struct();
selector = struct();

switch task
    case JointEncodersCalibrator.task
        run jointsCalibratorSequenceProfileWOsuspend;
        
    case AccelerometersCalibrator.task
        switch taskSpecificParams.subtask
            case 'calibOffsets'
                run(taskSpecificParams.motionSeqProfileOffsets);
            case 'calibMatrixC'
                run(taskSpecificParams.motionSeqProfileMatrixC);
            otherwise
                error('Unknown subtask for AccelerometersCalibrator!');
        end
        
    case SensorDataAcquisition.task
        run(taskSpecificParams.motionSeqProfile);
        
    case LowlevTauCtrlCalibrator.task
        % init joint/motors group label variable for the profile script
        motor = taskSpecificParams.motorName;
        switch taskSpecificParams.frictionOrKtau
            case 'friction'
                % run the profile script for friction identification
                run lowLevTauCtrlCalibratorSequenceProfile1;
            case 'ktau'
                % run the profile script for friction identification
                run lowLevTauCtrlCalibratorSequenceProfile3;
            otherwise
                error('Unknown low level torque control calibration phase!');
        end
    case LowlevCurrCtrlCalibrator.task
        % init joint/motors group label variable for the profile script
        motor = taskSpecificParams.motorName;
        switch taskSpecificParams.frictionOrKcurr
            case 'friction'
                % run the profile script for friction identification
                run lowLevCurrCtrlCalibratorSequenceProfile1;
            case 'kcurr'
                % run the profile script for friction identification
                run lowLevCurrCtrlCalibratorSequenceProfile2;
            otherwise
                error('Unknown low level current control calibration phase!');
        end
        
    otherwise
        error('Unknown task (sequence profile) !!');
end

end

