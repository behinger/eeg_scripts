function be_save_set(EEG)
%%  [EEG,p] = be_load_set(p,varargin)

EEG = pop_saveset(EEG,'filename',EEG.preprocess,'filepath',EEG.filepath);


end