% fl{1} = expLib.best_taste_dec(expLib.exp_day == 1); 
% fl{3} = expLib.best_taste_dec(expLib.exp_day == 3);

% fl{1} = filetable.decodefile(filetable.session == 1 & filetable.experience == "suc_preexp"); %for thomas rotation
% fl{2} = filetable.decodefile(filetable.session == 2 & filetable.experience == "suc_preexp");
% 
% day = struct();
% for j = [1 2]
%     for i = 1:length(fl{j})
%         load(fl{j}(i));
%         disp(fl{j}(i));
%         day(j).decinds{i} = decode.decind;
%         day(j).traininds{i} = decode.trainind;
%         day(j).windows{i} = decode.windows;
%         day(j).posteriors{i} = decode.posterior;
%         day(j).avgPosteriors{i} = decode.avgPosterior;
%         day(j).winPosts{i} = decode.winpost;
%         day(j).perClasses{i} = decode.perClass;
%         day(j).IDs{i} = decode.ID;
%         day(j).Dates{i} = decode.Date;
%         day(j).trlNos{i} = decode.trlno;
%         day(j).winAvgs{i} = decode.winAvg;
%     end
% end
%%
%n_an = 5;
%regular decoding meta analysis
filetable = get_filetable();
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

%%
%
filetable = get_filetable();
nrnavgmeta = table();
days = unique(filetable.session);
exp = unique(filetable.exp_group);
idx = 1;
for d = days'
    for cond = 1:length(exp)
        nrnavgmeta.day(idx) = d;
        nrnavgmeta.cond(idx) = exp(cond);
        nrnavgmeta.files(idx) = {filetable.decode_file(filetable.session == d & filetable.exp_group == exp(cond))};
        nrnavgmeta.n_an(idx) = length(nrnavgmeta.files{idx});
        for i = 1:nrnavgmeta.n_an(idx)
            load(nrnavgmeta.files{idx}(i))
            nrnavgmeta.decinds{idx,i} = decode.decind;
            nrnavgmeta.traininds{idx,i} = decode.trainind;
            nrnavgmeta.windows{idx,i} = decode.windows;
            nrnavgmeta.posteriors{idx,i} = decode.posterior;
            nrnavgmeta.avgPosteriors{idx,i} = decode.avgPosterior;
            nrnavgmeta.winPosts{idx,i} = decode.winpost;
            nrnavgmeta.perClasses{idx,i} = decode.perClass;
            nrnavgmeta.IDs{idx,i} = decode.ID;
            nrnavgmeta.Dates{idx,i} = decode.Date;
            nrnavgmeta.trlNos{idx,i} = decode.trlno;
            nrnavgmeta.winAvgs{idx,i} = decode.winAvg;
            
        end
        idx = idx+1;
    end
end

