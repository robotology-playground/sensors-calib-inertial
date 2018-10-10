function [ ok ] = ctrllerThreadUpdateFcn( obj,ctrllerThreadStop,rateThreadPeriod,PIDCtrller )

obj.pwmCtrledMotor.pwm = obj.pattern.x(t);

%Run the PID controller and set the computed PWM values
%   Detailed explanation goes here
ok = obj.ctrllerThreadUpdateFcn@MotorPWMcontroller(ctrllerThreadStop,rateThreadPeriod,PIDCtrller);

end
