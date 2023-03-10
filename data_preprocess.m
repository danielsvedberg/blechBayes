function [data] = data_preprocess(data)

tsts = size(data.spikes,2);
data.trlindx = {};
data.catspikes={};
data.trlno = {};
for tst = 1:tsts
    trls = size(data.spikes{tst},1);
    data.catspikes{tst} = permute(data.spikes{tst},[2,1,3]);
    data.trlno{tst} = 1:trls;
    data.trlindx{tst} = zeros(1,trls)+tst;
end

data.catspikes = cell2mat(data.catspikes);
data.trlindx = cell2mat(data.trlindx);
data.trlno = cell2mat(data.trlno);

%BAKS firing rate [PloS one 13.11 (2018): e0206794.]
[nrns,trls,bins] = size(data.catspikes);
data.rate = zeros(size(data.catspikes));
a=4;
time = (0.001:0.001:7);
for nrn = 1:nrns
    for trl = 1:trls
        spiketimes = find(squeeze(data.catspikes(nrn,trl,:)))./1000;
        b = length(spiketimes)^(4/5); 
        data.rawrate(nrn,trl,:) = round(BAKS(spiketimes, time', a, b)',3);
    end
end

%data cleaning
data.goodtrls = sum(sum(data.catspikes,3) == 0 ,1) < 5; %find trials with fewer than 5 dead neurons
data.trainindx = data.trlindx;
data.trainindx(:,~data.goodtrls) = 0;
data.latetrials = data.trainindx;
data.latetrials(:,1:10) = 0;
data.earlytrials = data.trainindx;
data.earlytrials(:,11:30) = 0;
cleantrls = data.catspikes(:,data.goodtrls,:); 
data.goodnrns = mean(sum(cleantrls,3) ,2) > 10 ; %find neurons with fewer than 5 dead trials
data.rate = data.rawrate(data.goodnrns,:,:);

% data.clean.ind = data.trlindx(data.goodtrls);
% data.clean.trlno = data.trlno(data.goodtrls);
% data.clean.spikes = data.catspikes(data.goodnrns,data.goodtrls,:); %filter good spikes and good neurons
% data.clean.rate = data.rate(data.goodnrns,data.goodtrls,:);

end