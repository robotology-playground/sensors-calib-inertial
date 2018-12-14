function ok = calibrateMatrixC(~,sensorsIdxListFile,data,~,sensMeasCell,calibrationMap)

%========================================== CALIBRATION ==========================================
%
%                          ellipsoid fitting and distance to ellipsoid
%

ellipsoid_p = cell(1,length(sensorsIdxListFile)); % implicit parameters
calib = cell(1,length(sensorsIdxListFile)); % explicit parameters
ellipsoid_e = cell(1,length(sensorsIdxListFile)); % least squares error
ellipsoid_d = cell(1,length(sensorsIdxListFile)); % distance to surface

for acc_i = 1:numel(sensorsIdxListFile)
    % get estimated centre from database
    predefinedCentre = calibrationMap(data.frames{1,sensorsIdxListFile(acc_i)}).centre;
    [ellipsoid_p{acc_i},ellipsoid_e{acc_i},ellipsoid_d{acc_i}] = ellipsoidfit( ...
        sensMeasCell{1,acc_i}(:,1), ...
        sensMeasCell{1,acc_i}(:,2), ...
        sensMeasCell{1,acc_i}(:,3),...
        predefinedCentre);
    [calib{acc_i}.centre,radii,calib{acc_i}.quat,calib{acc_i}.R] = ...
        ellipsoid_im2ex(ellipsoid_p{1,acc_i}); % convert implicit to explicit
    % convert ellipsoid axis lengths to rates
    calib{acc_i}.radii = radii/9.807;
    % compute full calibration matrix combining elongation and rotation
    calib{acc_i}.C = calib{acc_i}.R'*inv(diag(calib{acc_i}.radii))*calib{acc_i}.R;
end

% Create mapping extension with new calibrated frames
calibratedFrames = data.frames(1,sensorsIdxListFile);
calibMapExt = containers.Map(calibratedFrames,calib);

% Overwrite the old calibration
for cKey = calibMapExt.keys   % go through all elements of the map extension
    key = cell2mat(cKey);     % decapsulate key
    calibrationMap(key) = calibMapExt(key);
end

ok = true;

end

