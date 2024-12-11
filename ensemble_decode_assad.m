function decode = ensemble_decode_assad(eu)
    n_rec_un = length(eu);
    press_rates = [];
    lick_rates = [];
    spont_rates = [];
    cue_rates = [];
    for i = 1:n_rec_un %cleanest separation of movement would be incorrect reach trials vs incorrect lick trials
        %cor_press_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='press', ...
        %    allowedTrialDuration=[4,Inf]); %note: correct trials have [4,Inf], try to decode on correct trials in future
        %incor_press_rates(i,:,:)= getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='press', ...
        %    allowedTrialDuration=[2,4]);
        press_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='press', ...
            allowedTrialDuration=[2,Inf]);
        lick_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='lick', ...
            allowedTrialDuration=[2,Inf]);
        %incor_lick_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='lick', ...
        %    allowedTrialDuration=[2,4]);
        %cue_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='press', ...
        %    allowedTrialDuration=[2,Inf], alignTo='start'); %start is the cue, stop is the actual press    
        %consider making spont -2--4 seconds before correct presses
        spont_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-6,2], trialType='press', ...
            allowedTrialDuration=[2,Inf], alignTo='start'); %NOTE: CHECK IF LIGHT IS CUE
    
        %cue is the lever deploying, takes 800ms, so start of lever servo is
        %800ms before the marker
    end
    
    rates = cat(2, press_rates, lick_rates, spont_rates);
    presstrls = size(press_rates, 2);
    licktrls = size(lick_rates, 2);
    %cuetrls = size(cue_rates,2);
    sponttrls = size(spont_rates, 2);
    pressidx = zeros(1, presstrls) + 1;
    lickidx = zeros(1, licktrls) + 2;
    %cueidx = zeros(1,cuetrls) + 3;
    spontidx = zeros(1, sponttrls) + 3;
    idx = cat(2, pressidx, lickidx, spontidx);
    
    windows = zeros(4,2);
    windows(1,1) = 3501; %press start
    windows(1,2) = 4500; %press end
    windows(2,1) = 3501; %lick start
    windows(2,2) = 4500; %lick end
    %windows(3,1) = 3301; %cue start
    %windows(3,2) = 4300; %cue end
    windows(3,1) = 1; %spont start
    windows(3,2) = 4000; %spont end
    decode = poissbayes(rates, idx, idx, windows);
end