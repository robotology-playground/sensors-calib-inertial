function saveFigures2(folderName,figureNums)

if ~exist(folderName,'dir')
    mkdir folderName;
end

% Save as Matlab figure and export to png format
for figNum = figureNums(:)'
    figH = figure(figNum);
    set(figH,'PaperPositionMode','auto');
    set(gca,'FontSize',45);
    % choose dimensions
    figH.PaperPosition(3) = 2*figH.PaperPosition(4);
    % reduce extra white spaces
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax.Position([1,3]) = [left ax_width];
    % save figure
    filename = strrep(figH.UserData,'\_','_');
    savefig(figH,[folderName '/' filename '.fig']);
    print('-dpng','-r150','-opengl',[folderName '/' filename]);
end

end
