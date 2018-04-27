function plotterThreadUpdateFcn( h,x,y,colors )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% display current point
k = h.UserData(1);
h.MarkerFaceColor = colors{h.UserData(2)};

addpoints(h,x(k),y(k));
drawnow limitrate

% incremennt and loop if we reach the end of the vector
h.UserData = h.UserData+1;
if h.UserData(1)>numel(x)
    h.UserData(1) = 1;
end
if h.UserData(2)>5
    h.UserData(2) = 1;
end

end

