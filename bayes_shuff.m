%% shuffle control

peristim_mat = load('BS26_4Tastes_180204_102132_Peristim_all_tastes.mat');
ps_init = fieldnames(peristim_mat.all_tastes); 
ps_array = peristim_mat.all_tastes.(ps_init{1}); 
clear ps_init
ps_array = permute(ps_array, [4,3,2,1]);
ps_array = reshape(ps_array, 7000,30,120);
ps_array = permute(ps_array, [3,2,1]);
tstindx = reshape((ones(4,30).*(1:4)')', 120,1);
goodtrls = mean(sum(ps_array,3),2) > 20;
ps_array = ps_array(goodtrls,:,:);
tstindx = tstindx(goodtrls); %tstindx tracks which trials in ps_array correspond to which taste
ps_array = permute(ps_array,[2,1,3]);
goodnrns = squeeze(mean(sum(ps_array,3),2)) > 20;
ps_array = ps_array(goodnrns,:,:); %ps_array finishes as (nrns,tst-trls,timebins)

iterpost = zeros(10,56,7000,5);
iterwin = zeros(10,56,5);
for i = 1:10
    shuffind = zeros(size(ps_array));
    for nrn = 1:21
        for trl = 1:113
            shuffind(nrn,trl,:) = randperm(7000);
        end
    end
    ps_shuff = ps_array(shuffind);
    baksshuff = zeros(size(ps_shuff));
    a=4;
    for nrn = 1:21
        for trl = 1:113
            shufftimes{nrn,trl} = find(squeeze(ps_shuff(nrn,trl,:)));
            b = length(shufftimes{1,1})^(4/5); 
            baksshuff(nrn,trl,:) = BAKS((shufftimes{nrn,trl}./1000), (0.001:0.001:7)', a, b)';
        end
    end

    nrns = size(baksshuff,1);
    trls = size(baksshuff,2);
    bins = size(baksshuff,3);

    prepcashuff = permute(baksshuff, [1,3,2]);
    pcashuff = reshape(prepcashuff,nrns, []);
    [coeff,score,latent,tsquared,explained,mu] = pca(pcashuff');
    pcashuff = reshape(score',nrns,bins,trls);
    shuffdat = permute(pcashuff, [1,3,2]);
    trlshuff(i,:) = randperm(trls);
    shuffdat = shuffdat(1:16,trlshuff(i,:),:);
    trainShuff = shuffdat(:,1:2:end,:);
    tstInd = tstindx(randperm(length(tstindx)),1);
    trainInd = tstInd(1:2:end);
    testShuff = shuffdat(:,2:2:end,:); 
    testInd = tstindx(2:2:end); 

    bslnst = 1;
    bslnend = 2000;

    sampst = 2500;
    sampend = 3500;

    [instpost,winpost] = rt_bayes(trainShuff,testShuff, bslnst, bslnend, sampst, sampend, trainInd);
    iterpost(i,:,:,:) = instpost;
    iterwin(i,:,:) = winpost;
end

shuffind = tstindx(trlshuff);
win = permute(iterwin, [3 2 1]);
corrtrials = squeeze(sum((win == max(win)) .* (1:5)', 1)) == shuffind(:,2:2:end)';

for i = 1:4
    percorr(i,:) = sum(corrtrials.*(shuffind(:,2:2:end) == i)')/sum(shuffind(:,2:2:end) == i,2)';
end

for i = 1:4
    tstpost = iterpost(:,testInd == i,:,:);
    avgpost(:,i,:,:) = mean(tstpost,2); 
end

avgavgpost = squeeze(mean(avgpost,1));

%% avg plot
colormap = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560];

tastants = ["NaCl (Salty)", "Sucrose (Sweet)", "Citric Acid (Sour)","Quinine (Bitter)","Baseline"];
psvec = -999:1:3000;
len = (sampst:sampend)-2000;
lenny = length(len); 

figure()
for i = 1:4
    subplot(4,1, i)
    pltArr = squeeze(avgavgpost(i,1001:5000,:));
    clear gca
    plot(psvec,pltArr, 'LineWidth', 2)
    ylim([0 1])
    hold on
    line(len, ones(lenny,1)*percorr(i),'Color', colormap(i,:),'LineWidth', 2, 'LineStyle','--');
    hold off
    set(gca,'FontSize',12)
    ttl = title([tastants{i} ' delivered (shuffle)'])
    if i == 1
        ylab = ylabel({'avg posterior';'probability'})
        xlab = xlabel("time from taste delivery (ms)")
    end
    
end
lgnd = legend({"NaCl", "Suc", "CA", "QHCl","None"},'Orientation','horizontal')  
lgnd.Title.String = "Decoded Taste"
ttl.FontSize = 12;
ylab.FontSize = 12;
xlab.FontSize = 12;

%%
figure(1)
for i = 1:4
    subplot(4,1,i)
    b = bar(percorr(i)*100);
    set(gca,'FontSize',12)
    ylim([0 100])
    if i == 1
    ylabel({'% trials correctly';'classified (shuffle)'})
    end
    xticklabels(tastants{i})
    b.FaceColor = 'flat';
    b.CData = colormap(i,:);
end

