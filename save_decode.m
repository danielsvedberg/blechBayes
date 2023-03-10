function [decode] = save_decode(decode)

decodefolder = [decode.data_dir filesep 'decodes'];
if ~exist(decodefolder, 'dir')
    disp(['creating decode directory'])
    mkdir(decodefolder)
end

windowfolder = [decodefolder filesep decode.window_name];
if ~exist(windowfolder, 'dir')
    disp(['creating directory ' decode.window_name])
    mkdir(windowfolder)
end

decode.root_dir = windowfolder;
decode.path = [windowfolder filesep decode.filename];
save(decode.path,'decode');

end