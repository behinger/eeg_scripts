function EEG = be_reject_channel(EEG,p,varargin)

if nargin == 3
    silent = 1;
else
    silent = 0;
end
if ~check_EEG(EEG.setname,'Noisychannel')
    
    if exist(p.full.badChannel,'file')==2
        load(p.full.badChannel)
        fprintf('Rejected Channels loaded \n')
        for i = 1:length(rej_channel)
            fprintf('%7s ,', EEG.chanlocs(rej_channel(i)).labels);
        end
        fprintf('\n')
        fprintf('%7i ,', rej_channel(:))
        fprintf('\n')
        if silent
            askAppendOverwrite = 'u'
        else
        askAppendOverwrite = input('Overwrite old rejection channels? (o)verwrite/(a)ppend/(u)se old/(c)ancel: ','s');
        end
        if strcmp(askAppendOverwrite,'o')
            rej_channel = input('Which channels to reject e.g. [3,5,12] or {''Fz'',''AFF2''}? ');
        elseif strcmp(askAppendOverwrite,'a')
            rej_channel_orig = rej_channel;
            rej_channel = input('Which channels to reject e.g. [3,5,12] or {''Fz'',''AFF2''}? ');
        elseif  strcmp(askAppendOverwrite,'c')
            error('User Canceled');
        end
        
    else
        rej_channel=input('Which channels to reject e.g. [3,5,12] or {''Fz'',''AFF2''},? ');
    end
    
    
    
    
    % if cell input, convert it to matrix number
    if iscell(rej_channel)
        fprintf('%7s ,', rej_channel{:})
        fprintf('\n')
        
        rej_channel_nr = [];
        for i = 1:length(rej_channel)
            fprintf('%7i ,', find(strcmp({EEG.chanlocs.labels},rej_channel(i))))
            rej_channel_nr = [rej_channel_nr find(strcmp({EEG.chanlocs.labels},rej_channel(i)))];
            
        end
        rej_channel = rej_channel_nr;
        fprintf('\n')
    else %then we have the numbers and need to convert them temporarily for printing to the corresponding labels
        rej_channel = sort(rej_channel);
        for i = 1:length(rej_channel)
            fprintf('%7s ,', EEG.chanlocs(rej_channel(i)).labels);
        end
        fprintf('\n')
        fprintf('%7i ,', rej_channel(:))
        fprintf('\n')
    end
    rej_channel = sort(rej_channel);
    if exist('askAppendOverwrite','var') && strcmp(askAppendOverwrite,'a')
        rej_channel = sort([rej_channel_orig,rej_channel]);
        askAppendOverwrite = [];
    end
    
    if ~isdir(p.path.reject),          mkdir(p.path.reject);     end
    if exist(p.full.badChannel,'file')==2 && (~exist('askAppendOverwrite','var') || ~strcmp(askAppendOverwrite,'u'))
        copyfile(p.full.badChannel,[p.full.badChannel '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
        fprintf('Backup created \n')
        save(p.full.badChannel,'rej_channel');

    end
    
    EEG = pop_select( EEG,'nochannel',rej_channel);
    EEG.preprocess = [EEG.preprocess 'Noisychannel'];
    
    
end
