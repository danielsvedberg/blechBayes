%data retrieval


bsln = 500:1500;
span = 750; 
start = 2001;
finish = 3750;
%decode = optimizebayessampleGPU(dat.rate,dat.trlInd,bsln,start,finish,span);
sample = 2500:3500;
decode = bayesjackknifeGPU(gpuArray(dat.pca),gpuArray(dat.trlInd),gpuArray(sample),gpuArray(bsln));
decode.tastants = ["NaCl (Salty)", "Sucrose (Sweet)", "Citric Acid (Sour)","Quinine (Bitter)","Baseline"];

mkdir([name '_bayes'])
save(fullfile([destFolder],[name '_bayes'],[name '_decode_' num2str(decode.sample(1)) '-' num2str(decode.sample(end)) 'ms.mat']),'decode')
cd ([name '_bayes'])
