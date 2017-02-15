function EEG = be_filter_cont(EEG,varargin)
%% mv_filter_cont(EEG,p,[lowCutOff,highCutOff])
% Please define both low and high.
% Filter ised is: pop_eegfiltnew
if ~check_EEG(EEG.preprocess,'Filt')
    
    if nargin <2
        lowCutOff = 1;
        highCutOff = 120;
        
    elseif nargin == 3
        lowCutOff = varargin{1};
        highCutOff = varargin{2};
    else
        error('wrong input number')
    end
    type = 'eegfiltnews';
    
    %     EEG = pop_eegfilt( EEG, lowCutOff, 0, [], 0,0,type); %highpass
    %     EEG = pop_eegfiltnew(EEG,lowCutOff,highCutOff);
    if ~isempty(highCutOff)
        [EEG,~,bHP] = pop_eegfiltnew(EEG,[],highCutOff);
    else
        bHP = '';
    end
    
    if ~isempty(lowCutOff)
        [EEG,~,bLP] = pop_eegfiltnew(EEG,lowCutOff,[]);
    else
        bLP = '';
    end
    %     EEG = pop_eegfilt( EEG, 0, highCutOff, [], 0,0,type); % lowpass
    EEG = eeg_checkset( EEG );
    EEG.preprocessInfo.filter.type = type;
    EEG.preprocessInfo.filter.eegfiltnew = 1;
    EEG.preprocessInfo.filter.lowCutoff = lowCutOff;
    EEG.preprocessInfo.filter.highCutoff = highCutOff;
    EEG.preprocessInfo.filter.date = datestr(now);
    EEG.preprocessInfo.filter.bLP = bLP;
    EEG.preprocessInfo.filter.bHP = bHP;
    EEG.preprocess = [EEG.preprocess 'Filtfir'];
end