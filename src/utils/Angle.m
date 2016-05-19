classdef Angle < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        refGrav;
        acc_gain = 5.9855e-04;
        refNorm;
    end
    
    methods
        function obj = Angle(rawVec)
            obj.refGrav = rawVec'*obj.acc_gain;
            obj.refNorm = norm(obj.refGrav);
        end
        
        function setGravRef(obj,rawVec)
            obj.refGrav = rawVec'*obj.acc_gain;
            obj.refNorm = norm(obj.refGrav);
        end
        
        function normVecAngle2ref = computeNormAngle2ref(obj,rawVec)
            vec = rawVec'*obj.acc_gain;
            normVec = norm(vec);
            sinAngle = norm(cross(obj.refGrav,vec),2)/(norm(obj.refGrav,2)*norm(vec,2));
            cosAngle = (obj.refGrav'*vec)/(norm(obj.refGrav,2)*norm(vec,2));
            angle = atan2(sinAngle,cosAngle);
            angle2ref = angle*180/pi;
            normVecAngle2ref = [normVec angle2ref]';
        end
    end
    
end

