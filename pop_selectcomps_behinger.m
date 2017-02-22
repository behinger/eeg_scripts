% pop_selectcomps_behinger() - Display components with button to vizualize their
%                  properties and label them for rejection.
% Usage:
%       >> OUTEEG = pop_selectcomps_behinger( INEEG, compnum );
%
% Inputs:
%   INEEG    - Input dataset
%   compnum  - vector of component numbers
%
% Output:
%   OUTEEG - Output dataset with updated rejected components
%
% Note:
%   if the function POP_REJCOMP is ran prior to this function, some
%   fields of the EEG datasets will be present and the current function
%   will have some more button active to tune up the automatic rejection.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_prop(), eeglab()



function figHandleList = pop_selectcomps_behinger( EEG, compnum, fig )


COLREJ = '[1 0.6 0.6]';
COLACC = '[0.75 1 0.75]';
PLOTPERFIG = 35;

com = '';
if nargin < 1
    help pop_selectcomps_behinger;
    return;
end;

if nargin < 2
    promptstr = { 'Components to plot:' };
    initstr   = { [ '1:' int2str(size(EEG.icaweights,1)) ] };
    
    result = inputdlg2(promptstr, 'Reject comp. by map -- pop_selectcomps_behinger',1, initstr);
    if isempty(result), return; end;
    compnum = eval( [ '[' result{1} ']' ]);
    
    if length(compnum) > PLOTPERFIG
        ButtonName=questdlg2(strvcat(['More than ' int2str(PLOTPERFIG) ' components so'],'this function will pop-up several windows'), ...
            'Confirmation', 'Cancel', 'OK','OK');
        if ~isempty( strmatch(lower(ButtonName), 'cancel')), return; end;
    end;
    
end;
fprintf('Drawing figure...\n');
currentfigtag = ['selcomp' num2str(rand)]; % generate a random figure tag
figHandleList = [];
if length(compnum) > PLOTPERFIG
    for index = 1:PLOTPERFIG:length(compnum)
        figHandleList = [figHandleList pop_selectcomps_behinger(EEG, compnum([index:min(length(compnum),index+PLOTPERFIG-1)]))];
    end;
    
    com = [ 'pop_selectcomps_behinger(' inputname(1) ', ' vararg2str(compnum) ');' ];
    return;
end;

if isempty(EEG.reject.gcompreject)
    EEG.reject.gcompreject = zeros( size(EEG.icawinv,2));
end;
try, icadefs;
catch,
    BACKCOLOR = [0.8 0.8 0.8];
    GUIBUTTONCOLOR   = [0.8 0.8 0.8];
end;

% set up the figure
% -----------------
column =ceil(sqrt( length(compnum) ))+1;
rows = ceil(length(compnum)/column);
if ~exist('fig')
    figure('name', [ 'Reject components by map - pop_selectcomps_behinger() (dataset: ' EEG.setname ')'], 'tag', currentfigtag, ...
        'numbertitle', 'off', 'color', BACKCOLOR);
    figHandleList = [figHandleList gcf];
    set(gcf,'MenuBar', 'none');
    pos = get(gcf,'Position');
    set(gcf,'Position', [pos(1) 20 800/7*column 600/5*rows]);
    incx = 120;
    incy = 110;
    sizewx = 100/column;
    if rows > 2
        sizewy = 90/rows;
    else
        sizewy = 80/rows;
    end;
    pos = get(gca,'position'); % plot relative to current axes
    hh = gca;
    q = [pos(1) pos(2) 0 0];
    s = [pos(3) pos(4) pos(3) pos(4)]./100;
    axis off;
end;

% figure rows and columns
% -----------------------
if EEG.nbchan > 64
    disp('More than 64 electrodes: electrode locations not shown');
    plotelec = 0;
else
    plotelec = 1;
end;
count = 1;

    function selectcomp_pop_prop(hObject,eventdata)
        compIdx  = str2num(hObject.Tag(5:end));
        pop_prop_behinger(EEG, 0, compIdx, gcbo, { 'freqrange', [1 70] })

    end
    function reject_button_behinger(hObject,eventdata)
        compIdx  = str2num(hObject.Tag(5:end));
        EEG.reject.gcompreject(compIdx) = ~EEG.reject.gcompreject(compIdx);
        if EEG.reject.gcompreject(compIdx)
            set(gcbo, 'backgroundcolor',COLREJ)
        else
            set(gcbo, 'backgroundcolor',COLACC)
        end
    end

