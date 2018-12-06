function ok = calibrateOffsets(~,sensorsIdxListFile,data,time,sensMeasCell,calibrationMap)

%========================================== CALIBRATION ==========================================
%
%                          ellipsoid fitting and distance to ellipsoid
%

% Plot the data
for acc_i = 1:numel(sensorsIdxListFile)
    % plot the measurements
    accShortName = System.toLatexInterpreterCompliant(UI.getShortSensorName(data.frames{1,sensorsIdxListFile(acc_i)},3));
    % Offsets comparison
    figH = Plotter.plotNFuncTimeseries(...
        [],['Accelerometer ' accShortName ' offsets'],...
        [accShortName '_offsets'],'m \cdot s^{-2}',...
        time{acc_i},sensMeasCell{acc_i},{[accShortName ' offset$_x$'],[accShortName ' offset $_y$'],[accShortName ' offset $_z$']},...
        {'r-','g-','b-'},4,[],[],[]);
end

% define the sub-ranges whwre to average the offset
timeIdxes = 1:numel(time{1});
intervalStartTimeIdxes = cell(1,numel(sensorsIdxListFile));
intervalEndTimeIdxes = cell(1,numel(sensorsIdxListFile));
offsets = cell(1,numel(sensorsIdxListFile));
levels = [];

% Default calibration
calib.centre=[0 0 0]'; calib.radii=[1 1 1]';
calib.quat=[1 0 0 0]'; calib.R=eye(3);
calib.C=eye(3);

for acc_i = 1:numel(sensorsIdxListFile)
    intervalStartTimeIdxes{acc_i} = [1,timeIdxes(diff(time{acc_i})>0.1)];
    intervalEndTimeIdxes{acc_i} = [timeIdxes(diff(time{acc_i})>0.1)-1,timeIdxes(end)];
    for interval = [intervalStartTimeIdxes{acc_i};intervalEndTimeIdxes{acc_i}]
        levels = [levels; mean(sensMeasCell{acc_i}(interval(1):interval(2),:),1)];
    end
    calib.centre = mean(levels,1)';
    offsets{acc_i} = calib;
end

% Standard deviation of the estimated offsets (impacted by the repeatability of the joint encoders and inertial sensors:
% 
% std(Y,1,DIM) -> normalise Y by N (number of samples), compute standard deviation along dimension DIM.
% 
% Typically, std(1:4,1) = sqrt(mean(([1:4]-mean(1:4)).^2))
% 
% === example: ===
% 
% The repeated measurements were stored in:
% 
% levels =
% 
%     0.5954   -8.6783   -4.4600
%    -0.0847    8.2295    5.6451
%     0.5904   -8.7132   -4.4220
%    -0.1175    8.1890    5.6664
%     0.5702   -8.7028   -4.3878
%    -0.0461    8.2052    5.8616
% 
% std(levels([1 3 5],:),1,1)
% = 0.0109    0.0146    0.0295
% 
% std(levels([2 4 6],:),1,1)
% = 0.0292    0.0166    0.0974
% 

% Create mapping extension with new calibrated frames
calibratedFrames = data.frames(1,sensorsIdxListFile);
calibMapExt = containers.Map(calibratedFrames,offsets);

% Overwrite the old calibration (just the offsets)
for cKey = calibMapExt.keys   % go through all elements of the map extension
    key = cell2mat(cKey);     % decapsulate key
    calibrationMap(key) = calibMapExt(key);
end

ok = true;

end

