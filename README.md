Current pipeline looks like this:

```matlab
cfg = struct();
cfg.subject = 1;
p = be_generate_paths('/net/store/nbp/projects/mof');
 
        EEG = be_import(p,cfg.subject); % import subject
        
        % Load Channels
        if strcmp(p.data(cfg.subject).eeg(end-2:end),'cnt')
            % ANT  Elec
            EEG=pop_chanedit(EEG, 'lookup','/net/store/nbp/users/behinger/projects/mof/git/lib/eeglab/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
        else
           % 64 Elec 
           EEG.chanlocs = readlocs('/net/store/nbp/projects/lib/easycap_64/actiCAP64Ch_Montage72.elp','filetype','custom','format',{'channum','sph_phi_besa','sph_theta_besa'});
        end
        
        % Filter 1/120 Hz
        EEG = be_filter_cont(EEG,1,120);
        
        %Save it
        be_save_set(EEG)
        
    end
   
    % remove all the AUX/BIP channels
    if 1 == 0
      % You have to do this the first time manually. In this case I remove all electrodes of the second amp
      % and Cz
      badChan = find(cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'^Cz')) | cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'AUX*')) |  cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'BIP*')) );
      badChan = unique([badChan 73:143]);        

      EEG = be_reject_channel(EEG,p,cfg.subject,badChan);
    else
      EEG = be_reject_channel(EEG,p,cfg.subject,'silent',1);
    end
    
    EEG = be_reref(EEG,p,sub);  
    
    be_save_set(EEG)
end
% Runs AMICA on the grid.
% be_amica_grid(p,cfg.subject,2) % run on Set 2 the ICA
%% Load ICA
EEG = be_load_ICA(EEG,p,cfg.subject);

%% Manually mark the components
EEG = be_ICA_mark(EEG,p,cfg.subject);

% Delete the components
EEG = pop_subcomp(EEG,[],0);

EEG = eeg_checkset(EEG);
be_save_set(EEG)
```
