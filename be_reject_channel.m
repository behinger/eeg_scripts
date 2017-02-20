function EEG = be_reject_channel(EEG,p,sub,varargin)

if nargin > 3 && ~isstr(varargin{1})
   cfg.silent = 1;
   cfg.rej_channel = varargin{1};
   assert(~isempty(cfg.rej_channel),'Given noisy channels are empty')
else
    cfg = finputcheck(varargin,...
    {'silent','boolean',[],0;});
end
currP = p.reject(sub);


if ~check_EEG(EEG.setname,'badChannel')
    if isfield(cfg,'rej_channel')
        rej_channel = cfg.rej_channel;
        
    elseif exist(currP.channel,'file')==2
        load(currP.channel)
        fprintf('Rejected Channels loaded \n')
        for i = 1:length(rej_channel)
            fprintf('%7s ,', EEG.chanlocs(rej_channel(i)).labels);
        end
        fprintf('\n')
        fprintf('%7i ,', rej_channel(:))
        fprintf('\n')
        if cfg.silent
            askAppendOverwrite = 'u';
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
    
    if ~isdir(p.rejectpath),          mkdir(p.rejectpath);     end
    if exist(currP.channel ,'file')==2 && (~exist('askAppendOverwrite','var') || ~strcmp(askAppendOverwrite,'u'))
        copyfile(currP.channel ,[currP.channel '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
        fprintf('Backup created \n')
    end
    save(currP.channel ,'rej_channel');

    
    
    EEG = pop_select( EEG,'nochannel',rej_channel);
    EEG.preprocess = [EEG.preprocess '_badChannel'];
    
    
end
