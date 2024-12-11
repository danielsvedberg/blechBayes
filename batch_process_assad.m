%% 1.2Alt Or just load lite version, without non-SNr cells, without waveforms, spikecounts or spikerates.
eu = EphysUnit.load('\\research.files.med.harvard.edu\neurobio\Assad Lab\Lingfeng\Data\Units\Lite_NonDuplicate_NonDrift');


%% Load euComplete (complete with ITI spikes)
euNames = lower(eu.getName());

files = dir('\\research.files.med.harvard.edu\neurobio\Assad Lab\Lingfeng\Data\Units\NonLite_PressVsLick\*.mat');
sel = ismember(cellfun(@(n) lower(strrep(n, '.mat', '')), {files.name}, UniformOutput=false), euNames);
files = files(sel);
cd('\\research.files.med.harvard.edu\neurobio\Assad Lab\Lingfeng\Data\Units\NonLite_PressVsLick\')
euComplete = EphysUnit.load({files.name});

% euComplete.save('C:\SERVER\Units\NonLite_PressVsLick_NonDuplicate_NonDrift');

[lia, locb] = ismember(eu.getName(), euComplete.getName());
eu(lia) = euComplete(locb(lia));

clear euComplete

%% Load metadata
load('\\research.files.med.harvard.edu\neurobio\Assad Lab\Lingfeng\Data\Units\meta_Lite_NonDuplicate_NonDrift.mat')
% save('C:\SERVER\Units\meta_Lite_NonDuplicate_NonDrift.mat')
eu = eu(c.hasPress & c.hasLick);

exp_names = {};
for i = 1:length(eu)
    exp_names{i} = eu(i).ExpName;
end
unique_exp_names = unique(exp_names);
n_exp = length(unique_exp_names);
exp_names = string(exp_names);

decodes = cell(n_exp,1);
shuff_decodes = cell(n_exp,1);
n_neurons = cell(n_exp,1);
for i = 1:n_exp
    exp_name = unique_exp_names{i};
    exp_idx = exp_names == exp_name;
    eu_ens = eu(exp_idx);
    n_nrn = length(eu_ens);
    if n_nrn >= 5
        decodes{i} = ensemble_decode_assad(eu_ens);
        shuff_decodes{i} = ensemble_decode_assad_shuffle(eu_ens,10);
        n_neurons{i} = n_nrn;
    end
end

avgPosterior = zeros(18,3,3,8000);
ciPosterior = zeros(3,3,2,8000);
for i = 1:18
    avgPosterior(i, :, :, :) = decodes{i}.avgPosterior; 
end
for i = 1:3
    for j = 1:3
        ciPosterior(i,j,:,:) = bootci(1000,@mean, squeeze(avgPosterior(:,i,j,:)));
    end
end
avgPosterior = squeeze(mean(avgPosterior,1));




%% plotting

dns = {'press', 'lick', 'spontaneous'};
corpresstime = -3.999:0.001:4;
licktime = corpresstime;
cuetime = corpresstime;
sponttime = -5.999:0.001:2.000;
timeaxs = cat(1, corpresstime, licktime,sponttime);
xaxlabs = {'time to lever press', 'time to lick', 'time to lever deployment'}
windows = decodes{1}.windows;
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

f = figure();
t = tiledlayout(1,2,"TileSpacing","compact","Padding","compact");
axs = {};
for i = 1:2
    axs{i} = nexttile;
    hold on
    for j = 1:3
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
        plot(time, squeeze(avgPosterior(j,i,:))', DisplayName=dns{j}, linewidth = 2)
    end
    title(strcat(dns(i), " trials"))
    xlabel(xaxlabs{i})
    if i == 1
        ylabel('p(state)')
    else
        yticklabels([])
        yticks(0:0.2:1)
    end
    % if i == 1
    %     legend()
    % end
end
linkaxes([axs{1}, axs{2}])
set(gcf, 'Position',[0, 0, 400,200])
saveas(f, "average_decode.png")
saveas(f, "average_decode.svg")


