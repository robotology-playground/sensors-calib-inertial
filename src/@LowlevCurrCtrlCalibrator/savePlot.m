function savePlot( figuresHandler,savePlot,exportPlot,dataPath )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Save the plots into matlab figure files and eventually export them to PNG
% files.
if savePlot
    % save plots
    [figsFolder,iterator] = figuresHandler.saveFigures(exportPlot);
    % create log info file
    fileID = fopen([figsFolder '.txt'],'w');
    fprintf(fileID,'figs folder = %s\n',[dataPath '/' figsFolder]);
    fprintf(fileID,'iterator = %d\n',iterator);
    %fprintf(fileID,whos);
    fclose(fileID);
end

end
