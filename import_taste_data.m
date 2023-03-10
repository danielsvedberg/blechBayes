function [data] = import_taste_data(file,day,exp_group)
%dialogue box queries user to select file if not supplied
if ~exist('file','var')
    [file,origin] = uigetfile('.mat','select data_file'); 
end

%destination folder for datasets defaults to working directory if not
%supplied
% if ~exist('dest_folder', 'var')
%     dest_folder = pwd;
% end

[root_dir, name, ext] = fileparts(file); %separate (file)name and extension from path
nameparts = split(name,"_"); %split filename by _ to get anID and date
nameparts = convertCharsToStrings(nameparts);
anID = nameparts(1); %first block is always anID
date = nameparts(end-1); %second-to-last block always date
filename = strcat(anID,"_",date,"_","preprocessed",ext);
filepath = strcat(root_dir,filesep,filename);

if ~exist(filepath,'file')
    disp("making new preprocessed file")
    load(file, 'data');
    data.filename = filename;
    data.anID = anID;
    data.date = date;
    data.Date = date;
    data.path = filepath;
    data.root_dir = root_dir;

    %dialogue box queries user to supply day (1-3) if not supplied in function
    if exist('day','var')
        data.exp_day = day; 
    else
        data.exp_day = input('input experiment day: ');
    end

    %dialogue box queries user to supply if animal is naive (True/False) if not supplied in function
    if exist('exp_group','var')
        data.exp_group = exp_group;
    else
        data.exp_group = input('input experiment group string: ');
    end

    %run preprocessing on data
    data = data_preprocess(data);

    save(data.path,'data','-v7.3')
else
    load(filepath, 'data');
    disp("file already found")
end

end

