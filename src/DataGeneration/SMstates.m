classdef SMstates < Simulink.IntEnumType
   enumeration
      getJointLimits(0)
      reachPosition(1)
      runCalibTrajectory(2)
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