%%
sts = 5; 
trlpdiv = 5; 
ndivs = 30/trlpdiv;
%g is (day x cond)
%blacklist = ["DS40","DS47"];
for g = 1:6
    n_an = meta.n_an(g);
    if n_an > 0
        winavg_agg = zeros(n_an,sts,sts);
        winavg_diag = zeros(n_an,sts);
        winposts_agg = zeros(n_an,sts,120);
        for an = 1:n_an
            winposts_agg(an,:,:) = meta.winPosts{g,an}(:,1:120); %winposts_agg is just making a matrix from a cell array for just taste trials
            winavg_agg(an,:,:) = meta.winAvgs{g,an};
            winavg_diag(an,:) = diag(squeeze(winavg_agg(an,:,:)));
        end
        %bintrls = n_an * 4 * 6; %every set of bintrls is n_an * #tastes * #bintrls/taste
        bintrls = n_an * 4 * trlpdiv;
        meta.winposts_corct{g} = zeros(n_an,120);
    %     day(d).winposts_palAsUnpal= zeros(n_an,60);
    %     day(d).winposts_unpalAsPal = zeros(n_an,60);

    %     palAsUnpalbools = zeros(5,120);
    %     palAsUnpalbools(:,1:60) = palAsUnpalbools(:,1:60) + [false false true true false]';
    %     palAsUnpalbools = logical(palAsUnpalbools);
    %     unpalAsPalbools = zeros(5,120);
    %     unpalAsPalbools(:,61:120) = unpalAsPalbools(:,61:120) + [true true false false false]';
    %     unpalAsPalbools = logical(unpalAsPalbools);
        for an = 1:n_an
            wpag = squeeze(winposts_agg(an,:,:));
            inds = meta.decinds{g,an}(1:120);
            boolind = (zeros(1,120) + [1 2 3 4 5]') == inds;
            meta.winposts_corct{g}(an,:) = wpag(boolind);
            badtrls = meta.traininds{g,an}(1:120) == 0;
            meta.winposts_corct{g}(an,badtrls) = nan;
%             if any(meta.IDs{g,an} == blacklist)
%                 meta.winposts_corct{g}(an,:) = nan;
%             end

    %         palAsUnpalVals = wpag(palAsUnpalbools);
    %         palAsUnpalVals = reshape(palAsUnpalVals, 2, []);
    %         day(d).winposts_palAsUnpal(an,:) = nansum(palAsUnpalVals);
    %         day(d).winposts_palAsUnpal(an,badtrls(1:60)) = nan;
    %         
    %         unpalAsPalVals = wpag(unpalAsPalbools);
    %         unpalAsPalVals = reshape(unpalAsPalVals, 2, []);
    %         day(d).winposts_unpalAsPal(an,:) = nansum(unpalAsPalVals);
    %         day(d).winposts_unpalAsPal(an,badtrls(61:end)) = nan;       
        end
        
        
        meta.bin_tasteposts{g} = reshape(meta.winposts_corct{g}, [],4);%reshape to trls x tastes(?)
        meta.bin_winposts{g} = reshape(meta.bin_tasteposts{g}', bintrls, []); 
        meta.bin_tasteposts{g} = reshape(meta.bin_tasteposts{g}, [], ndivs, 4);



    %     day(d).bin_winposts_unpalAsPal = reshape(day(d).winposts_unpalAsPal, [], 2);
    %     day(d).bin_winposts_unpalAsPal = reshape(day(d).winposts_unpalAsPal' , 60, []); 
    %     day(d).bin_winposts_unpalAsPal = reshape(day(d).winposts_unpalAsPal' , 12, []);
    %     day(d).bin_winposts_palAsUnpal = reshape(day(d).winposts_palAsUnpal, [], 2);
    %     day(d).bin_winposts_palAsUnpal = reshape(day(d).winposts_palAsUnpal', 60, []); 
    %     day(d).bin_winposts_palAsUnpal = reshape(day(d).winposts_palAsUnpal', 12, []);

    %     day(d).mean_winposts_corct = nanmean(day(d).mean_winposts_corct,1);
    %     day(d).binwin_avg = nanmean(day(d).bin_winposts);
    %     day(d).binwin_sem = nanstd(day(d).bin_winposts,1)./sqrt(size(day(d).bin_winposts,1));
    %     ts = tinv([0.025 0.975], size(day(d).bin_winposts,1)-1);
    %     day(d).binwin_95CIerr = ts(2)*day(d).binwin_sem; 
    %     day(d).winavg = squeeze(nanmean(winavg_agg,1));
    %     day(d).winstd = squeeze(nanstd(winavg_agg,1));
    %     winavg_diag_cat = reshape(winavg_diag(:,1:4),[],1);
    %     day(d).avg_tst_corct = nanmean(winavg_diag_cat);
    %     day(d).std_tst_corct = std(winavg_diag_cat);
        meta.bootMean_taste{g} = nanmean(bootstrp(100000, @nanmean, meta.bin_tasteposts{g}),1);
        meta.bootMean_taste{g} = reshape(meta.bootMean_taste{g}, [],4);
        meta.bootMean{g} = nanmean(bootstrp(100000, @nanmean, meta.bin_winposts{g}),1);
        %alpha = 0.05/n_an;
        alpha = 0.05;
        meta.bootCI{g} = bootci(1000000, {@nanmean, meta.bin_winposts{g}},'Alpha',alpha);
        meta.bootCI_taste{g} = squeeze(bootci(1000000,{@nanmean,meta.bin_tasteposts{g}}, 'Alpha', alpha));
    %     day(d).palAsUnpal_bootMean = mean(bootstrp(100000, @nanmean, day(d).bin_winposts_palAsUnpal));
    %     day(d).palAsUnpal_bootCI = bootci(1000000, @nanmean, day(d).bin_winposts_palAsUnpal);
    %     day(d).unpalAsPal_bootMean = mean(bootstrp(100000, @nanmean, day(d).bin_winposts_unpalAsPal));
    %     day(d).unpalAsPal_bootCI = bootci(1000000, @nanmean, day(d).bin_winposts_unpalAsPal);
    end
end
%metafn = [pwd filesep 'bayesMetaAnalysis.mat'];
metafn = [pwd filesep 'bayesMetaAnalysis.mat'];
save(metafn,'meta');
%%
% plot accuracy over time groups

f = figure();
f.Units = "inches";
f.Position = [1,1,10,6];
daylabels = ["Day 1" "Day 3"];
trlticks = ["1-6" "7-12" "13-18" "19-24" "25-30"];
days = [1 2];
colors = [0.4660 0.6740 0.1880; 0 0.4470 0.7410];
ndays = 2;
t = tiledlayout(1,ndays);
axes = zeros(1,ndays);
for i = 1:ndays
    clear title
    d = days(i);
    axes(i) = nexttile(t);
    trl_grps = length(day(d).bootMean);
    e = errorbar(1:trl_grps, day(d).bootMean, day(d).bootMean-day(d).bootCI(1,:), day(d).bootCI(2,:)-day(d).bootMean);
    title(daylabels(i))
    e.Marker = 'o';
    e.LineWidth = 2.0;
    e.Color = colors(i,:);
    ylim([0 1])
    xlim([0.25 5.75])
    xticks(1:5)
    xticklabels(trlticks)
    ax = gca;
    ax.FontSize = 14;
end
linkaxes(axes, 'xy')
yticklabels(axes(2),{})
ylab = ylabel(t,'mean p(correct taste)');
xlab = xlabel(t, "taste exposure trials");
t.TileSpacing = 'None';
ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'trlgrp_tasteID.svg'];
saveas(f, plotpath);

%% 


f = figure();
f.Units = "inches";
f.Position = [1,1,12,10];
daylabels = ["Day 1" "Day 2", "Day 3"];
condlabels = ["Naive" "Sucrose Preexposed"];
trlticks = ["1-5" "5-10" "11-15" "16-20" "21-25" "26-30"];
taste = ["Suc" "NaCl" "CA" "QHCl"];
days = [1 2 3];
colors = get(gca,'ColorOrder');
colors2 = colors .* 0.7;
colors = colors + (1 - colors).*0.2 ;
ndays = 3;
t = tiledlayout(4,2);
t.TileSpacing = 'None';
axes = zeros(4,2);
for j = 1:4
    for i = 1:1
        rows = meta(meta.day == i & meta.n_an > 0,:);
        d = days(i);
        for k = 1:height(rows)
            fullaverage = mean(rows.bootMean_taste{k});
            axes(j*k) = nexttile(t); 
            trl_grps = size(rows.bootMean_taste{k},1);
            avg = rows.bootMean_taste{k}(:,j);
            e = errorbar(1:trl_grps, avg, avg'-rows.bootCI_taste{k}(1,:,j), rows.bootCI_taste{k}(2,:,j)-avg');
            e.Marker = 'o';
            e.LineWidth = 2.0;
            e.Color = colors(j,:);
            e.Line
            h = yline(fullaverage(j));
            h.LineWidth = 2;
            if rows.cond(k) == "suc_preexp"
                e.Color = colors2(j,:);
                e.LineStyle = '--';
                e.Marker = "diamond";
            end  
        if j == 1
            title(condlabels(k))
        end 
        if j == 4
            xticklabels(trlticks)
        else
            xticklabels([])
        end 
        if k == 1
            ylabel(taste(j))
        else
            yticklabels([])
        end
        ylim([0 1])
        xlim([0.25 6.75])
        xticks(1:6)

        ax = gca;
        ax.FontSize = 14;
        end
    end
    %lgd.Layout.Tile = 4*j;
end
%linkaxes(axes, 'xy')
%(axes(2),{})
ylab = ylabel(t,'mean pr(correct taste)');
xlab = xlabel(t, "taste exposure trials");

ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'trltstgrp_tasteID_sucpreexp.png'];
saveas(f, plotpath);

%%
f = figure();
f.Units = "inches";
f.Position = [1,1,12,6];
daylabels = ["Day 1" "Day 2", "Day 3"];
condlabels = ["Naive" "Sucrose Preexposed"];
trlticks = ["1-5" "5-10" "11-15" "16-20" "21-25" "26-30"];
%taste = ["Suc" "NaCl" "CA" "QHCl"];
days = [1 2 3];
colors = get(gca,'ColorOrder');
colors2 = colors .* 0.7;
colors = colors + (1 - colors).*0.2 ;
ndays = 3;
nconds = 2;
t = tiledlayout(1,2);
axes = zeros(1,1);
for i = 1:1
    rows = meta(meta.day == i & meta.n_an > 0,:);
    d = days(i);
    
    
    for k = 1:height(rows)
        fullaverage = mean(rows.bootMean{k});
        axes(i) = nexttile(t); 
        trl_grps = size(rows.bootMean_taste{k},1);
        avg = rows.bootMean{k}(:);
        e = errorbar(1:trl_grps, avg, avg'-rows.bootCI{k}(1,:), rows.bootCI{k}(2,:)-avg');
        e.Marker = 'o';
        e.LineWidth = 3.0;
        e.Color = colors2(k,:);
        e.Line
        h = yline(fullaverage);
        if rows.cond(k) == "suc_preexp"
            e.Color = colors(k,:);
            e.LineStyle = '--';
            e.Marker = "diamond";
        end
        hold on
        ylim([0 1])
        xlim([0.25 6.75])
        xticks(1:6)
        h.LineWidth = 2;

        ax = gca;
        ax.FontSize = 14;
        title(condlabels(k))
        if j == 1
            
        end 
        %if j == 4
            xticklabels(trlticks)
        %else
            %xticklabels([])
        %end 
        if k ~= 1
            yticklabels([])
        end        
    end  


end
linkaxes(axes, 'xy')
ylab = ylabel(t,'mean pr(correct taste)');
xlab = xlabel(t, "trial number");
t.TileSpacing = 'None';
ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'trlgrp_tasteID_sucpreexp.png'];
saveas(f, plotpath);

%% plot with all tastes ACTUALLY WORKED 030722

f = figure();
f.Units = "inches";
f.Position = [1,1,12,12];
daylabels = ["Session 1", "Session 3"];
condlabels = ["Naive" "Sucrose Preexposed"];
conds = ["Naive","Suc_Preexp"];
trlticks = ["1-5" "5-10" "11-15" "16-20" "21-25" "26-30"];
taste = ["Suc" "NaCl" "CA" "QHCl"];
days = [1 3];
colors = get(gca,'ColorOrder');
colors2 = colors .* 0.7;
colors = colors + (1 - colors).*0.2 ;
ndays = 3;
t = tiledlayout(4,2);
t.TileSpacing = 'None';
axes = zeros(4,2);
for j = 1:4
    for z = [1 2] %z is day index
        axes(j*z) = nexttile(t); 
        for i = 1:2 % i is condition index
            rows = meta(meta.cond == conds(i) & meta.n_an > 0 & meta.day==days(z),:);
            fullaverage = mean(rows.bootMean_taste{k});

            trl_grps = size(rows.bootMean_taste{1},1);
            avg = rows.bootMean_taste{1}(:,j);
            e = errorbar(1:trl_grps, avg, avg'-rows.bootCI_taste{1}(1,:,j), rows.bootCI_taste{1}(2,:,j)-avg');
            hold on
            e.Marker = 'o';
            e.LineWidth = 2.0;
            e.Color = colors(j,:);
            e.Line
            h = yline(fullaverage(j));
            h.LineWidth = 2;
            if rows.cond == "Suc_Preexp"
                e.Color = colors2(j,:);
                e.LineStyle = '--';
                e.Marker = "diamond";
                h.LineStyle = '--';
            end  
        if j == 1
            title(daylabels(z))
        end 
        if j == 4
            xticklabels(trlticks)
        else
            xticklabels([])
        end 
        if z == 1
            ylabel(taste(j))
        else
            yticklabels([])
        end
        ylim([0 1])
        xlim([0.25 6.75])
        xticks(1:6)
        yticks([0 0.5 1])

        ax = gca;
        ax.FontSize = 14;
        end
    end
    leg = legend("Naive","Naive Mean", "Sucrose Preexposed","Sucrose Preexposed Mean",'Location','eastoutside');
end
%linkaxes(axes, 'xy')
%(axes(2),{})
ylab = ylabel(t,'mean pr(correct taste)');
xlab = xlabel(t, "taste exposure trials");

ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'tstsep_d1vd3vexp.png'];
saveas(f, plotpath);

%% plot 020722
f = figure();
f.Units = "inches";
f.Position = [1,1,12,12];
daylabels = ["Session 1" "Session 2", "Session 3"];
condlabels = ["Naive" "Sucrose Preexposed"];
conds = ["Naive","Suc_Preexp"];
trlticks = ["1-5" "5-10" "11-15" "16-20" "21-25" "26-30"];
%taste = ["Suc" "NaCl" "CA" "QHCl"];
days = [1 2 3];
colors = get(gca,'ColorOrder');
colors2 = colors .* 0.7;
colors = colors + (1 - colors).*0.2 ;
ndays = 3;
nconds = 2;
t = tiledlayout(2,2);
axes = zeros(2,2);
for j = [1,2]
    for i = [1,3]
        rows = meta(meta.day == i & meta.n_an > 0 & meta.cond == conds(j),:);
        d = days(i);
        axes(i,j) = nexttile(t); 

        for k = 1:height(rows)
            fullaverage = mean(rows.bootMean{k});
            trl_grps = size(rows.bootMean_taste{k},1);
            avg = rows.bootMean{k}(:);
            e = errorbar(1:trl_grps, avg, avg'-rows.bootCI{k}(1,:), rows.bootCI{k}(2,:)-avg');
            e.Marker = 'o';
            e.LineWidth = 3.0;
            e.Color = colors2(k,:);
            e.Line
            h = yline(fullaverage);
            if rows.cond(k) == "Suc_Preexp"
                e.Color = colors(k,:);
                e.LineStyle = '--';
                e.Marker = "diamond";
            end
            hold on
            ylim([0 1])
            xlim([0.25 6.75])
            xticks(1:6)
            h.LineWidth = 2;

            ax = gca;
            ax.FontSize = 14;
            if j == 1
                title(daylabels(i))
            end

            if j == 2
                xticklabels(trlticks)
            else
                xticklabels([])
            end 
            if i == 1
                ylabel(condlabels(j))
            else
                yticklabels([])
            end        
        end  


    end
end
linkaxes(axes, 'xy')
ylab = ylabel(t,'mean p(correct taste)');
xlab = xlabel(t, "trial number");
t.TileSpacing = 'None';
ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'd1vd3_naivevsuc_preexp.png'];
saveas(f, plotpath);

%% old plotting from spring pizza talk
f = figure();
f.Units = "inches";
f.Position = [1,1,10,6];
daylabels = ["Day 1" "Day 3"];
trlticks = ["1-6" "7-12" "13-18" "19-24" "25-30"];
days = [1 2];
colors = [0.4660 0.6740 0.1880; 0 0.4470 0.7410];
ndays = 3;
t = tiledlayout(1,ndays);
axes = zeros(1,ndays);
for i = 1:ndays
    clear title
    d = days(i);
    axes(i) = nexttile(t);
    trl_grps = length(meta.bootMean);
    mean = meta.bootMean{i};
    
    e = errorbar(1:trl_grps, mean, mean-meta.bootCI(1,:), day(d).bootCI(2,:)-day(d).bootMean);
    title(daylabels(i))
    e.Marker = 'o';
    e.LineWidth = 2.0;
    e.Color = colors(i,:);
    ylim([0 1])
    xlim([0.25 5.75])
    xticks(1:5)
    xticklabels(trlticks)
    ax = gca;
    ax.FontSize = 14;
end
linkaxes(axes, 'xy')
yticklabels(axes(2),{})
ylab = ylabel(t,'mean p(correct taste)');
xlab = xlabel(t, "taste exposure trials");
t.TileSpacing = 'None';
ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'trlgrp_tasteID.svg'];
saveas(f, plotpath);




