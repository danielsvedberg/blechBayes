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

function [decode] = gammabayes2(dat,trainind,decind,windows)
dat = (round(dat,3)+0.001);
[nrns,trls,bins] = size(dat);
sts = max(max(trainind));
decode.decind = decind;
decode.trainind = trainind;
decode.windows = windows;
decode.posterior = zeros(sts, trls,bins);
dsts = struct();
n_wins = size(decind,1);
decode.winpost = zeros(sts,trls,n_wins);

for trl = 1:trls %each loop is an iteration of the jacknife
    test = squeeze(dat(:,trl,:)); %test is the trial that is being decoded this loop
    pdfs = zeros(sts,bins); %pdfs will store the state probabilities for each bin
    winpdfs = zeros(sts,n_wins); %winpdfs will store the state probabilities for each window-of-interest--used as the "trial accuracy"
    trlSt = decind(:,trl); %get the state of this trial for the test
    testSt = windows(trlSt,1); %establish the start of the test window
    testEnd = windows(trlSt,2); %establish the end of the test window
    
    iterind = trainind; %make a copy of the training index, leaving out the current trial from training
    iterind(:,trl) = 0;
    
    for i = 1:sts
        stTrls = logical(sum(iterind == i, 1)); %gets the indices of trials in which the state of interest is present
        train = squeeze(dat(:,stTrls, :)); %pull the data for only trials where the state of interest is present
        winSt = windows(i,1); 
        winEnd = windows(i,2);

        samp = reshape(permute(squeeze(train(:,:,winSt:winEnd)),[1,3,2]),nrns,[]);
        nrns = size(samp,1);
        dsts(i).params = zeros(nrns,2);
        
        for nrn = 1:nrns
            [dsts(i).params(nrn,:),dsts(i).error(nrn,:,:)] = gamfit(samp(nrn,:), 0.025);
            for j = 1:n_wins
                dsts(i).winpdf(nrn,j) = sum(gamlike(dsts(i).params(nrn,:),test(nrn,testSt(j):testEnd(j))));
            end
        end
        a = dsts(i).params(:,1).*ones(1,bins);
        b = dsts(i).params(:,2).*ones(1,bins);
        pdfs(i,:) = sum(log(gampdf(test,a,b)),1);
        winpdfs(i,:) = sum(dsts(i).winpdf,1)*-1;
    end

    for i = 1:length(dsts)
        svedberg = pdfs-pdfs(i,:);
        win_svedberg = winpdfs-winpdfs(i,:);
        decode.posterior(i,trl,:) = 1./(sum(exp(svedberg)));
        decode.winpost(i,trl,:) = 1./(sum(exp(win_svedberg)));
    end
end

decode.avgPosterior = zeros(sts,sts,bins);
decode.winAvg = zeros(sts,sts,n_wins);
decode.perClass = zeros(sts,sts,n_wins);
winClass = decode.winpost == max(decode.winpost);
for st = 1:sts
    trls = logical(sum(trainind == st,1));
    n_trls = sum(trls);
    decode.avgPosterior(:,st,:) = nanmean(decode.posterior(:,trls,:),2);
    decode.winAvg(:,st,:) = nanmean(decode.winpost(:,trls,:),2);
    n_class = sum(winClass(:,trls,:),2);
    decode.perClass(:,st,:) = n_class./n_trls;
end

end



