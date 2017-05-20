function sensorHwId = frame2hwId( sensorFrameName )

% match the string chunk after the last '_' of <sensorFrameName>
splitName = textscan(sensorFrameName,'%s','delimiter','_');
sensorHwId = splitName{1}{end};

% check the string chunk has the format <dsd> or <ddsd> where 'd' is a
% digit and 's' is a character. TO BE IMPROVED
if isempty(regexp(sensorHwId,'([0-9]+|e)[bx][0-9]+','match'))
    error('Unknown sensor board ID');
end

end
