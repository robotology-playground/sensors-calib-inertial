% this script generates a vector of ROBOT_DOF random values between 0 and
% 10.

%randOffsets=zeros(ROBOT_DOF,1)
randOffsets=(ones(ROBOT_DOF,1)*10+rand(ROBOT_DOF,1)*5)*pi/180
