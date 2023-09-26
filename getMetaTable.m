function [meta] = getMetaTable(main_folder)

if ~exist('main_folder', 'var')
    filetable = get_filetable();
else
    filetable = get_filetable(main_folder);
end

meta = table();
daysElap = unique(filetable.session);
exp = unique(filetable.exp_group);
idx = 1;
for d = daysElap'
    for cond = 1:length(exp)
        meta.root(idx) = filetable.root_dir(idx);
        meta.day(idx) = d;
        meta.cond(idx) = exp(cond);
        rows = filetable.session == d & filetable.exp_group == exp(cond);
        meta.files{idx} = string(filetable.root_dir(rows)) + filesep + string(filetable.decode_file(rows));
        meta.n_an(idx) = length(meta.files{idx});
        for i = 1:meta.n_an(idx)
            load(meta.files{idx}(i))
            meta.decinds{idx,i} = decode.decind;
            meta.traininds{idx,i} = decode.trainind;
            meta.windows{idx,i} = decode.windows;
            meta.posteriors{idx,i} = decode.posterior;
            meta.avgPosteriors{idx,i} = decode.avgPosterior;
            meta.winPosts{idx,i} = decode.winpost;
            meta.perClasses{idx,i} = decode.perClass;
            meta.IDs{idx,i} = decode.ID;
            meta.Dates{idx,i} = decode.Date;
            meta.trlNos{idx,i} = decode.trlno;
            meta.winAvgs{idx,i} = decode.winAvg;
            
        end
        idx = idx+1;
    end
end