for ri = compnum
    if exist('fig')
        button = findobj('parent', fig, 'tag', ['comp' num2str(ri)]);
        if isempty(button)
            error( 'pop_selectcomps_behinger(): figure does not contain the component button');
        end;
    else
        button = [];
    end;
    
    if isempty( button )
        % compute coordinates
        % -------------------
        X = mod(count-1, column)/column * incx-10;
        Y = (rows-floor((count-1)/column))/rows * incy - sizewy*1.3;
        
        % plot the head
        % -------------
        if ~strcmp(get(gcf, 'tag'), currentfigtag);
            figure(findobj('tag', currentfigtag));
        end;
        ha = axes('Units','Normalized', 'Position',[X Y sizewx sizewy].*s+q);
        if plotelec
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                'off', 'style' , 'fill', 'chaninfo', EEG.chaninfo,'numcontour', 8);
        else
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                'off', 'style' , 'fill','electrodes','off', 'chaninfo', EEG.chaninfo);
        end;
        axis square;
        
        % plot the button
        % ---------------
        
        
        
        
        button = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
            [X+sizewx/2 Y+sizewy sizewx/2 sizewy*0.25].*s+q, 'tag', ['comp' num2str(ri)]);
        
        
        set( button, 'callback', @selectcomp_pop_prop );
        
        
        
        button_2 = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
            [X Y+sizewy sizewx/2 sizewy*0.25].*s+q, 'tag', ['comp' num2str(ri)]);
        
       
        set( button_2, 'callback', @reject_button_behinger );
        
        if isfield(EEG.reject,'eTall') && EEG.reject.eTall(ri)
            %draw yellow
            uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2-10 Y+sizewy-5 sizewx/4 sizewy*0.1].*s+q,'backgroundcolor',[1 0 1])
            
        end
        if isfield(EEG.reject,'eTpruned') &&EEG.reject.eTpruned(ri)
            %draw lila
            uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2-10 Y+sizewy-7 sizewx/4 sizewy*0.1].*s+q,'backgroundcolor',[1 1 0])
        end
        
        if isfield(EEG.reject,'muscleRej') &&EEG.reject.muscleRej(ri)
            %draw lila
            uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2-10 Y+sizewy-9 sizewx/4 sizewy*0.1].*s+q,'backgroundcolor',[0 1 1])
        end
        
        if isfield(EEG.reject,'spectra') &&EEG.reject.spectra(ri)
            %draw lila
            uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2-10 Y+sizewy-11 sizewx/4 sizewy*0.1].*s+q,'backgroundcolor',[0 0.5 1])
        end
        
        
    end;
    set( button, 'backgroundcolor', eval(fastif(EEG.reject.gcompreject(ri), COLREJ,COLACC)), 'string', int2str(ri));
    set( button_2, 'backgroundcolor', eval(fastif(EEG.reject.gcompreject(ri), COLREJ,COLACC)), 'string', int2str(ri));
    drawnow;
    
    count = count +1;
end;

%legend
if isfield(EEG.reject,'eTall')
    uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2+15 Y+sizewy-10 sizewx sizewy/4].*s+q,'backgroundcolor',[1 0 1],'string','etAll')
end
if isfield(EEG.reject,'eTpruned')
    uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2+15 Y+sizewy-15 sizewx sizewy/4].*s+q,'backgroundcolor',[1 1 0],'string','eTPruned')
end
if isfield(EEG.reject,'muscleRej')
    uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2+15 Y+sizewy-20 sizewx sizewy/4].*s+q,'backgroundcolor',[0 1 1],'string','muscle')
end
if isfield(EEG.reject,'spectra')
    uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',[X+sizewx/2+30 Y+sizewy-20 sizewx sizewy/4].*s+q,'backgroundcolor',[0 0.5 1],'string','muscleJose')
end


% draw the bottom button
% ----------------------

