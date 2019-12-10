function bestmodel = optimizebayessampleGPU(dat,trlInd,bsln,start,finish,span)
loops = finish-start-span;
bestacc = 0;
bestsample = start:start+span-1; 
gpuDat = gpuArray(dat);
gpuInd = gpuArray(trlInd);
gpuBsln = gpuArray(bsln);
for i = 1:loops
    loopstart = start+i-1;
    sample = loopstart:loopstart+span;
    out = bayesjackknifeGPU(gpuDat,gpuInd,gpuArray(sample),gpuBsln);
    acc = trace(out.winavg(1:end-1,:));
    if acc > bestacc
        bestacc = acc;
        bestmodel = out;
    end
end
end