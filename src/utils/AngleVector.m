classdef AngleVector < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        angleList;
        acc_offsetList;
    end
    
    methods
        function obj = AngleVector(vec)
            % Refer to wiki:
            % https://github.com/robotology/codyco-modules/wiki/External-Inertial-Sensors-for-iCubGenova02
            %
            % a = ((t1 x1 y1 z1)   .... (tn xn yn xn))
            % n  = number of sensors published on the port
            % ai = pos of sensor ... see enum type
            % bi = accel (1) or gyro (2)
            % ti = timestamp in us
            %
            % | size  |            4           | ...
            % | offset| 4*(i-1)+1..4*(i-1)+4   | ...
            % | Field | t1..z1| ti  xi  yi  zi | ...
            %
            HEADER_LENGTH = 0;
            FULL_ACC_SIZE = 4;
            LIN_ACC_1RST_IDX = 2;

            obj.angleList = cell(13,1);
            obj.acc_offsetList = zeros(13,1);
            
            for acc_idx = 1:13
                acc_offset = HEADER_LENGTH+(acc_idx-1)*FULL_ACC_SIZE+LIN_ACC_1RST_IDX;
                obj.acc_offsetList(acc_idx) = acc_offset;
                acc_i = vec([acc_offset acc_offset+1 acc_offset+2]);
                obj.angleList{acc_idx} = Angle(acc_i);
            end
        end
        
        function angleVec = computeAngles2ref(obj,vec)
            angleVec = zeros(2,13);
            for acc_idx = 1:13
                acc_offset = obj.acc_offsetList(acc_idx);
                acc_i = vec([acc_offset acc_offset+1 acc_offset+2]);
                angleVec(:,acc_idx) = obj.angleList{acc_idx}.computeNormAngle2ref(acc_i);
            end
        end
        
        function setRefs(obj,vec)
            for acc_idx = 1:13
                acc_offset = obj.acc_offsetList(acc_idx);
                acc_i = vec([acc_offset acc_offset+1 acc_offset+2]);
                obj.angleList{acc_idx}.setGravRef(acc_i);
            end
        end
    end
    
end

