function [EEG] = be_clean_continuous(EEG,p,sub,varargin)
%% Cleaning function

global rej
rej = [];


cfg = finputcheck(varargin,...
    {'silent','boolean',[],0;});

resave = 0;

if  cfg.silent == 0
    cleanerName = input('Your name: ','s');
end
% Check if the file already exists
if exist(p.reject(sub).continuous,'file')==2
    %Load it
    tmpRej = load(p.reject(sub).continuous);
    %fnRej = fieldnames(tmpRej);
    rej = tmpRej.rej;
    
    fprintf('Rejections loaded \n')
    % Check whether an empty (temporary) file has been made
    if exist('tmp','var')
        warning('Loaded Rejections were Empty!')
    else %if not temporary, check Samplingrate
        
        if isempty(rej)
            warning('Rejection are empty please overwrite')
        else
            if size(rej,2)-5 ~= EEG.nbchan
                rej = [rej(:,1:5) zeros(EEG.nbchan,size(rej,1))'];
                warning('Last time the Data had been cleaned with different number of channels, fixing it!\n ')
            end
        end
    end
elseif cfg.silent
    error('no cleaning file found, please clean your data first before using silent=1')
end
% If cfg.silent, the cleaningInput should be "use old"
if cfg.silent
    cleaningInput='u';
    % if Cleaning Check, we want to see the cleaning Times and use
    % Append
    
else
    %Else we ask what the user wants
    cleaningInput = input('Old cleaning times found: (o)verwrite, (u)se old cleaning, (a)ppend, (c)ancel y/n: ','s');
end
%If we overwrite, we simply ask the user to clean again
if strcmp(cleaningInput,'o')
    eegplot(EEG.data,'srate',EEG.srate,'winlength',8, ...
        'events',EEG.event,'wincolor',[1 0.5 0.5],'command','global rej,rej=TMPREJ',...
        'eloc_file',EEG.chanlocs);
    uiwait;
    resave = 1;
    %If we append, we use the old rejectiontimes for 'winrej'
elseif strcmp(cleaningInput,'a')
    if isempty(rej)
        fprintf('The old Rejections were empty, (a)ppend does the same thing as (o)verwrite \n');
    else
        if size(rej,2)-5 ~= EEG.nbchan
            error('Different cleaned channels vs. EEG channels found. This should not happen anymore, rej: %i, cleaning: %i \n \n',size(rej,2)-5,EEG.nbchan);
            
        end
    end
    eegplot(EEG.data,'srate',EEG.srate,'winlength',8, ...
        'events',EEG.event,'wincolor',[1 0.5 0.5],'command','global rej,rej=TMPREJ',...
        'eloc_file',EEG.chanlocs,'winrej',sort(rej));
    uiwait;
    
    if strcmp(input('Do you really want to append (y)es/(a)bort :','s'),'a')
        error('User Aborted')
    end
    resave = 1;
    
    % If we cancel, throw an error
elseif strcmp(cleaningInput,'c') %
    error('User canceled the cleaning-action')
    % The only possible Input now can be 'u', for continuing the
    % cleaning
elseif ~strcmp(cleaningInput,'u')
    error('User gave impossible input')
end



% save the times of the rejection
if exist(p.reject(sub).continuous,'file')==2 && (~cfg.silent && ~strcmp(cleaningInput,'u') || resave) % if we find the file, and we are not on the grid and we do not continue without cleaning anything, backup!
    copyfile(p.reject(sub).continuous,[p.reject(sub).continuous '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
    fprintf('Backup created \n')
end
% We get the current samplingRate

currentDate = datestr(now);
%If not on grid and not just cleaning the Dataset, save it!
if ~cfg.silent && ~strcmp(cleaningInput,'u') || resave
    if isempty(rej)
        error('rejection was empty! Did not save and aborted')
    end
    
    save(p.reject(sub).continuous,'rej','currentDate','cleanerName');
    fprintf('Rejections saved \n')
end

% Convert and reject the marked rejections
tmprej = eegplot2event(rej, -1);
tmprej(:,3) = tmprej(:,3) - 0.5*EEG.srate; %assuming cutoff -6dB is 0.5Hz!
tmprej(:,4) = tmprej(:,4) + 0.5*EEG.srate; %assuming cutoff -6dB is 0.5Hz!
tmprej(tmprej(:,3)<1,3) = 1;
tmprej(tmprej(:,4)>EEG.pnts,4) = EEG.pnts;
% Sorting the values
[~,sIdx] = sort(tmprej(:,3));
tmprej = tmprej(sIdx,:);

% Sort them, there used to be a bug in EEGLAB and this fixes it.
throw_out = nan;
while ~isempty(throw_out)
    throw_out = [];
    for i = 1:size(tmprej,1)-1
        if ~isempty(throw_out) && throw_out(end) == i
            continue
        end
        if tmprej(i,4)>=tmprej(i+1,3)
            throw_out=[throw_out i+1];
            tmprej(i,3) = min(tmprej(i,3),tmprej(i+1,3));
            tmprej(i,4) = max(tmprej(i,4),tmprej(i+1,4));
        end
        
        
        
    end
    tmprej(throw_out,:) = [];
end

if ~strcmp(cleaningInput,'a')
    tmprej(:,3:4) = round(tmprej(:,3:4));
end
[EEG,~] = eeg_eegrej(EEG,tmprej(:,[3 4]));

%Save it in the preprocess unit.
EEG.preprocessInfo.tmprej = tmprej;
EEG.preprocessInfo.cleanContDate = datestr(now);
EEG.preprocess = [EEG.preprocess '_contClean'];
%     end
end
