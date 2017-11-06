function [EEG,excludeChan]= be_removeCommonChannels(EEG,remove)
    if nargin == 1
        remove = 0;
    end
    lab = {EEG.chanlocs.labels};
    % ANT system AUX/BIP channels 
    excludeChan= find(cellfun(@(x)~isempty(x),regexpi(lab,'AUX*')) |  cellfun(@(x)~isempty(x),regexpi(lab,'BIP*')) );
    
    % eyeeeg channels
    excludeChan = [excludeChan find(cellfun(@(x)ismember(x,{'TIME'    'L_GAZE_X'    'L_GAZE_Y'    'L_AREA'    'R_GAZE_X'    'R_GAZE_Y'    'R_AREA'    'INPUT'}),lab))];
    
    fprintf('Excluding the following channels from the reference: \n')
    fprintf('%s, ',lab{excludeChan})
    fprintf('\n')
    if remove
        EEG = pop_select(EEG,'nochannel',excludeChan);
    end