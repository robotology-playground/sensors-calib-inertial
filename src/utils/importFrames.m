%% import frames saved from CREO
%

format LONGG
list_kHsens_fromCREO = cell(3,1);
fileFormat = '%f64 %f64 %f64 %f64';

for fileIter = 1:13
    % open file
    %filename = 'fileEx.txt';
    filename=['/Users/nunoguedelha/dev/jointOffsetCalibInertial/data/NunoTransforms/10b' int2str(fileIter) '.trf.1'];
    fid = fopen(filename);
    % read file into list
    C = textscan(fid, fileFormat);
    list_kHsens_fromCREO{fileIter,1} = cell2mat(C(1:3));
    % close file
    if fclose(fid) == -1
        error('[ERROR] there was a problem in closing the file')
    end
end

