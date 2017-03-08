function [EEG reject] = be_ICA_mark(EEG,p,sub,varargin)
%% be_ICA_mark(EEG,p,1,manualRejStruct)
% this function can be used to load the saved badComponents e.g.:
%  [~,reject] = be_ICA_mark(EEG,p,1)
% add new RejectStruct
%  be_ICA_mark(EEG,p,reject,1)
% manually clean
%  be_ICA_mark(EEG,p)
% add the rejections to EEG
%  EEG = be_ICA_mark(EEG,p,1)
global rej
rej = 0;
% check
% % glbal EEG
% if isstruct(EEG)
%     warning('Local EEG found, but this is a function call (be_ICA_mark). Will overwrite the local EEG if manual cleaning was asked!!!')
% end
silent = 0;
if nargin > 3
    for l = 1:length(varargin)
        if isnumeric(varargin{l})
            silent = 1;
        
            error('unkown varargin in be_ICA_mark')
        end
    end
    
end

if nargin <3
    error('not enough input arguments to be_ICA_mark')
end

EEG = eeg_checkset(EEG);

if exist(p.reject(sub).ica{EEG.preprocessInfo.chosenICA},'file')==2
    reject = load(p.reject(sub).ica{EEG.preprocessInfo.chosenICA});
    reject = reject.reject;
    tmp = dir(p.reject(sub).ica{EEG.preprocessInfo.chosenICA});
    fprintf('%s: Reject \n',tmp.date)
    fprintf('%i,',find(reject==1)),fprintf('\n')
else
    reject = 0;
end



if ~silent
    askAppendOverwrite = input('Manualy clean? (y)/(n): ','s');
else
    askAppendOverwrite = 'silent';
end




switch askAppendOverwrite
    case 'y'
        EEG.reject.gcompreject = EEG.reject.gcompreject==1 | reject == 1;
        
        
        [handles] = pop_selectcomps_behinger(EEG,1:EEG.nbchan);
        waitfor(handles)
        fprintf('press any key to continue \n')            ,pause
        
        reject = rej;%EEG.reject.gcompreject;
        fprintf('marked components:')
        fprintf('%i,',find(reject))
        fprintf('\n')
        resave = 1;
    case {'n','silent'}
        %EEG.reject.gcompreject = reject;
        resave = 0;
    otherwise
ee        error('User Canceled \n')
end

if exist(p.reject(sub).ica{EEG.preprocessInfo.chosenICA},'file')==2 && resave
    copyfile(p.reject(sub).ica{EEG.preprocessInfo.chosenICA},[p.reject(sub).ica{EEG.preprocessInfo.chosenICA } '.bkp' datestr(now,'mm-dd-yyyy_HH-MM-SS')]);
    fprintf('Backup created \n')
end
if resave
    save(p.reject(sub).ica{EEG.preprocessInfo.chosenICA},'reject');
    fprintf('Components Saved \n')
end
EEG.reject.gcompreject = reject;
