function EEG = be_load_ICA(EEG,p,sub,IDX)
%% Loads AMICA output specificed in p
% mv_load_ICA(EEG,p)
% Updates the Path
% Prints out all available ICA (if multiple)
% Loads the selected one, or if you provided an IDX loads the one on the
% IDX
% sample: mv_load_ICA(EEG,p,2) % adds the second ICA e.g. p.amica.path{2}
p = be_generate_paths(p);
if ~check_EEG(EEG.preprocess,'Ica')
    
    if length(p.amica(sub).path) > 1 && sum(cellfun(@(x)length(x),p.amica(sub).date)==20)>1 % the second one is to check whether there was actually an amica, or whether it is just the empty folder
        for i = 1:length(p.amica(sub).path)
            fprintf('%i : %s | %s \n',i,p.amica(sub).date{i}, p.amica(sub).path{i})
        end
        if nargin <4
            amica_index=input('Please choose an amica: ');
        else
            amica_index = IDX;
        end
    else
        amica_index = 1;
    end
    fprintf('loading AMICA: %s \n',p.amica(sub).path{amica_index})
    addpath('/net/store/nbp/projects/EEG/blind_spot/amica')
    mod = loadmodout12(p.amica(sub).path{amica_index});
    EEG.icaweights = mod.W;
    EEG.icasphere = mod.S;
    EEG.icawinv = [];EEG.icaact = [];EEG.icachansind = [];
    if isempty(findstr('Ica',EEG.setname))
        EEG.preprocess = [EEG.preprocess '_ica'];
    end
    EEG.preprocessInfo.icaname = p.amica(sub).path{amica_index};
    EEG.preprocessInfo.ICAloadDate = datestr(now);
    EEG.preprocessInfo.chosenICA = amica_index;
    EEG = eeg_checkset(EEG);
    %pop_saveset(EEG,'filename',EEG.setname,'filepath',p.path.set)
end