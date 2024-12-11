function decode = ensemble_decode_assad_shuffle(eu, niter)
    decode = {niter, 1};
    for j = 1:niter
        n_rec_un = length(eu);
        press_rates = [];
        lick_rates = [];
        spont_rates = [];
        for i = 1:n_rec_un %cleanest separation of movement would be incorrect reach trials vs incorrect lick trials
            press_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='press', ...
                allowedTrialDuration=[2,Inf]);
            lick_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-4,4], trialType='lick', ...
                allowedTrialDuration=[2,Inf]);
            spont_rates(i,:,:) = getTrialAlignedData(eu(i), 'rate', [-6,2], trialType='press', ...
                allowedTrialDuration=[2,Inf], alignTo='start'); %NOTE: CHECK IF LIGHT IS CUE
        end
        
        rates = cat(2, press_rates, lick_rates, spont_rates);
        shuffidx = randperm(size(rates,2));
        rates = rates(:,shuffidx,:);
        presstrls = size(press_rates, 2);
        licktrls = size(lick_rates, 2);
        %cuetrls = size(cue_rates,2);
        sponttrls = size(spont_rates, 2);
        pressidx = zeros(1, presstrls) + 1;
        lickidx = zeros(1, licktrls) + 2;
        %cueidx = zeros(1,cuetrls) + 3;
        spontidx = zeros(1, sponttrls) + 3;
        idx = cat(2, pressidx, lickidx, spontidx);
        
        windows = zeros(3,2);
        windows(1,1) = 3501; %press start
        windows(1,2) = 4500; %press end
        windows(2,1) = 3501; %lick start
        windows(2,2) = 4500; %lick end
        windows(3,1) = 1; %spont start
        windows(3,2) = 4000; %spont end
        dec = poissbayes(rates, idx, idx, windows);
        decs.winAvg = dec.winAvg;
        decs.avgPosterior = dec.avgPosterior;
        decs.predPcts = dec.predPcts;
        decs.winPcts = dec.winPcts;
        decode{j} = decs;
    end
end