classdef SMstates < Simulink.IntEnumType
   enumeration
      getJointLimits(0)
      reachStartPosition(1)
      runCalibTrajectory(2)
      reachInitPosition(3)
   end
   methods
       function retVal = getDescription()
           retVal = 'States of the main state machine';
       end
       function retVal = getHeaderFile()
           retVal = 'SMstates.m';
       end
   end
end
