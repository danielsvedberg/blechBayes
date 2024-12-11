function decode = ensemble_decode_assad_left_vs_right(exp)
    press_med = exp.sr(2).X; %1 is lateral 2 is medial
    press_lat = exp.sr(1).X;
    spont_med = exp.spontRate(2).X;
    spont_lat = exp.spontRate(1).X;

    spont = cat(2, spont_med, spont_lat);
    rates = cat(2, press_med, press_lat, spont);

    nPressMed = size(press_med, 2);
    nPressLat = size(press_lat, 2);
    nSpont = size(spont, 2);

    pressMedIdx = zeros(1, nPressMed) + 1;
    pressLatIdx = zeros(1, nPressLat) + 2;
    spontidx = zeros(1, nSpont) + 3;
    idx = cat(2, pressMedIdx, pressLatIdx, spontidx);
    
    windows = zeros(4,2);
    windows(1,1) = 3501; %med start
    windows(1,2) = 4500; %med end
    windows(2,1) = 3501; %lat start
    windows(2,2) = 4500; %lat end
    windows(3,1) = 1; %spont start
    windows(3,2) = 4000; %spont end
    decode = poissbayes(rates, idx, idx, windows);
end