function [bool] = check_EEG(setname,whatCheck,varargin)
%% Check EEG for already processed steps
% example: check_EEG('ALpasPil6VReventsResample512','Resample') returns 1
% Additional arguments possible:
% silent(on/off):      Don't ask whether overwrite or not
% overwrite(on/off):   Automatically overwrite (always returns 0)

res = finputcheck(varargin,...
    {'silent'      'string'    {'on','off'}    'off'; ...
     'overwrite'   'string'    {'on','off'}    'off';});
if ischar(res)
    error(res)
end
    
    
if ~isempty(strfind(setname, whatCheck)) && strcmp(res.overwrite,'off')
    bool = true;
    if strcmp(res.silent,'off') && strcmp(input([whatCheck 'already found, do it again (y/n)? '],'s'),'y')
        bool = false;
    end
else
    bool = false;
end


end