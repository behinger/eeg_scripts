function [EEG] = be_import(p,sub)
%% Imports NBP EEG data
% also updates the path before doing it.
% names the EEG.setname to the filename
% EEG = mv_import_cnt(p) % with p = mv_generate_paths(..)
if nargin < 2 || nargin >2
    help be_import
    error('Not enough or too many input arguments %i, should be 1',nargin)
end
% p = be_generate_paths(p);

if strcmp(p.data(sub).eeg(end-2:end),'cnt')
    addpath('/net/store/nbp/projects/lib/anteepimport1.09/')
    fprintf('ANT Detected, importing it. make sure to have the anteepimport1.09 path added to your library!(check the NBP wiki!) \n')
    EEG = pop_loadeep(p.data(sub).eeg,'triggerfile','on');
    
elseif strcmp(p.data(sub).eeg(end-2:end),'set') ||strcmp(p.data(sub).eeg(end-2:end),'fdt')
    fprintf('EEGlab Set detected \n')
    EEG=  pop_loadset(p.data(sub).eeg);
    
elseif strcmp(p.data(sub).eeg(end-3:end),'vhdr')
    fprintf('Brain Vision File detected \n')
    [pathstr,name,ext] = fileparts(p.data(sub).eeg);
    
    if ~exist('pop_loadbv')
        error('pop_loadbv not found. Either eeglab is not initialized or you need to download it. Go to EEGlab - File - Manage EEGlab Extensions - Data Import Extensions and download the loadbv plugin')
    end
    EEG = pop_loadbv(pathstr, [name,ext]);
    
end

% Deblanking, sometimes there are weird characters in the type. Especially
% with ANT systems
for e = 1:length(EEG.event)
    EEG.event(e).type = deblank(EEG.event(e).type);
end
    

EEG.preprocessInfo.import.Date = datestr(now);
tmp = dir(p.data(sub).eeg);
EEG.preprocessInfo.import.rawFileInfo = tmp;
EEG.filepath = fullfile(p.setpath,num2str(sub));
EEG.preprocess = []; %init the preprocessing field used for the filename
EEG = eeg_checkset(EEG);