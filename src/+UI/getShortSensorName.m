function shortName = getShortSensorName(fullSensorName,N)

splitName = textscan(fullSensorName,'%s','delimiter','_');
shortName = cell2mat(join(splitName{1}(end-N+1:end),'_'));

end