function close_function(varargin)
    global rej
    rej = rej|EEG.reject.gcompreject; %the or is neccesarry as the other window could have changed the rejection file already. God, I hate global variables -.-
    delete(gcf)
    end
if ~exist('fig')
    
%     command = 'global rej;rej = EEG.reject.gcompreject;delete(gcf)';
    
    set(gcf,'CloseRequestFcn',@close_function)
    
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[90 -10  15 sizewy*0.25].*s+q, 'callback',  @close_function);
    % sprintf(['eeg_global; if %d pop_rejepoch(%d, %d, find(EEG.reject.sigreject > 0), EEG.reject.elecreject, 0, 1);' ...
    %		' end; pop_compproj(%d,%d,1); close(gcf); eeg_retrieve(%d); eeg_updatemenu; '], rejtrials, set_in, set_out, fastif(rejtrials, set_out, set_in), set_out, set_in));
end;

com = [ 'pop_selectcomps_behinger(' inputname(1) ', ' vararg2str(compnum) ');' ];
% uiwait

return;


end



function com = pop_prop_behinger(EEG, typecomp, chanorcomp, winhandle, spec_opt)

com = '';
if nargin < 1
    help pop_prop;
    return;
end;
if nargin < 5
    spec_opt = {};
end;
if nargin == 1
    typecomp = 1;    % defaults
    chanorcomp = 1;
end;
if typecomp == 0 & isempty(EEG.icaweights)
    error('No ICA weights recorded for this dataset -- first run ICA on it');
