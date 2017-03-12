function [data, time] = readDataDumper(s)

allData = load(s);
[time,IA,~] = unique(allData(:,2));
data = allData(IA,3:end);
