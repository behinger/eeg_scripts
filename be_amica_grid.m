function [] = be_amica_grid(p,sub,varargin)
% varargin => Dataset, AMICA-folder, 'runlocally'
%function [] = be_amica_grid(p,sub,[setid],[amicaid])

if nargin < 1
    error('You have to define the structure ''p'' with the function generate_paths')
end

p = be_generate_paths(p);



fprintf('Path updated \n')
sets = p.eegset(sub);
if nargin>2
    chosenSet = varargin{1};
elseif length(sets.path)>1
    
    for i = 1:length(sets.path)
        fprintf('%i : %s | %s \n',i,sets.date{i}, sets.path{i});
    end
    chosenSet = input('Which set should the ICA run on? ');
else
    chosenSet = 1;
end


if nargin>3
    amicaChosenPath = varargin{2};
elseif length(p.amica(sub).path)>1
    for i = 1:length(p.amica(sub).path)
        fprintf('%i : %s  \n',i,p.amica(sub).path{i})
    end
    amicaChosenPath = input('Where should the amica be saved? ');
else
    amicaChosenPath = 1;
end



cmd_grid = [
    'init_' p.project ';p = be_generate_paths(''' p.mainpath ''');runamica12(p.eegset(' num2str(sub) ').path{' num2str(chosenSet) '},''outdir'',''' p.amica(sub).path{amicaChosenPath} ''',''num_models'',1,''share_comps'',1,'...
    ' ''do_reject'',1,''numrej'',5,''rejsig'',3,''max_threads'',7)']

if nargin > 4 && strcmp(varargin{3},'runlocal')
    %run locally
    eval(cmd_grid)
else
    % run on grid
    nbp_grid_start_cmd(cmd_grid,'jobnum',1,'requ','mem=5G,h=!ramsauer.ikw.uni-osnabrueck.de','out',fullfile(p.mainpath,'gridlogs'),'parallel',7)

end
