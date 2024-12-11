%batchprocess is my workflow for concurrently databasing and analyzing many
%files/recordings
%file with recordings is at \\research.files.med.harvard.edu\neurobio\Assad Lab\Lingfeng\Data\Units
%ephysunit objects have ExperimentName field
%eu = EphysUnit.load('desmond23_20220504_with_ITI');

run('Users\Dan\Documents\MATLAB\blechBayes\read_reachDir_2tgt_singleTrial.m');

%% run bayes decoding on all the data
n_exp = length(traj2tgt);
decodes = {};
for i = 1:n_exp
    exp = traj2tgt(i);
    decodes{i} = ensemble_decode_assad_lat_vs_med(exp);
end
n_decodes = length(decodes);
avgPosterior = zeros(n_decodes,3,3,8000);
ciPosterior = zeros(3,3,2,8000);
for i = 1:n_decodes
    avgPosterior(i, :, :, :) = decodes{i}.avgPosterior; 
end
for i = 1:3
    for j = 1:3
        ciPosterior(i,j,:,:) = bootci(1000,@mean, squeeze(avgPosterior(:,i,j,:)));
    end
end
avgPosterior = squeeze(mean(avgPosterior,1));

%% plotting

dns = {'press medial', 'press lateral', 'spontaneous'};
medpresstime = -3.999:0.001:4;
latpresstime = medpresstime;
sponttime = -5.999:0.001:2.000;
timeaxs = cat(1, medpresstime, latpresstime,sponttime);
xaxlabs = {'time to lever press', 'time to lever press', 'time to lever press'};
windows = decodes{1}.windows;
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
axs = {};
f = figure();
t = tiledlayout(1,2,"TileSpacing","compact","Padding","compact");
for i = 1:2
    axs{i} = nexttile;
    hold on
    for j = 1:2
        startidx = windows(i,1);
        endidx = windows(i,2);
        windowtime = timeaxs(i,startidx:endidx);
        if j == i
            winpost = squeeze(avgPosterior(j,i,startidx:endidx));
            zeroarr = ones(size(winpost));
            fill([windowtime, fliplr(windowtime)], [winpost', zeroarr'], ...
                "black", FaceAlpha=0.1, DisplayName='training window')
        end
        time = squeeze(timeaxs(i,:))';
        fill([time', fliplr(time')], [squeeze(ciPosterior(j,i,1,:))', fliplr(squeeze(ciPosterior(j,i,2,:))')], ...
            colors(j,:), FaceAlpha=0.2, LineStyle='None')
        plot(time, squeeze(avgPosterior(j,i,:))', DisplayName=dns{j}, linewidth = 2, color=colors(j,:))
    end
    title(strcat(dns(i), " trials"))
    xlabel(xaxlabs{i})
    if i == 1
        ylabel('p(state)')
    else
        yticklabels([])
        yticks(0:0.2:1)
    end
end
set(gcf, 'Position',[0, 0, 400,200])
saveas(t, "average_decode_med_vs_lat.png")
saveas(t, "average_decode_med_vs_lat.svg")
save('decodes_med_vs_lat.mat', 'decodes')