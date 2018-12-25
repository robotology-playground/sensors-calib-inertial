function saveFigures2(folderName,figureNums)

if ~exist(folderName,'dir')
    mkdir folderName;
end

% Save as Matlab figure and export to png format
for figNum = figureNums(:)'
    figH = figure(figNum);
    set(figH,'PaperPositionMode','auto');
    set(gca,'FontSize',45);
    filename = strrep(figH.UserData,'\_','_');
    savefig(figH,[folderName '/' filename '.fig']);
    print('-dpng','-r150','-opengl',[folderName '/' filename]);
end

end
