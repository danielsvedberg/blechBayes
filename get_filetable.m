function tbl = get_filetable(main_folder)

if ~exist('main_folder')
    main_folder = uigetdir('select data directory');
end

mat_files = dir(fullfile(main_folder, '**/*.mat'));

initab = struct2table(mat_files);

filenames = initab.name; %get all .mat files in main_folder
filenames = convertCharsToStrings(filenames); %convert to string array for easy idxing
rootpaths = initab.folder; %get all paths to .mat files in main_folder
rootpaths = convertCharsToStrings(rootpaths); %same as above

prepIdxs = contains(filenames,'preprocessed'); %get indices for preprocessed data
decodeIdxs = contains(filenames,'decode'); %get indices for decodes
optiIdxs = contains(filenames,'opti'); %get indices for decode optimizations
rawIdxs = ~(preprocessedIdxs + decodeIdxs + optiIdxs); %raw files are all the files that are not what's above

raw_files = filenames(rawIdxs); 
prep_files = filenames(prepIdxs);
decode_files = filenames(decodeIdxs);
opti_files = filenames(optiIdxs);

filechunks = split(raw_files','_'); %key info is in the name of the raw data

anIDs = filechunks(:,:,1);
dates = filechunks(:,:,end-1);
rawroots = rootpaths(rawIdxs);

tbl = table(anIDs', dates', raw_files, rawroots, 'VariableNames',["anID", "datestr","root_dir","raw_data_file"]);
tbl.date = datetime(tbl.datestr, 'InputFormat','yyMMdd');
tbl = grouptransform(tbl,'anID',@min,'date','ReplaceValues',false);
tbl.session = days(tbl.date-tbl.fun_date)+1;


prepdate = 


% datainfos = dir('/home/dsvedberg/Documents/MATLAB/**/*spont*.mat');
% datainfos = datainfos(~contains({datainfos.name}, ["decode","DS23","200201"]));
% datafile = string({datainfos.name});
% 
% decodeinfos = dir('/home/dsvedberg/Documents/MATLAB/**/*tastedecode*.mat');
% decodeinfos = decodeinfos(~contains({decodeinfos.name}, ["DS23","200201"]));
% decodefile = string({decodeinfos.name});
% 
% nrnavginfos = dir('/home/dsvedberg/Documents/MATLAB/**/*nrnavgdecode*.mat');
% nrnavginfos = nrnavginfos(~contains({nrnavginfos.name}, ["DS23","200201"]));
% nrnavgfile = string({nrnavginfos.name});
% 
% datatable = filesanddatestable(datafile');
% datatable = renamevars(datatable, ['filelist'],['datafile']);
% 
% decodetable = filesanddatestable(decodefile');
% decodetable = renamevars(decodetable, ['filelist'],['decodefile']);
% 
% nrnavgtable = filesanddatestable(nrnavgfile');
% nrnavgtable = renamevars(nrnavgtable, ['filelist'],['nrnavgfile']);
% 
% filetable = outerjoin(datatable,decodetable,'mergekeys',true);
% filetable = outerjoin(filetable,nrnavgtable,'mergekeys',true);
% 
% 
% experience = table(["DS31" "DS33" "DS36" "DS39" "DS40" "DS41" "DS42" "DS44" "DS45" "DS46" "DS47"]',...
%     ["Naive" "Naive" "Naive" "Naive" "Naive" "Suc_Preexp" "Suc_Preexp" "Suc_Preexp" "Suc_Preexp" "Naive" "Suc_Preexp"]',...
%     'Variablenames',{'animal','experience'});
% filetable = outerjoin(filetable,experience,'mergekeys',true);

end