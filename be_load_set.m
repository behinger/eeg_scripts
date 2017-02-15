function [EEG,p] = be_load_set(p,sub,varargin)
%%  [EEG,p] = be_load_set(p,sub,[setID])
p = mof_generate_paths(p);
if ~isfield(p,'eegset')
    error('no sets found')
end
sets = p.eegset(sub);
if nargin >= 3
    if ~isnumeric(varargin{1})
        error('Setselection has to be a Number')
    end
    setIdx = varargin{1};
else
    for i = 1:length(sets.path)
        fprintf('%i : %s | %s \n',i,sets.date{i}, sets.path{i});
    end
    setIdx=input('Please choose a Set to load: ');
end
if nargin ==4
    loadmode = varargin{2};
else
    loadmode ='all';
end

EEG = pop_loadset('filename',sets.path{setIdx},'loadmode',loadmode);


end