function EEG = be_reject_channel_v2(EEG,p,sub,varargin)
% be_reject_channel_2(EEG,p,subjectID,'silent',1)
cfg = finputcheck(varargin,...
    {'remove_channel','cell',[],[];
    'silent','boolean',[],0;});
if ischar(cfg)
    error(cfg)
end
pathToRejectfile= p.reject(sub);

% check that badChannel has not been done before
% if, prompt to continue
check_EEG(EEG.preprocess,'badChannel')

rej_channel = [];
if ~isempty(cfg.remove_channel)
    rej_channel = [rej_channel cfg.remove_channel];
end

if exist(pathToRejectfile.channel,'file')==2
    tmp = load(pathToRejectfile.channel);
    rej_channel = [rej_channel tmp.rej_channel];
end


print_curr_rej_channel(rej_channel);

if ~cfg.silent
    askAppendOverwrite = input('What to do with old rejection channels? (o)verwrite/(a)ppend/(u)se old/(c)ancel: ','s');
    
    if strcmp(askAppendOverwrite,'o')
        fprintf('overwriting...\n')
        rej_channel = [];
    elseif  strcmp(askAppendOverwrite,'c')
        error('cancel...\n')
        
    end
    
    if ~strcmp(askAppendOverwrite,'u')
        fprintf('appending...\n')
        rej_channel = [rej_channel input('Which channels to reject e.g. {''Fz'',''AFF2''}? ')];
    end

end
print_curr_rej_channel(rej_channel);

if ~isdir(p.rejectpath),          mkdir(p.rejectpath);     end

% save only if not silent & not the old file was used
if ~cfg.silent && (~exist('askAppendOverwrite','var') || ~strcmp(askAppendOverwrite,'u'))
    % If file exists already, make backup
    if exist(pathToRejectfile.channel ,'file')==2
        copyfile(pathToRejectfile.channel ,[pathToRejectfile.channel '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
        fprintf('Backup created \n')
    end
    save(pathToRejectfile.channel ,'rej_channel');
end


EEG = pop_select( EEG,'nochannel',rej_channel);
EEG.preprocess = [EEG.preprocess '_badChannel'];


end

function print_curr_rej_channel(rej_channel)

fprintf('Currently Rejected Channels \n')
for k = 1:length(rej_channel)
    fprintf('%7s ,', rej_channel{k});
end
fprintf('\n')
end