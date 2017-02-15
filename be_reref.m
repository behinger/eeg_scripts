function EEG = be_reref(EEG,p)
    EEG = pop_reref(EEG,[]);
    EEG.preprocess = [EEG.preprocess 'Refav'];
    EEG.preprocessInfo.reference = 'AVG';
    


end