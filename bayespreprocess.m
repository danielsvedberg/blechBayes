%file retrieval
[file,destFolder] = uigetfile('.mat','select data_file');
name = file(1:4);
raw = load([destFolder filesep file]);
cells = struct2cell(raw.spike_trains);
for i = 1:numel(cells)
    trlInd_beta{i}(1:size(cells{i},2)) = i;
    spikes_beta{i} = permute(squeeze(cells{i}),[2,1,3]);
end
spikes = cell2mat(spikes_beta);
tstindx = cell2mat(trlInd_beta);
clear raw cells trlInd_beta spikes_beta file

%data cleaning
%[bins,nrns,trls,tsts] = size(spikes);
%tstTrls = tsts*trls;
%spikes = reshape(spikes, bins,nrns,tstTrls); %[bins,nrns,taste-trials]
[nrns,tstTrls,bins] = size(spikes);
%spikes = permute(spikes, [3,2,1]); %[taste-trials,nrns,bins]
%tstindx = reshape((ones(4,30).*(1:4)')', tstTrls,1); %make index of taste-trials
spikes = permute(spikes, [2,1,3]); %[taste-trials,nrns,bins]
goodtrls = mean(sum(spikes,3),2) > 20; %find trials with spikes > 20
goodnrns = squeeze(mean(sum(spikes,3),1)) > 20; %find neurons with spikes > 20
spikes = spikes(goodtrls,goodnrns,:); %filter good spikes and good neurons
spikes = permute(spikes,[2,1,3]); %[neurons,taste-trials,bins]
dat = struct(); 
dat.spikes = spikes; 
dat.trlInd = tstindx(goodtrls); %tstindx tracks which trials in spikes correspond to which taste
dat.tasteID = ["NaCl", "Sucrose", "CA","QHCl"]; 

%BAKS firing rate [PloS one 13.11 (2018): e0206794.]
[nrns,trls,bins] = size(dat.spikes);
dat.rate = zeros(size(dat.spikes));
a=4;
for nrn = 1:nrns
    for trl = 1:trls
        spiketimes{nrn,trl} = find(squeeze(dat.spikes(nrn,trl,:)));
        b = length(spiketimes{1,1})^(4/5); 
        dat.rate(nrn,trl,:) = BAKS((spiketimes{nrn,trl}./1000), (0.001:0.001:7)', a, b)';
    end
end

%PCA of BAKS rate
prepcabaks = permute(dat.rate, [1,3,2]);
pcadat = reshape(prepcabaks,nrns, []);
[~,score,~,~,explained,~] = pca(pcadat');
pcaout = reshape(score',nrns,bins,trls);
pcaout = permute(pcaout, [1,3,2]);
dat.pca = pcaout(explained > 1,:,:);

mkdir([name '_bayes'])
cd ([name '_bayes'])
save(fullfile([destFolder],[name '_preprocess' '.mat']),'dat')

