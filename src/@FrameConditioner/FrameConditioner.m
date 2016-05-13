classdef FrameConditioner
    % This class defines the constants for rotating the sensor frames (inversion 
    % of both frame axes x and y)
    % 
    
    properties (Constant)
        % correction for MTB mounted upside-down
%         real_R_model  =   [-1, 0, 0; ...
%                             0,-1, 0; ...
%                             0, 0, 1];
        % correction for the IMU frame
        real_R_model  =   [ 0,-1, 0; ...
                            0, 0, 1; ...
                           -1, 0, 0];
    end
    
end