%% plot unpalatable-as-palatable confusion
f = figure();
f.Units = "inches";
f.Position = [1,1,10,6];
daylabels = ["Day 1" "Day 3"];
trlticks = ["1-6" "7-12" "13-18" "19-24" "25-30"];
days = [1 3];
colors = [0.4660 0.6740 0.1880; 0 0.4470 0.7410];
ndays = 2;
t = tiledlayout(1,ndays);
axes = zeros(1,ndays);
for i = 1:ndays
    clear title
    d = days(i);
    axes(i) = nexttile(t);
    trl_grps = length(day(d).bootMean);
    e = errorbar(1:trl_grps, day(d).unpalAsPal_bootMean, day(d).unpalAsPal_bootMean-day(d).unpalAsPal_bootCI(1,:), day(d).unpalAsPal_bootCI(2,:)-day(d).unpalAsPal_bootMean);
    title(daylabels(i))
    e.Marker = 'o';
    e.LineWidth = 2.0;
    e.Color = colors(i,:);
    ylim([0 1])
    xlim([0.25 5.75])
    xticks(1:5)
    xticklabels(trlticks)
    ax = gca;
    ax.FontSize = 14;
end
linkaxes(axes, 'xy')
yticklabels(axes(2),{})
ylab = ylabel(t,'mean p(Suc & Na) CA & QHCl trials');
xlab = xlabel(t, "taste exposure trials");
t.TileSpacing = 'None';
ylab.FontSize = 16;
xlab.FontSize = 16;
xlab.FontWeight = 'bold';
plotpath = [pwd filesep 'unpalAsPal_trlgrp_tasteID.svg'];
saveas(f, plotpath);









