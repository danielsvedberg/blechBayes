%demo of gamma bayes workflow:

%import_taste_data: you probably want to skip running this step unless you
%are using my python code, this is more for your understanding of the demo.
%this function takes in the mat file + some id variables, outputs smoothed
%data reshaped for use in the decoder + adds id fields to the struct. This
%data comes out as dat.rate, which has the dimensions of neurons x trials x
%timebins. dat.trlindx is a vector that is n-trials long, each entry is the
%state/taste id corresponding to the trial in dat.rate, represented as an
%integer. I have 5 states (4 tastes + baseline) so this is going to be 1:5 
%for me, its up to you to decide how to numerically code your states
dat = import_taste_data("/home/dsvedberg/Documents/MATLAB/DS39/201029/DS39_spont_taste_201029_154308.mat", 1, "naive");

%what is below here is likely more relevant to you: 
%since we are decoding, but not training on spontaneous trials, we want to
%make a new trial index where each spontaneous trial is marked to not be
%used as training data. We do this by assigning it state 0. We then want to
%use the pre-stim activity as the baseline state, so we add a second row to
%the trial index, indicating that every taste-trial has a secondary purpose
%as a baseline trial. Lastly, the windows variable will know from where in
%the trial to draw the training data for each state, based on it's index.

new_trlidx = dat.trlindx; %copy the old trial index--this was just an n-trials
%long vector with an integer (1-5) representing the state/state that trial contained

bslnidxs = new_trlidx == 5; %get indices where spont trials live

new_trlidx(2,:) = 5; %add a row to the trial index; every trial now is marked to also have 
%baseline data pulled from it (the windows variable tells the decoder where
%these indices are)

new_trlidx(:,bslnidxs) = 0; %for indices where spont trials live, make them 0 so they 
%don't get pulled into training data
%now, every trial is marked with 2 numbers, in the first row, is an integer 1-4: which taste,
%and in the 2nd row, each taste-trial gets a 5 for baseline. Since the last 90
%trials are spontaneous activity, we assign them 0s for both rows. 

trainind = new_trlidx; %just to use common variable names
%one last note on trainind--you can theoretically have as many states as
%you want in each trial. Want baseline, ID, and palatability? you can have
%3 rows in trainind, and you just assign where in the trial you want to
%sample your data from using windows


decind = dat.trlindx; %pull the old trial index, this is used to compare 

%windows tells the decoder where to look in the data to get a certain state
%the row number (first dimension) corresponds to the state number--i.e. window
%for state 1 is in row 1 of windows
%the first column of windows is the start index of the window
%the second column of windows is the end index off the window
%remember, trainind tells the decoder which trials to look at
%and then windows tells the decoder where in those trials to look.
windows = zeros(5,2); %since we are looking for 5 states, then we need 5 windows
windows(1:4,1) = 2251; %states 1-4 are taste, I assume the taste response is happening at the same time in this demo, but you
windows(1:4,2) = 3000; %have the option to go crazy and use different windows for each state. Here I don't demo iterating over different windows, but it's something you should do
windows(5,1) = 1; %lastly, since state 5 is baseline, that will be the first 2000ms of each taste-trial
windows(5,2) = 2000;
%the main limitation I will point out is that with this system, each specific state
%is assumed to happen at the same point in each trial. It cannot move
%around trial to trial. You can move around when states happen across
%different states, but each individual state is assumed to happen at the same time in
%each trial


test = gammabayes2(dat.rate, new_trlidx, decind, windows);
%the most important thing is that dat.rate needs to have dimensions
%[neurons,trials,bins]
