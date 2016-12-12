classdef Angle < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        refVec;
        acc_gain = 5.9855e-04;
        refNorm;
    end
    
    methods(Static)
        % Compute angle from vector va to vector vb
        % Oriented angle axis support = va x vb
        function angle = va2vb(va,vb)
            va = va(:); vb = vb(:);
            sinAngle = norm(cross(va,vb),2)/(norm(va,2)*norm(vb,2));
            cosAngle = (va'*vb)/(norm(va,2)*norm(vb,2));
            angle = atan2(sinAngle,cosAngle);
        end
    end
    
    methods
        % Constructor. Sets ref vector vector from rawVec
        function obj = Angle(rawVec)
            obj.setGravRef(rawVec);
        end
        
        % Set ref vector from rawVec
        function setGravRef(obj,rawVec)
            obj.refVec = rawVec'*obj.acc_gain;
            obj.refNorm = norm(obj.refVec);
        end
        
        % Compute the raw vector norm (as an acceleration) and
        % the angle to ref vector
        function normVecAngle2ref = computeNormAngle2ref(obj,rawVec)
            % convert raw vector to acceleration vector
            vec = rawVec'*obj.acc_gain;
            % compute norm
            normVec = norm(vec,2);
            % compute angle
            angle = Angle.va2vb(obj.refVec,vec);
            angle2ref = angle*180/pi;
            normVecAngle2ref = [normVec angle2ref]';
        end
    end
    
end

