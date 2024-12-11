%By Daniel Svedberg, May 2020.
%%%Inputs: 

%%dat (data) 
% size: [neurons, trials, time-bins]. Order of trials should correspond to 
% trainind and decind

%%trainind (training index)
% size: [trials,#decoding-states for the trial]. Each trial should contain 
% an integer representing the true state corresponding to the trial. A 
% state of 0 means the trial will be excluded from the training data and
% trial-averaged decodes. The second dimension of trainind can contain a
% additional states pertaining to the trial (for example, if the first 
% 1000ms is state 1, and the last 2000ms is state 2, trainind(trial,:) =
% [1,2]

%%decind (decode index)
% size: [trials,#decoding-states for the trial]. Size needs to match trainind

%%windows (window index)
% size: [# states, 2] windows(:,1) = start index of the window,
% windows(:,2) = end index of the window. windows tells the script what
% indices from the trials to use as training data for each state. Each row of windows
% should correspond to the states in trainind/decind. If there are 5 states
% to decode, then windows should have 5 rows, where row 1 is the window for
% state 1, and row 5 of windows is the window for state 5. 

function [decode] = poissbayes(dat,trainind,decind,windows)
dat = round(dat);
[nrns,trls,bins] = size(dat);
sts = max(max(trainind));
decode.decind = decind;
decode.trainind = trainind;
decode.windows = windows;
decode.posterior = zeros(sts, trls,bins);
dsts = struct();
decode.winpost = zeros(sts,trls);


n_sts = sts;
prior = 1/n_sts;
priors = zeros(1, n_sts) + prior;

% %calculate priors:
% %first get each unique indices
% statelen = windows(:,2) - windows(:,1);
% statecount = histcounts(trainind);
% nbins = statelen' .* statecount;
% bintot = sum(nbins);
% priors = nbins/bintot;

% for i = 1:sts
%     strls = rates(trainind) == i;
% 
%     for nrn = 1:nrns
% 
%     end
% end

for trl = 1:trls %each loop is an iteration of the jacknife
    test = squeeze(dat(:,trl,:)); %test is the trial that is being decoded this loop
    pdfs = zeros(sts,bins); %pdfs will store the state probabilities for each bin
    winlikes = zeros(sts,1); %winpdfs will store the state probabilities for each window-of-interest--used as the "trial accuracy"
    trlSt = decind(:,trl); %get the state of this trial for the test
    testSt = windows(trlSt,1); %establish the start of the test window
    testEnd = windows(trlSt,2); %establish the end of the test window
    wintest = test(:,testSt:testEnd);

    iterind = trainind; %make a copy of the training index, leaving out the current trial from training
    iterind(:,trl) = 0;
    
    likes = zeros(sts,bins);
    for i = 1:sts
        stTrls = logical(sum(iterind == i, 1)); %gets the indices of trials in which the state of interest is present
        train = squeeze(dat(:,stTrls, :)); %pull the data for only trials where the state of interest is present
        winSt = windows(i,1); 
        winEnd = windows(i,2);

        samp = reshape(permute(squeeze(train(:,:,winSt:winEnd)),[1,3,2]),nrns,[]);
        nrns = size(samp,1);
        dsts(i).params = zeros(nrns,1);
        
        for nrn = 1:nrns
            [dsts(i).params(nrn,:),dsts(i).error(nrn,:,:)] = poissfit(samp(nrn,:), 0.025);
        end

        a = dsts(i).params(:,1).*ones(1,bins);
        like = log(poisspdf(test, a));
        likes(i,:) = sum(like,1);
        winlikes(i) = sum(sum(like(:,testSt:testEnd),2));
    end
    pdfs = likes + log(priors');
    winpdfs = winlikes + log(priors');
    %marglikes = sum(exp(likes));
    %decode.posterior(:,trl,:) = exp(likes - marglikes);

    for i = 1:length(dsts)
        svedberg = pdfs-pdfs(i,:);
        win_svedberg = winpdfs-winpdfs(i);
        decode.posterior(i,trl,:) = 1./(sum(exp(svedberg)));
        decode.winpost(i,trl) = 1./(sum(exp(win_svedberg)));
    end
end
winpreds = decode.winpost == max(decode.winpost);
preds = decode.posterior == max(decode.posterior);
decode.avgPosterior = zeros(sts,sts,bins);
decode.winAvg = zeros(sts,sts);
for st = 1:sts
    trls = logical(sum(trainind == st,1));
    ntrls = sum(trls);
    decode.avgPosterior(:,st,:) = nanmean(decode.posterior(:,trls,:),2);
    decode.predPcts = sum(preds(:,trls,:),2)./ntrls.*100;
    decode.winAvg(:,st) = nanmean(decode.winpost(:,trls),2);
    decode.winPcts(:,st) = sum(winpreds(:,trls,:),2)./ntrls.*100;
end

end



