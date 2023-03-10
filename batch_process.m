%batchprocess

%% batch opti-decode
main_folder = uigetdir('select data directory');
mat_files = dir(fullfile(main_folder, '**/*.mat'));

mattab = struct2table(mat_files); 
roots = mattab.folder;
files = mattab.name;
paths = strcat(roots,filesep,files);
rawfiles = paths(contains(files,'spont_taste'));

sesnos = [1,3,1,2,3];
for i = 1:5
    data = import_taste_data(rawfiles{i}, sesnos(i), "naive");
    decodes = optiwindow(data);
    [decodes,bestdec]= find_best_decodes(decodes,"taste");
    bestdec = enhance_decode(data,bestdec, "taste");
end


parfor i = 1:4
    disp(rawfiles(i))
    %directory handling and preprocessing
    data = import_taste_data(rawfiles(i), sesnos(i), naives(i));
    %load(rawfiles(i));
    decodes = optiwindow(data);%dependencies: data_preprocess, root_dir
    [decodes,bestdec] = find_best_decodes(decodes,"taste");
    bestdec = enhance_decode(data,bestdec, "taste");
end
%% batch MI