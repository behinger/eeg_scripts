function EEG = be_reref(EEG,p,sub)
    EEG = pop_reref(EEG,[]);
    if strcmp(p.data(sub).eeg(end-2:end),'cnt')
        warning('ANT System detected: Removed additionally FCz to account for the rank reduction')
        % remove a 'random' channel due to rankreduction with av-ref
        remChan = find(cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'^FCz')));
        if isempty(remChan)
            warning('could not find FCz, removing FT10 instead')
            remChan = find(cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'FT10')));
        end
        EEG = pop_select(EEG,'nochannel',remChan);
    end
    EEG.preprocess = [EEG.preprocess '_refav'];
    EEG.preprocessInfo.reference = 'AVG';
end