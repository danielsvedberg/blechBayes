function [decodes] = optiwindow(data)
decodes = struct();
ext = 'opti_decodes.mat';
newfile = strcat(data.ID,'_',data.date,'_',ext);
path = strcat(data.root_dir, filesep, newfile);
if ~exist(path, 'file')
    disp('performing decode-window optimization')
    save(path,'decodes','-v7.3')

    seed = zeros(5,2);
    seed(1:4,1) = 2001;
    seed(1:4,2) = 2500;

    increments = (100:100:1000);
    increments = reshape(increments,1,1,[]);

    winsizes = (0:100:500);
    winsizes = reshape(winsizes,1,1,1,[]);
    winsizes(:,2,:,:) = 0;
    winsizes = flip(winsizes);

    testwinds = seed+increments+winsizes;
    testwinds(5,1,:) = 1001;
    testwinds(5,2,:) = 6000;
    testwinds = reshape(testwinds,5,2,[]);
    n_winds = size(testwinds,3);

    performance = zeros(1,5);
    decodes = struct();

    states = max(data.trlindx);
    threshold = 1/states;
    index = 0;
    for i = 1:n_winds
       decode = gammabayes2(data.rate,data.trainindx,data.trlindx,testwinds(:,:,i));
       for j = 1:5
            performance(j) = decode.perClass(j,j);
       end
       worstperf = min(performance);
       if worstperf > threshold
           index = index + 1;
           decodes(index).decode = decode;
           decodes(index).decode.performance = performance;
       end
    end 
else
    disp('opti-decodes already exist, loading file')
    load(path, 'decodes');

    save(path,'decodes','-v7.3')
end

end

