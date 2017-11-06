function [pStruct] = be_generate_paths(folder)
% Change this function to your local project
%% Check folder Structure


%%

if isstruct(folder) %in this case we want to update p!
    % the input file is in this case p!
    
    folder = folder.mainpath;
end

if ~exist(folder,'dir')
   folder = ['e:' folder];
    if ~exist(folder,'dir')
        error('could not find folder')
    end
end
pStruct = struct();
pStruct.mainpath = folder;
pStruct.datapath = fullfile( pStruct.mainpath ,'data');
rawPathDir =dir(pStruct.datapath);
for k = 3:length(rawPathDir) % skipping '.' and '..'

    subjectName= rawPathDir(k).name; % subject name
    [s,e] = regexp(subjectName,'[0-9]{1,2}');
    subject_nr = str2num(subjectName(s:e));
        
    assert(isnumeric(subject_nr))
    
    % just in case we fuck up and have multiple sets or something I
    % leave this here
    %         for m = 3:length(subjectDir)
    %             tmpXf = subjectDir(m).name;
    %             if any(strfind(tmpXf,'.vhdr')) || any(strfind(tmpXf,'.set'))
    %                 if ~isempty(file)
    %                     fprintf('%%%%%%%%%%%%%%%%%% \n')
    %                     fprintf('multiple EEG files found! 1) %s \t 2) %s \n',file,tmpXf)
    %                     fprintf('%%%%%%%%%%%%%%%%%% \n')
    %                 end
    %                 file= [tmpXf];
    %             end
    %         end
    
    eegFile = [dir(fullfile(pStruct.datapath,subjectName,'*.vhdr')) dir(fullfile(pStruct.datapath,subjectName,'*.cnt'))];
    edfFile = dir(fullfile(pStruct.datapath,subjectName,'*.edf'));
    csvFile = dir(fullfile(pStruct.datapath,subjectName,'*.csv'));
    
    
    pStruct.data(subject_nr).subject = subjectName;
    pStruct.data(subject_nr).eeg= fullfile(pStruct.datapath,subjectName,eegFile.name);
    pStruct.data(subject_nr).edf= fullfile(pStruct.datapath,subjectName,edfFile.name);
    pStruct.data(subject_nr).csv= fullfile(pStruct.datapath,subjectName,csvFile.name);
    
    
    %% Find all ICA's
    pStruct.amicapath = fullfile(pStruct.mainpath,'amica');
    if ~exist(pStruct.amicapath,'dir')
        mkdir(pStruct.amicapath)
    end
    amicaSubjectPath = fullfile(pStruct.amicapath ,num2str(subject_nr));
    if ~exist(amicaSubjectPath,'dir')
        mkdir(amicaSubjectPath)
    end
    
    pStruct.amica(subject_nr).mainpath = amicaSubjectPath;
    tmp = dir(amicaSubjectPath);
    if ~isempty(tmp)
        tmp(1:2) = []; % remove '.' and '..'
    end
    if isempty(tmp)
        pStruct.amica(subject_nr).path{1} = fullfile(amicaSubjectPath,'amica_run_1');
        pStruct.amica(subject_nr).date{1} = date;
    else
        
        for biggestICA = 1:length(tmp)
            if biggestICA== 1
            pStruct.amica(subject_nr).path{1} = fullfile(amicaSubjectPath,tmp(1).name);
            pStruct.amica(subject_nr).date{1} = [tmp(1).date];
            else
            pStruct.amica(subject_nr).path{end+1} = fullfile(amicaSubjectPath,tmp(biggestICA).name);
            pStruct.amica(subject_nr).date{end+1} = tmp(biggestICA).date;
            end
        end
        
        pStruct.amica(subject_nr).path{end+1} = fullfile(amicaSubjectPath,['amica_run_' num2str(biggestICA+1)]);
        pStruct.amica(subject_nr).date{end+1} = [];
    end
    
    
        %%
    pStruct = generate_folder(pStruct,subject_nr,'set','setpath','eegset','*.set');
    pStruct = generate_folder(pStruct,subject_nr,'postprocessing','postprocessingpath','postprocessing','*.*');
    pStruct = generate_folder(pStruct,subject_nr,'reject','rejectpath','reject',{'channel.mat','continuous.mat','trial.mat'},0);
    
    % Generate one rejection file per AMICA folder
    pStruct.reject(subject_nr).ica = {};
    basepath = pStruct.reject(subject_nr).mainpath;

    for k = find(cellfun(@(x)~isempty(x),pStruct.amica(subject_nr).date))    
        pStruct.reject(subject_nr).ica(end+1) = {fullfile(basepath,sprintf('ICA_run_%i_date_%s.mat',k,pStruct.amica(subject_nr).date{k}))};       
    end
% 
    
end
pStruct.subjects = 1:length(pStruct.data);
pStruct.subjects(cellfun(@(x)isempty(x),{pStruct.data(:).subject})) = nan;
[~,projName] = fileparts(pStruct.mainpath);
pStruct.project = projName;
end


function pStruct = generate_folder(pStruct,subject_nr,folderName,fieldPathName,fieldSubjectName,fileending,varargin)
if nargin == 7
    autoSearch = varargin{1};
else 
    autoSearch = 1;
end

    pStruct.(fieldPathName) = fullfile(pStruct.mainpath,folderName);
    if ~exist(pStruct.setpath,'dir')
        mkdir(pStruct.setpath)
    end
    setSubjectPath = fullfile(pStruct.(fieldPathName) ,num2str(subject_nr));
    if ~exist(setSubjectPath,'dir')
        mkdir(setSubjectPath)
    end
    
    pStruct.(fieldSubjectName)(subject_nr).mainpath = setSubjectPath;
    if autoSearch
        tmp = dir(fullfile(setSubjectPath,fileending));
        tmp(cellfun(@(x)all(unique(x) == '.'),{tmp(:).name})) = []; % remove '.' and '...'
            
        if ~isempty(tmp)
            pStruct.(fieldSubjectName)(subject_nr).path{1} = fullfile(setSubjectPath,tmp(1).name);
            pStruct.(fieldSubjectName)(subject_nr).date{1} = [tmp(1).date];
            for i = 2:length(tmp)
                pStruct.(fieldSubjectName)(subject_nr).path{end+1} = fullfile(setSubjectPath,tmp(i).name);
                pStruct.(fieldSubjectName)(subject_nr).date{end+1} = tmp(i).date;
            end
        end
    else
        for c = 1:length(fileending)
            [~,name,~] = fileparts(fileending{c});
            pStruct.(fieldSubjectName)(subject_nr).(name) = fullfile(setSubjectPath,fileending{c});
        end
        
    end
end