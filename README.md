Current pipeline looks like this:

```matlab
function pilot_continuous_preprocessing(subject,manual,runica)
% manual => for cleaning once
% runica => runs ICA on 2Hz filtered data and removes some channels if necessary
if nargin == 1
    manual = 0;
    runica = 0;
elseif nargin==2
    runica = 0;
end

%%

cfg = struct();
cfg.subject = subject; %3
p = be_generate_paths('/net/store/nbp/projects/mof');
% readtable(p.data(cfg.subject).csv);



%% Import Chanlocs and Filter

try
    EEG = be_load_set(p,cfg.subject,1);
catch
    EEG = be_import(p,cfg.subject); 
    
    % add chanlocs
    if cfg.subject == 8
        % in this subject we recorded with the second set of channels,
        % but still have the labels of the first amplifier. Fixing this
        EEG2 = pop_loadset('filepath',p.eegset(5).path{1},'loadmode','info'); % load a 128 Elec file
        
        EEG.chanlocs(1:end-1) = EEG2.chanlocs(73:end); % overwrite it
        EEG.chanlocs(31).labels = 'Iz'; % this one in the 128E is CzOtherAmp, but here it is Iz
    end
    
    if strcmp(p.data(cfg.subject).eeg(end-2:end),'cnt')
        %ANT  Elec
        EEG=pop_chanedit(EEG, 'lookup','/net/store/nbp/users/behinger/projects/mof/git/lib/eeglab/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
    else
        %64 Elec
        EEG.chanlocs = readlocs('/net/store/nbp/projects/lib/easycap_64/actiCAP64Ch_Montage72.elp','filetype','custom','format',{'channum','sph_phi_besa','sph_theta_besa'});
    end
    
    % filter
    EEG = be_filter_cont(EEG,1,120);
    
    
    % add eyetracking
    eyemat = parseedf(p.data(subject).edf);
    EEG = pop_importeyetracker(EEG,eyemat,[5 5],1:length(eyemat.colheader),eyemat.colheader,1,0,0,0);
    etchan = strcmp('EYE',{EEG.chanlocs.type});
    EEG.etdata = EEG.data(etchan,:);
    EEG.data(etchan,:) = [];
    EEG.etchanlocs = EEG.chanlocs(etchan);
    EEG.chanlocs(etchan) = [];
    EEG.nbchan = EEG.nbchan - sum(etchan);
    EEG = eeg_checkset(EEG);
    EEG.preprocess = [EEG.preprocess '_ET'];
    
    % add csv
    EEG = mof_addcsv(EEG,p,cfg.subject);
   
    be_save_set(EEG)
    
end


if manual
    fprintf('close the eegplot window to auto continue \n')
    pop_eegplot(EEG);    
end
EEG.urchanlocs = EEG.chanlocs;
EEG = be_reject_channel(EEG,p,cfg.subject,'silent',~manual);

EEG = be_reref(EEG,p,cfg.subject);





if manual
    EEG = be_clean_continuous(EEG,p,cfg.subject);
else
    EEG = be_clean_continuous(EEG,p,cfg.subject,'silent',1);
end
%% Custom Functionsnot in be_pipeline
if runica
    EEG = be_removeCommonChannels(EEG,1);
    EEG = be_filter_cont(EEG,2,120);
    
    EEG.preprocess = [EEG.preprocess '_icaready'];
    be_save_set(EEG)
    be_amica_grid(p,cfg.subject,2) %vp 3, set 2
    return
end


%%
EEG = be_load_ICA(EEG,p,cfg.subject);
EEG = be_ICA_mark(EEG,p,cfg.subject);

% EEG = pop_selectcomps_behinger(EEG,1:35)
EEG = pop_subcomp(EEG,[],0);
EEG.preprocess = [EEG.preprocess '_componentsRemoved'];

EEG = pop_interp(EEG,EEG.urchanlocs,'spherical');
EEG.preprocess = [EEG.preprocess '_interpol'];
EEG = eeg_checkset(EEG);


% We could remove portions of data based on the eyetracking, but we are
% not doing it here
%fin = @(field)find(strcmp(field,{EEG.chanlocs.labels}));
%EEG =     pop_rej_eyecontin(EEG,[fin('R_AREA'),fin('L_AREA')],[0 0],[1000 1000],0)

    
be_save_set(EEG)
```
