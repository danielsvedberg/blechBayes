function [decodes, bestdec] = find_best_decodes(decodes,type)
%type can be "taste" or "pal" for taste or palatability decoding
%respectively
bestidx = 1;
bestmin = 0;
bestmean = 0;
for i = 1:length(decodes)
    perf = decodes(i).decode.performance;
    decodes(i).performance = perf;
    decmin = min(perf);
    decmean = mean(perf);
    decodes(i).meanperf = decmean;
    if type == "taste" && decmin >= bestmin && decmean > bestmean
        bestidx = i;
        bestmin = decmin;
        bestmean = decmean;
    elseif type == "pal" && decmin >= bestmin && decmean >= bestmean
        bestidx = i;
        bestmin = decmin;
        bestmean = decmean;
    end
    
end
decodes(bestidx).best = true;
bestdec = decodes(bestidx).decode;

end 