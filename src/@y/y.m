classdef y
    %Y Class implementing a few YARP constants not handled by the bindings
    %   Detailed explanation goes here
    properties(Constant) %, Access=protected)
        aVocab = yarp.Vocab();
    end
    
    properties(Constant)
        VOCAB_CM_IDLE            = y.vocabEnc('idl');
        VOCAB_CM_TORQUE          = y.vocabEnc('torq');
        VOCAB_CM_POSITION        = y.vocabEnc('pos');
        VOCAB_CM_VELOCITY        = y.vocabEnc('vel');
        VOCAB_CM_CURRENT         = y.vocabEnc('icur');
        VOCAB_CM_PWM             = y.vocabEnc('ipwm');
    end
    
    methods(Static = true)
        function vocabInt = vocabEnc(vocabString)
            % we cast the vocab integer to double otherwise the fromMatlab
            % conversion fails (copies 0s instead of the actual values.
            % This should be due to a memory misalignment).
            vocabInt = double(y.aVocab.encode(vocabString));
        end
        
        function vocabString = vocabDec(vocabInt)
            vocabString = y.aVocab.decode(vocabInt);
        end
    end
    
end
