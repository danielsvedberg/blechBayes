%batchprocess is my workflow for concurrently databasing and analyzing many
%files/recordings

%% batch opti-decode
main_folder = uigetdir('select data directory'); %find folder where data files live
mat_files = dir(fullfile(main_folder, '**/*.mat')); %this gets the relevant.mat files

%construct a database table of the files:
mattab = struct2table(mat_files); %create a table object with the .mat files
roots = mattab.folder; %vector with root directory for each file
files = mattab.name; %vector with bare file-names for each file
paths = strcat(roots,filesep,files); %create vector with full filepath of each file
rawfiles = paths(contains(files,'spont_taste')); %hard coding specific to me: fiter filepath vector with filename flag
rawf = files(contains(files,'spont_taste')); % filter the files vector to also only contain "spont_taste"
    
sesnos = [1,2,1,2,3,1,2,1,2,3,1,2,3,1,2,3,1,2,3,1,2]; %hardcoding: vector of session # for each recording
parfor i = 1:length(rawf) 
    data = import_taste_data(rawfiles{i}, sesnos(i), "naive");
    decodes = optiwindow(data);
    [decodes,bestdec]= find_best_decodes(decodes,"taste");
    bestdec = enhance_decode(data,bestdec, "taste");
end


parfor i = 1:length(rawf)
    disp(rawfiles(i))
    %directory handling and preprocessing
    data = import_taste_data(rawfiles(i), sesnos(i), naives(i));
    %load(rawfiles(i));
    decodes = optiwindow(data);%dependencies: data_preprocess, root_dir
    [decodes,bestdec] = find_best_decodes(decodes,"taste");
    bestdec = enhance_decode(data,bestdec, "taste");
end


%% analysis to screen for replay
meta = getMetaTable(main_folder);
spontbinsums = {};
file = {};
day = {};
cond = {};
[r, cols] = size(meta);
idx = 1;
for i = 1:r
    files = meta.files{i};
    for j = 1:length(files)
        decinds = meta.decinds{i,j} == 5;
        post = meta.posteriors{i,j};
        spontpost = post(:,decinds,:);
        maxpost = spontpost == max(spontpost);
        binsums = sum(sum(maxpost,3),2);
        totbins = sum(binsums);
        binpct = binsums/totbins;
        spontbinsums{idx} = binpct;
        file{idx} = meta.files{i}(j);
        day{idx} = meta.day(i);
        cond{idx} = meta.cond(i);
        idx = idx+1;
        
    end
    
end

sponttbl = table(file',day',cond',spontbinsums','VariableName',["file","day","exp_group","spont_bin_pcts"]);
sponttbl.spont_bin_pcts = cell2mat(sponttbl.spont_bin_pcts')';
sponttbl.day = cell2mat(day');
sponttbl.exp_group = string(sponttbl.exp_group);

sponttbl_sum = removevars(sponttbl,["file","exp_group"]);
sponttbl_sum = grpstats(sponttbl_sum, ["day"],["mean","meanci"]);

means = sponttbl_sum.mean_spont_bin_pcts;
groups = sponttbl_sum.day;
tastes = ["Suc","NaCl","CA","QHCl","Spont"];
errhigh = sponttbl_sum.meanci_spont_bin_pcts(:,:,2);
errlow = sponttbl_sum.meanci_spont_bin_pcts(:,:,1);
%tastes = repmat(tastes,3,1);
%x = sponttbl_sum.mean_spont_bin_pcts;
p = bar([1,2,3],means');
hold on
% Calculate the number of bars in each group
nbars = size(means, 2);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; p(i).XEndPoints];
end
errorbar(x',means,means-errlow,errhigh-means,'k','linestyle','none');
ylab = ylabel('% bins');
xlab = xlabel('Session #');
legend(tastes,'Location','northwest');
hold off
saveas(gcf,'replay_in_pretaste_spont.png')

