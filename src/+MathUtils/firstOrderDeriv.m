function dx = firstOrderDeriv( x,time )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

% right differential
dxR = diff(x);
dtR = diff(time);
dxR(end+1) = dxR(end);
dtR(end+1) = dtR(end);

% left differential
dxL = zeros(size(dxR)); dtL = zeros(size(dtR));
dxL(2:end) = dxR(1:end-1);
dxL(1) = dxL(2);
dtL(2:end) = dtR(1:end-1);
dtL(1) = dtL(2);

% division by the total time delta
dx = (dxL+dxR)./(dtL+dtR);

end

