classdef y
    %Y Class implementing a few YARP constants not handled by the bindings
    %   Detailed explanation goes here
    properties(Constant)
        VOCAB_CM_IDLE            = y.vocabEnc('idl');
        VOCAB_CM_TORQUE          = y.vocabEnc('torq');
        VOCAB_CM_POSITION        = y.vocabEnc('pos');
        VOCAB_CM_POSITION_DIRECT = y.vocabEnc('posd');
        VOCAB_CM_VELOCITY        = y.vocabEnc('vel');
        VOCAB_CM_CURRENT         = y.vocabEnc('icur');
        VOCAB_CM_PWM             = y.vocabEnc('ipwm');
        VOCAB_PIDTYPE_POSITION   = y.vocabEnc('pos');
        VOCAB_PIDTYPE_VELOCITY   = y.vocabEnc('vel');
        VOCAB_PIDTYPE_TORQUE     = y.vocabEnc('trq');
        VOCAB_PIDTYPE_CURRENT    = y.vocabEnc('cur');
    end
    
    methods(Static = true)
        function vocabInt = vocabEnc(vocabString)
            % we cast the vocab integer to double otherwise the fromMatlab
            % conversion fails (copies 0s instead of the actual values.
            % This should be due to a memory misalignment).
            vocabInt = double(yarp.encode(vocabString));
        end
        
        function vocabString = vocabDec(vocabInt)
            vocabString = yarp.decode(vocabInt);
        end
    end
    
end
