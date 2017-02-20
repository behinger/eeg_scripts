
function [EEG, reject] = be_clean_trials(EEG,p,sub,varargin)
%function [EEG, reject] = be_clean_trials(EEG,p,sub,[cfg.silent=1/0])
global rej

cfg = finputcheck(varargin,...
    {'silent','boolean',[],0;});


if nargin <3
    error('not enough input arguments to be_clean_trials')
end

EEG = eeg_checkset(EEG);


if exist(p.reject(sub).trial,'file')~=2
    askAppendOverwrite = input('Manualy clean? (y)/(n): ','s');
    
else
    
    tmpRej = load(p.reject(sub).trial);
    reject =tmpRej.reject;
    fprintf('found old rejection file, loading it \n')
    
    if ~cfg.silent
        
        fprintf('%i,',find(reject)),fprintf('\n')
        askAppendOverwrite = input('Manualy clean? (y)/(n): ','s');

    else
        askAppendOverwrite = 'silent';
    end
end




switch askAppendOverwrite
    case 'y'
        eegplot(EEG.data,'srate',EEG.srate,'winlength',8, ...
            'events',EEG.event,'wincolor',[1 0.5 0.5],'command','global rej,rej=TMPREJ',...
            'eloc_file',EEG.chanlocs);
        
        uiwait;
        reject = rej;
        reject = eegplot2trial(reject,EEG.pnts,EEG.trials);
        resave = 1;
    case {'n','silent'}
        resave = 0;
        
    otherwise
        error('User Canceled \n')
end

if exist(p.reject(sub).trial,'file')==2 && resave
    copyfile(p.reject(sub).trial,[p.reject(sub).trial '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
    fprintf('Backup created \n')
end
if resave
    save(p.reject(sub).trial,'reject');
    %     fprintf('Components Saved \n')
end

EEG = pop_rejepoch( EEG, reject,0);
%Save it in the preprocess unit.
EEG.preprocessInfo.trialrej = reject;
EEG.preprocessInfo.cleanTrialDate = datestr(now);
EEG.preprocess = [EEG.preprocess '_trialClean'];

