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

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_selectcomps_behinger.m,v $
% Revision 1.29  2007/04/30 23:17:04  arno
% only plot spectrum up to 50 Hz
%
% Revision 1.28  2006/03/29 00:51:48  scott
% nothing
%
% Revision 1.27  2005/11/02 19:56:07  arno
% history
%
% Revision 1.26  2005/03/05 02:33:21  arno
% chaninfo
%
% Revision 1.25  2004/07/09 17:00:24  arno
% only show electrode if less than 64 channels
%
% Revision 1.24  2004/03/18 00:31:45  arno
% remove skirt
%
% Revision 1.23  2004/02/23 15:30:18  scott
% added 'shrink','skirt' to topoplot call
%
% Revision 1.22  2004/02/23 15:28:08  scott
% turned 'electrodes','off' in topoplots
%
% Revision 1.21  2003/07/24 23:17:27  arno
% removing extra plot
%
% Revision 1.20  2003/07/24 18:52:10  arno
% typo
% /
%
% Revision 1.19  2003/07/21 15:25:31  arno
% allowing to select component to reject
%
% Revision 1.18  2003/05/12 22:29:10  arno
% verbose off
% for topoplot
%
% Revision 1.17  2003/05/10 17:31:52  arno
% adding name of dataset to title
%
% Revision 1.16  2003/02/11 02:02:16  arno
% making it compatible for one row
%
% Revision 1.15  2003/02/10 23:25:52  arno
% allowing to plot less than 35 components
%
% Revision 1.14  2002/09/04 23:31:22  arno
% spetial aborting plot feature
%
% Revision 1.13  2002/09/04 23:25:40  arno
% debugging last
%
% Revision 1.12  2002/09/04 23:24:34  arno
% updating pop_compprop -> pop_prop
%
% Revision 1.11  2002/08/19 22:05:37  arno
% removing comment
%
% Revision 1.10  2002/08/12 18:35:09  arno
% questdlg2
%
% Revision 1.9  2002/08/12 14:59:30  arno
% button color
%
% Revision 1.8  2002/08/12 01:42:46  arno
% colors
%
% Revision 1.7  2002/08/11 22:19:37  arno
% *** empty log message ***
%
% Revision 1.6  2002/07/26 23:57:37  arno
% same
%
% Revision 1.5  2002/07/26 23:56:27  arno
% window location
%
% Revision 1.4  2002/07/26 14:35:27  arno
% debugging: if nb comps~=nb chans
%
% Revision 1.3  2002/04/26 21:21:08  arno
% updating eeg_store call
%
% Revision 1.2  2002/04/18 18:40:01  arno
% retrIeve
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 

function [EEG, com] = pop_selectcomps_behinger( EEG, compnum, fig );

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

if length(compnum) > PLOTPERFIG
    for index = 1:PLOTPERFIG:length(compnum)
        pop_selectcomps_behinger(EEG, compnum([index:min(length(compnum),index+PLOTPERFIG-1)]));
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
		command = sprintf('pop_prop( %s, 0, %d, gcbo, { ''freqrange'', [1 50] });', inputname(1), ri);
        
		set( button, 'callback', command );
        
        
        
        button_2 = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
                           [X Y+sizewy sizewx/2 sizewy*0.25].*s+q, 'tag', ['comp' num2str(ri)]);
                       
		command_2 = ['EEG.reject.gcompreject(' num2str(ri) ') = ~EEG.reject.gcompreject(' num2str(ri) ');'...
            sprintf('if EEG.reject.gcompreject( %i ) set(gcbo, ''backgroundcolor'', %s); else set(gcbo, ''backgroundcolor'', %s); end;', ... %%3.15f
					ri, COLREJ, COLACC)];
		set( button_2, 'callback', command_2 );
        
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
if ~exist('fig')
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Cancel', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[-10 -10  15 sizewy*0.25].*s+q, 'callback', 'close(gcf); fprintf(''Operation cancelled\n'')' );
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Set threhsolds', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[10 -10  15 sizewy*0.25].*s+q, 'callback', 'pop_icathresh(EEG); pop_selectcomps_behinger( EEG, gcbf);' );
	if isempty( EEG.stats.compenta	), set(hh, 'enable', 'off'); end;	
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See comp. stats', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[30 -10  15 sizewy*0.25].*s+q, 'callback',  ' ' );
	if isempty( EEG.stats.compenta	), set(hh, 'enable', 'off'); end;	
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See projection', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[50 -10  15 sizewy*0.25].*s+q, 'callback', ' ', 'enable', 'off'  );
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Help', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[70 -10  15 sizewy*0.25].*s+q, 'callback', 'pophelp(''pop_selectcomps_behinger'');' );
	command = '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh(''[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);''); close(gcf)';
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[90 -10  15 sizewy*0.25].*s+q, 'callback',  command);
			% sprintf(['eeg_global; if %d pop_rejepoch(%d, %d, find(EEG.reject.sigreject > 0), EEG.reject.elecreject, 0, 1);' ...
		    %		' end; pop_compproj(%d,%d,1); close(gcf); eeg_retrieve(%d); eeg_updatemenu; '], rejtrials, set_in, set_out, fastif(rejtrials, set_out, set_in), set_out, set_in));
end;

com = [ 'pop_selectcomps_behinger(' inputname(1) ', ' vararg2str(compnum) ');' ];
return;		
