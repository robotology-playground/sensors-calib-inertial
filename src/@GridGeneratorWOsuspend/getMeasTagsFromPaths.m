function measTag = getMeasTagsFromPaths(~,qT)

% For each pair of simultaneous target positions <qT_i,qA_i>, set the tag
% activating or deactivating the sensor data acquisition.
% In this derived class, the acquisition is never suspended during
% transition movements
measTag = true(size(qT));

end
