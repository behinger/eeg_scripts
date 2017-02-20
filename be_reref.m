function EEG = be_reref(EEG,p,sub)
    EEG = pop_reref(EEG,[]);
    if strcmp(p.data(sub).eeg(end-2:end),'cnt')
        warning('ANT System detected: Removed additionally FCz to account for the rank reduction')
        % remove a 'random' channel due to rankreduction with av-ref
        EEG = pop_select(EEG,'nochannel',find(cellfun(@(x)~isempty(x),regexpi({EEG.chanlocs.labels},'^FCz'))));
    end
    EEG.preprocess = [EEG.preprocess '_refav'];
    EEG.preprocessInfo.reference = 'AVG';
end