%Created by Daniel Svedberg July 2019. Detailed information/instructions
%below function definition.
function [decode] = bayesjackknifeGPU(dat,ind,sample,bsln)
[nrns,trls,bins] = size(dat);
tsts = max(ind);
decode = struct();
decode.tasteInd = ind;
decode.sample = sample;
decode.bsln = bsln;
decode.posterior = gpuArray(zeros(tsts+1, trls,bins));
normal = @(x,m,s) (1./(sqrt(2*pi.*s.^2)).*exp((-(x-m).^2)./(2.*s.^2)));
for trl = 1:trls %each loop is an iteration of the jacknife
    test = squeeze(dat(:,trl,:));
    train = dat; train(:,trl,:) = [];
    trainTsts = ind; trainTsts(trl) = []; 
    dsts = struct();
    ml = gpuArray(zeros(tsts+1,bins));
    for i = 1:tsts
        dsts(i).dat = reshape(permute(train(:,trainTsts == i,sample),[1,3,2]),nrns,[]);
        dsts(i).mu = mean(dsts(i).dat,2);
        dsts(i).sigma = std(dsts(i).dat,0,2);
        dsts(i).pdf = sum(log(normal(test, dsts(i).mu, dsts(i).sigma)),1);
        ml(i,:) = dsts(i).pdf;
    end
    dsts(i+1).dat = reshape(permute(train(:,:,bsln),[1,3,2]),nrns,[]);
    dsts(i+1).mu = mean(dsts(i+1).dat,2);
    dsts(i+1).sigma = std(dsts(i+1).dat,0,2);
    dsts(i+1).pdf = sum(log(normal(test, dsts(i+1).mu, dsts(i+1).sigma)),1);
    ml(i+1,:) = dsts(i+1).pdf;
    ml = log(sum(exp(ml),1));
    windec = gpuArray(zeros(5,1));
    for i = 1:length(dsts)
        decode.posterior(i,trl,:) = exp(dsts(i).pdf-ml)';
        windec(i) = sum(exp(dsts(i).pdf(sample)-ml(sample)));
    end
    winnorm = sum(windec); 
    decode.winpost(:,trl) = windec./winnorm;
end
 
for i = 1:max(decode.tasteInd)
    trls = size(decode.winpost(:,decode.tasteInd == i),2);
    decode.avg(:,i,:) = mean(decode.posterior(:,decode.tasteInd == i,:),2);
    decode.percent(:,i,:) = sum(decode.posterior(:,decode.tasteInd == i,:) == max(decode.posterior(:,decode.tasteInd == i,:)),2)./trls;
    decode.winavg(:,i) = mean(decode.winpost(:,decode.tasteInd == i), 2);
    decode.winpercent(:,i) = sum(decode.winpost(:,decode.tasteInd == i) == max(decode.winpost(:,decode.tasteInd == i)),2)./trls;
    PI95 = tinv([0.025 0.975], trls-1);
    winsem = std(decode.winpost(:,decode.tasteInd == i),0,2)/sqrt(trls);
    decode.winCI95(:,:,i) = winsem*PI95;%+decode.winavg(:,i);
    sem = std(decode.posterior(:,decode.tasteInd == i,:),0,2)/sqrt(trls);
    decode.CI95(:,i,:,:) = sem.*reshape(PI95,[1,1,1,2])+decode.avg(:,i,:);
end 
end
%General:
%bayesjacknifeGPU is a GPUarray-optimized version of bayesjackknife
%that takes time averaged neural data and trial categories and
%performs bayesian decoding of assigned states. This is done using the
%"jackknife" method, where the function loops through every trial and sets 
%it apart for decoding, where the decoder is trained on the remaining trials. 
%Inputs [all must be in the form of GPUArray:
%   dat: data for decoding, formatted as neurons*trials*timebins
%       can be any time-averaged data, i.e. smoothed firing rate or PCA of 
%       smoothed firing rate. Trials can be in any order as long as you 
%       have an index for them, stored in ind      
%   ind: vector indexing trial IDs; i.e. if dat(:,1:10,:) are NaCl trials, 
%       ind(1:10) should = 1; if dat(:,11:20,:) = Suc trials then ind(11:20) = 2
%   sample: vector of timebins in each trial of dat corresponding to the 
%       decoding window (i.e. 2500:3500 ms)
%   bsln: vector of the timebins in each trial of dat corresponding to the
%       ITI assigned as baseline (i.e 1:2000 ms). 
%Output:
%   decode: bayesjackknife outputs a struct titled decode
%   decode.tasteInd: the same index as input "ind"
%   decode.posterior: instantaneous decodes, as a probability of 0 to 1 
%       where the first dimension is the state that was decoded for the
%       data, and the dimension number corresponds to the index number.
%       The last dimension corresponds to baseline decoding
%   decode.winpost: organized similarly as decode.posterior, but the
%       likelihood of decoding the entire window is calculated as one
%       number
%   decode.avg: trial-average of decode.postrior for each decoding state
%   decode.winavg: trial-average of decode.winpost for each decoding state


