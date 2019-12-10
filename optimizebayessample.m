function [bestacc,bestsample] = optimizebayessample(dat,trlInd,bsln,start,finish,span)
loops = finish-start-span;
bestacc = 0;
bestsample = start:start+span; 
for i = 1:loops
    loopstart = start+i-1;
    sample = loopstart:loopstart+span;
    out = bayesjackknife(bayesjackknife(dat,trlInd,sample,bsln);
    acc = trace(out.winavg(1:end-1,:));
    if acc > bestacc
        bestacc = acc;
        bestsample = sample;
    end
end
end