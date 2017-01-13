function tuneFilter(hObject,callbackdata,filterContext)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

figureOpened = true; % for handling "close figure" action

% define operation on graph depending on the key pressed
switch callbackdata.Key
    case 'q'
        close;
        figureOpened = false;
    case 'i'
        filterContext.SgolayK = 3;
        filterContext.SgolayF = 11;
    case 's'
        filtParams.type = 'sgolay';
        filtParams.SgolayK = filterContext.SgolayK;
        filtParams.SgolayF = filterContext.SgolayF;
        save(filterContext.contextPath,'filtParams');
    case 'l'
        load(filterContext.contextPath,'filtParams');
        filterContext.SgolayK = filtParams.SgolayK;
        filterContext.SgolayF = filtParams.SgolayF;
    case {'1','2','3','4','5'}
        filterContext.SgolayK = str2double(callbackdata.Key);
    case 'rightarrow'
        filterContext.deltaF = filterContext.deltaF*10;
    case 'leftarrow'
        filterContext.deltaF = max(1,filterContext.deltaF/10);
    case 'downarrow'
        filterContext.SgolayF = filterContext.SgolayF - filterContext.adjustedDeltaF;
    case 'uparrow'
        filterContext.SgolayF = filterContext.SgolayF + filterContext.adjustedDeltaF;
    otherwise
end

% is reploting necessary?
switch callbackdata.Key
    case {'i','l','1','2','3','4','5','downarrow','uparrow'}
        refresh = true;
    otherwise
        refresh = false;
end

% make sure to always apply an even deltaF
filterContext.adjustedDeltaF = filterContext.deltaF + mod(filterContext.deltaF,2);

%% make sure that we still meet following requirements after K or F is changed :
newF = filterContext.SgolayF; % for readability
% newF >= SgolayK+1
newF = max(newF,filterContext.SgolayK+1);
% newF < (nb of samples - margin)
newF = min(newF,length(filterContext.time)-10);
% newF is odd
newF = newF-mod(newF,2)+1;
% store newF
filterContext.SgolayF = newF;

%% Plot filtered sensor data components

%% print filter (this will be done on any key press)
clc;
disp(['key pressed : ' callbackdata.Key]);
disp(['from figure : ' get(gcf,'Name')]);
filterContext
if callbackdata.Key == 's'
    disp('Saved!');
end
if callbackdata.Key == 'l'
    disp('Loaded!');
end

SigOrigStyle = {'Color',[239/255 170/255 170/255],'LineStyle','-'};

if figureOpened && refresh
    %% compute new filtered signal
    filteredMeas = sgolayfilt(filterContext.sensMeas,filterContext.SgolayK,filterContext.SgolayF);
    disp('...Filtered signal computed.');
    disp('plotting...');
    %% Replace previous plot with original/lastFiltered/newFiltered plots
    
    % Plot original signal components X, Y, Z, flushing previous plots
    plot(filterContext.ax,...
        filterContext.time,filterContext.sensMeas(:,1),...
        SigOrigStyle{:},'lineWidth',3);                   % component X
    plot(filterContext.ay,...
        filterContext.time,filterContext.sensMeas(:,2),...
        SigOrigStyle{:},'lineWidth',3);                   % component Y
    plot(filterContext.az,...
        filterContext.time,filterContext.sensMeas(:,3),...
        SigOrigStyle{:},'lineWidth',3);                   % component Z
    
    % Hold on
    hold(filterContext.ax,'on');
    hold(filterContext.ay,'on');
    hold(filterContext.az,'on');
    
    % Plot last filtered signal
    plot(filterContext.ax,...
        filterContext.time,filterContext.lastFilteredSensMeas(:,1),...
        'k:','lineWidth',1);                             % component X
    plot(filterContext.ay,...
        filterContext.time,filterContext.lastFilteredSensMeas(:,2),...
        'k:','lineWidth',1);                             % component Y
    plot(filterContext.az,...
        filterContext.time,filterContext.lastFilteredSensMeas(:,3),...
        'k:','lineWidth',1);                             % component Z

    % Plot filtered signal
    plot(filterContext.ax,...
        filterContext.time,filteredMeas(:,1),...
        'b-','lineWidth',2);                             % component X
    plot(filterContext.ay,...
        filterContext.time,filteredMeas(:,2),...
        'b-','lineWidth',2);                             % component Y
    plot(filterContext.az,...
        filterContext.time,filteredMeas(:,3),...
        'b-','lineWidth',2);                             % component Z
    
    disp('plot complete!');
        
    % Plot titles
    title(filterContext.ax,'X component','Fontsize',16,'FontWeight','bold');
    title(filterContext.ay,'Y component','Fontsize',16,'FontWeight','bold');
    title(filterContext.az,'Z component','Fontsize',16,'FontWeight','bold');

    % Hold off
    hold(filterContext.ax,'off');
    hold(filterContext.ay,'off');
    hold(filterContext.az,'off');
    
    %% replace last filtered signal
    filterContext.lastFilteredSensMeas = filteredMeas;
end

end