end;
if nargin == 2
    promptstr    = { fastif(typecomp,'Channel index(ices) to plot:','Component index(ices) to plot:') ...
        'Spectral options (see spectopo() help):' };
    inistr       = { '1' '''freqrange'', [2 50]' };
    result       = inputdlg2( promptstr, 'Component properties - pop_prop()', 1,  inistr, 'pop_prop');
    if size( result, 1 ) == 0 return; end;
    
    chanorcomp   = eval( [ '[' result{1} ']' ] );
    spec_opt     = eval( [ '{' result{2} '}' ] );
end;

% plotting several component properties
% -------------------------------------
if length(chanorcomp) > 1
    for index = chanorcomp
        pop_prop(EEG, typecomp, index, 0, spec_opt);  % call recursively for each chanorcomp
    end;
    com = sprintf('pop_prop( %s, %d, [%s], NaN, %s);', inputname(1), ...
        typecomp, int2str(chanorcomp), vararg2str( { spec_opt } ));
    return;
end;

if chanorcomp < 1 | chanorcomp > EEG.nbchan % should test for > number of components ??? -sm
    error('Component index out of range');
end;

% assumed input is chanorcomp
% -------------------------
try, icadefs;
catch,
    BACKCOLOR = [0.8 0.8 0.8];
    GUIBUTTONCOLOR   = [0.8 0.8 0.8];
end;
basename = [fastif(typecomp,'Channel ', 'Component ') int2str(chanorcomp) ];

fhandle = figure('name', ['pop_prop() - ' basename ' properties'], 'color', BACKCOLOR, 'numbertitle', 'off', 'visible', 'off');
pos     = get(fhandle,'Position');
set(fhandle,'Position', [pos(1) pos(2)-500+pos(4) 500 500], 'visible', 'on');
hh = axes('parent',fhandle);
pos      = get(hh,'position'); % plot relative to current axes
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
axis(hh,'off');

% plotting topoplot
% -----------------
h = axes('parent',fhandle,'Units','Normalized', 'Position',[-10 60 40 42].*s+q);

%topoplot( EEG.icawinv(:,chanorcomp), EEG.chanlocs); axis square;

if isfield(EEG.chanlocs, 'theta')
    if typecomp == 1 % plot single channel locations
        topoplot( chanorcomp, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
            'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12); axis square;
    else             % plot component map
        topoplot( EEG.icawinv(:,chanorcomp), EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
            'shading', 'interp', 'numcontour', 3); axis square;
    end;
else
    axis(h,'off');
end;
basename = [fastif(typecomp,'Channel ', 'IC') int2str(chanorcomp) ];
% title([ basename fastif(typecomp, ' location', ' map')], 'fontsize', 14);
title(basename, 'fontsize', 14);

% plotting erpimage
% -----------------
hhh = axes('Parent', fhandle,'Units','Normalized', 'Position',[45 62 48 38].*s+q);
eeglab_options;
if EEG.trials > 1
    % put title at top of erpimage
    axis(hhh,'off');
    hh = axes('Parent', fhandle,'Units','Normalized', 'Position',[45 62 48 38].*s+q);
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
    if EEG.trials < 6
        ei_smooth = 1;
    else
        ei_smooth = 3;
    end
    if typecomp == 1 % plot channel
        offset = nan_mean(EEG.data(chanorcomp,:));
        erp=nan_mean(squeeze(EEG.data(chanorcomp,:,:))')-offset;
        erp_limits=get_era_limits(erp);
        erpimage( EEG.data(chanorcomp,:)-offset, ones(1,EEG.trials)*10000, EEG.times*1000, ...
            '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp','erp_vltg_ticks',erp_limits);
    else % plot component
        icaacttmp  = eeg_getdatact(EEG, 'component', chanorcomp);
        offset     = nan_mean(icaacttmp(:));
        era        = nan_mean(squeeze(icaacttmp)')-offset;
        era_limits = get_era_limits(era);
        erpimage( icaacttmp-offset, ones(1,EEG.trials)*10000, EEG.times*1000, ...
            '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '','erp_vltg_ticks',era_limits);
    end;
    axes(hhh);
    title(sprintf('%s activity \\fontsize{10}(global offset %3.3f)', basename, offset), 'fontsize', 14);
else
    % put title at top of erpimage
    EI_TITLE = 'Continous data';
    axis(hhh,'off');
    hh = axes('Parent', fhandle,'Units','Normalized', 'Position',[45 62 48 38].*s+q);
    ERPIMAGELINES = 200; % show 200-line erpimage
    while size(EEG.data,2) < ERPIMAGELINES*EEG.srate
        ERPIMAGELINES = 0.9 * ERPIMAGELINES;
    end
    ERPIMAGELINES = round(ERPIMAGELINES);
    if ERPIMAGELINES > 2   % give up if data too small
        if ERPIMAGELINES < 10
            ei_smooth = 1;
        else
            ei_smooth = 3;
        end
        erpimageframes = floor(size(EEG.data,2)/ERPIMAGELINES);
        erpimageframestot = erpimageframes*ERPIMAGELINES;
        eegtimes = linspace(0, erpimageframes-1, length(erpimageframes)); % 05/27/2014 Ramon: length(erpimageframes) by EEG.srate/1000  in eegtimes = linspace(0, erpimageframes-1, EEG.srate/1000);
        if typecomp == 1 % plot channel
            offset = nan_mean(EEG.data(chanorcomp,:));
            % Note: we don't need to worry about ERP limits, since ERPs
            % aren't visualized for continuous data
            erpimage( reshape(EEG.data(chanorcomp,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar');
        else % plot component
            icaacttmp = eeg_getdatact(EEG, 'component', chanorcomp);
            offset = nan_mean(icaacttmp(:));
            erpimage(reshape(icaacttmp(:,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset,ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar','yerplabel', '');
        end
    else
        axis(hh,'off');
        text(0.1, 0.3, [ 'No erpimage plotted' 10 'for small continuous data']);
    end;
    axes(hhh);
end;

% plotting spectrum
% -----------------
if ~exist('winhandle')
    winhandle = NaN;
end;
if ishandle(winhandle)
    h = axes('Parent', fhandle,'units','normalized', 'position',[5 10 95 35].*s+q);
else
    h = axes('Parent', fhandle,'units','normalized', 'position',[5 0 95 40].*s+q);
end;
%h = axes('units','normalized', 'position',[45 5 60 40].*s+q);
try
    eeglab_options;
    if typecomp == 1
        [spectra freqs] = spectopo( EEG.data(chanorcomp,:), EEG.pnts, EEG.srate, spec_opt{:} );
    else
        if option_computeica
            [spectra freqs] = spectopo( EEG.icaact(chanorcomp,:), EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,chanorcomp), spec_opt{:} );
        else
            icaacttmp = (EEG.icaweights(chanorcomp,:)*EEG.icasphere)*reshape(EEG.data(EEG.icachansind,:,:), length(EEG.icachansind), EEG.trials*EEG.pnts);
            [spectra freqs] = spectopo( icaacttmp, EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,chanorcomp), spec_opt{:} );
        end;
    end;
    % set up new limits
    % -----------------
    %freqslim = 50;
    %set(gca, 'xlim', [0 min(freqslim, EEG.srate/2)]);
    %spectra = spectra(find(freqs <= freqslim));
    %set(gca, 'ylim', [min(spectra) max(spectra)]);
    
    %tmpy = get(gca, 'ylim');
    %set(gca, 'ylim', [max(tmpy(1),-1) tmpy(2)]);
    set( get(h, 'ylabel'), 'string', 'Power 10*log_{10}(\muV^{2}/Hz)', 'fontsize', 14);
    set( get(h, 'xlabel'), 'string', 'Frequency (Hz)', 'fontsize', 14);
    title('Activity power spectrum', 'fontsize', 14);
catch err
    axis off;
    text(0.1, 0.3, [ 'Error: no spectrum plotted' 10 err.message 10]);
    %     lasterror
    % 	text(0.1, 0.3, [ 'Error: no spectrum plotted' 10 ' make sure you have the ' 10 'signal processing toolbox']);
end;

% display buttons
% ---------------
if ishandle(winhandle)
    COLREJ = '[1 0.6 0.6]';
    COLACC = '[0.75 1 0.75]';
    % CANCEL button
    % -------------
    h  = uicontrol(fhandle, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Cancel', 'Units','Normalized','Position',[-10 -10 15 6].*s+q, 'callback', 'delete(gcf);');
    
    % VALUE button
    % -------------
    hval  = uicontrol(fhandle, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Values', 'Units','Normalized', 'Position', [15 -10 15 6].*s+q);
    
    % REJECT button
    % -------------
    if ~isempty(EEG.reject.gcompreject)
        status = EEG.reject.gcompreject(chanorcomp);
    else
        status = 0;
    end;
    %hr = uicontrol(fhandle, 'Style', 'pushbutton', 'backgroundcolor', eval(fastif(status,COLREJ,COLACC)), ...
    %			'string', fastif(status, 'REJECT', 'ACCEPT'), 'Units','Normalized', 'Position', [40 -10 15 6].*s+q, 'userdata', status, 'tag', 'rejstatus');
    %command = [ 'set(gcbo, ''userdata'', ~get(gcbo, ''userdata''));' ...
    %			'if get(gcbo, ''userdata''),' ...
    %			'     set( gcbo, ''backgroundcolor'',' COLREJ ', ''string'', ''REJECT'');' ...
    %			'else ' ...
    %			'     set( gcbo, ''backgroundcolor'',' COLACC ', ''string'', ''ACCEPT'');' ...
    %			'end;' ];
    %set(hr, 'callback', command);
    
    % HELP button
    % -------------
    h  = uicontrol(fhandle, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'HELP', 'Units','Normalized', 'Position', [65 -10 15 6].*s+q, 'callback', 'pophelp(''pop_prop'');');
    
    % OK button
    % ---------
    %command = [ 'global EEG;' ...
    %			'tmpstatus = get( findobj(''parent'', gcbf, ''tag'', ''rejstatus''), ''userdata'');' ...
    %			'EEG.reject.gcompreject(' num2str(chanorcomp) ') = tmpstatus;' ];
    % 	if winhandle ~= 0
    %         if VERS < 8.04
    %             command = [ command ...
    %                 sprintf('if tmpstatus set(%3.15f, ''backgroundcolor'', %s); else set(%3.15f, ''backgroundcolor'', %s); end;', ...
    %                 winhandle, COLREJ, winhandle, COLACC)];
    %         elseif VERS >= 8.04
    %             command = [ command ...
    %                 sprintf('if tmpstatus set(findobj(''Tag'', ''%s''), ''backgroundcolor'', %s); else set(findobj(''Tag'',''%s''), ''backgroundcolor'', %s); end;', ...
    %                 winhandle.Tag, COLREJ, winhandle.Tag, COLACC)];
    %         end
    % 	end;
    % 	command = [ command 'close(gcf); clear tmpstatus' ];
    % 	h  = uicontrol(fhandle, 'Style', 'pushbutton', 'string', 'OK', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[90 -10 15 6].*s+q, 'callback', command);
    
    % draw the figure for statistical values
    % --------------------------------------
    index = num2str( chanorcomp );
    command = [ ...
        'figure(''MenuBar'', ''none'', ''name'', ''Statistics of the component'', ''numbertitle'', ''off'');' ...
        '' ...
        'pos = get(gcf,''Position'');' ...
        'set(gcf,''Position'', [pos(1) pos(2) 340 340]);' ...
        'pos = get(gca,''position'');' ...
        'q = [pos(1) pos(2) 0 0];' ...
        's = [pos(3) pos(4) pos(3) pos(4)]./100;' ...
        'axis off;' ...
        ''  ...
        'txt1 = sprintf(''(\n' ...
        'Entropy of component activity\t\t%2.2f\n' ...
        '> Rejection threshold \t\t%2.2f\n\n' ...
        ' AND                 \t\t\t----\n\n' ...
        'Kurtosis of component activity\t\t%2.2f\n' ...
        '> Rejection threshold \t\t%2.2f\n\n' ...
        ') OR                  \t\t\t----\n\n' ...
        'Kurtosis distibution \t\t\t%2.2f\n' ...
        '> Rejection threhold\t\t\t%2.2f\n\n' ...
        '\n' ...
        'Current thesholds sujest to %s the component\n\n' ...
        '(after manually accepting/rejecting the component, you may recalibrate thresholds for future automatic rejection on other datasets)'',' ...
        'EEG.stats.compenta(' index '), EEG.reject.threshentropy, EEG.stats.compkurta(' index '), ' ...
        'EEG.reject.threshkurtact, EEG.stats.compkurtdist(' index '), EEG.reject.threshkurtdist, fastif(EEG.reject.gcompreject(' index '), ''REJECT'', ''ACCEPT''));' ...
        '' ...
        'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-11 4 117 100].*s+q, ''Style'', ''frame'' );' ...
        'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-5 5 100 95].*s+q, ''String'', txt1, ''Style'',''text'', ''HorizontalAlignment'', ''left'' );' ...
        'h = uicontrol(gcf, ''Style'', ''pushbutton'', ''string'', ''Close'', ''Units'',''Normalized'', ''Position'', [35 -10 25 10].*s+q, ''callback'', ''close(gcf);'');' ...
        'clear txt1 q s h pos;' ];
    set( hval, 'callback', command);
    if isempty( EEG.stats.compenta )
        set(hval, 'enable', 'off');
    end;
    
    com = sprintf('pop_prop( %s, %d, %d, 0, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
else
    com = sprintf('pop_prop( %s, %d, %d, NaN, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
end;

return;
end

function out = nan_mean(in)

nans = find(isnan(in));
in(nans) = 0;
sums = sum(in);
nonnans = ones(size(in));
nonnans(nans) = 0;
nonnans = sum(nonnans);
nononnans = find(nonnans==0);
nonnans(nononnans) = 1;
out = sum(in)./nonnans;
out(nononnans) = NaN;

end
function era_limits=get_era_limits(era)
%function era_limits=get_era_limits(era)
%
% Returns the minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)
%
% Inputs:
% era - [vector] Event related activation or potential
%
% Output:
% era_limits - [min max] minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)

mn=min(era);
mx=max(era);
mn=orderofmag(mn)*round(mn/orderofmag(mn));
mx=orderofmag(mx)*round(mx/orderofmag(mx));
era_limits=[mn mx];

end
function ord=orderofmag(val)
%function ord=orderofmag(val)
%
% Returns the order of magnitude of the value of 'val' in multiples of 10
% (e.g., 10^-1, 10^0, 10^1, 10^2, etc ...)
% used for computing erpimage trial axis tick labels as an alternative for
% plotting sorting variable

val=abs(val);
if val>=1
    ord=1;
    val=floor(val/10);
    while val>=1,
        ord=ord*10;
        val=floor(val/10);
    end
    return;
else
    ord=1/10;
    val=val*10;
    while val<1,
        ord=ord/10;
        val=val*10;
    end
    return;
end

end