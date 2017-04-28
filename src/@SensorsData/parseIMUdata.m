function parseIMUdata(obj,~)
% Parses the IMU data on the '/icub/inertial' YARP port.
% 
% define offsets for parsing Linear Acceleration data from the Head IMU
%
% Refer to wiki:
% http://eris.liralab.it/wiki/Inertial_Sensor
%
% The output consists in 12 double, organized as follows:
% 
% euler angles [3]: deg
% linear acceleration [3]: m/s^2
% angular speed [3]: deg/s (* see note1)
% magnetic field [3]: arbitrary units
%
% header_length = 0;
% full_acc_size = 12;
% lin_acc_first_idx = 4;
% lin_acc_last_idx = 6;
%

% The robot has only 1 IMU installed in the head, we labelled '1x1_acc'
obj.mapIMUlabel2position = containers.Map({'1x1_acc'},{'4:6'});

end
