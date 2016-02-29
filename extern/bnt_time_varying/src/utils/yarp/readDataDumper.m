function [data, time] = readDataDumper(s)

allData = load(s);
time = allData(:,2);
data = allData(:,3:end);