# blechBayes
 bayesian decoding for katz lab

The core functions are bayesjackknife.m/bayesjackknifeGPU.m, where the GPU version is to be run on computers with a GPU for ~10x speed. 

The bayesjackknife functions will take in a 1) data matrix, 2) trial index, 3) an index of the "region of interest", and 4) an index of the baseline period. The bayesjackknife functions output a data structure, which contains the probability that every trial belongs to each of the categories supplied in the trial index and the baseline. These probabilities are calucluated using the jackknife algorithm, where the conditional likelihood functions for each state are trained on every trial except for one, and then the left-out trial is decoded, and a different trial is left out on each iteration until all the trials have been decoded. 

 1) Data matrix (dat)
Data matrix should be continuously distributed data that will be fit to a normal distribution (i.e. neural firing rates, LFP power, or PCAs of data), of dimensions channels x trials x timebins. Channels are treated as independent variables (i.e. individual neurons, or LFP power-bands). Theoretically, channels of different kinds can be combined (i.e. you can have 10 channels with neural firing rates, and 10 channels of LFP power-bands for an input matrix of 20 channels), and the algorithm will find useful information for inference from all of the data. All your trials (of different kinds) will be contained in a single dimension, and will be tracked by the trial index. 

2) Trial index (ind)
The trial index should be array that categorizes each trial. (i.e if you have 6 total trials consisting of successive sucrose, salt, quinine deliveries, then your trial index should be [1,2,3,1,2,3])

3) Region of interest or "sample" (sample)
The sample should be an array indexing every time bin of interest to be included in the training data. So if each trial's data is an array that spans 0:7000, representing -1999ms before and 5000ms after stimulus delivery, and you want to train only on data from 0-1000ms after stimulus delivery, then your "sample" should be an array defined as 2001:4000.

4) Inter-trial-interval sample or "Baseline" (bsln)
The baseline sample should be an array indexing every time bin representing "baseline" data or otherwise "inter-trial-interval" data to train a "baseline" state in the model. Currently, the function is not set up to handle baseline data as separate trials, but I am looking to add this in the future. 

Output:
1) decode.posterior: moment by moment posterior probability that each trial is decoded as each of the indexed state, with dimensions decoded state x trials x timebins
2)decode.avg: moment-by-moment posterior probability that trials belonging to a state are decoded as each of the indexed states + baseline, with dimensions decoded state x actual state x timebins
3) decode.percent: percent of trials decoded in the state, with dimensions decoded state x actual state x timebins 
4) decode.CI95: 95% confidence intervals of the average decode, where the last two dimensions are upper bound and lower bound. 
