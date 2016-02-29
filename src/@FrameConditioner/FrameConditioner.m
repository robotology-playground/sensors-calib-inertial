classdef FrameConditioner
    % This class defines the constants for rotating the sensor frames (inversion 
    % of both frame axes x and y)
    % 
    
    properties (Constant)
        %% some sensor are inverted in the model with respect to how are mounted on
        % the real robot
        mtbInvertedFrames   =  {true,true, ...
                                false,false, ...
                                true, ...
                                true};

        % correction for MTB mounted upside-down
        real_R_model  =   [-1, 0, 0; ...
                            0,-1, 0; ...
                            0, 0, 1];
    end
    
end
