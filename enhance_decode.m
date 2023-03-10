function [decode] = enhance_decode(data,decode,type)

    decode.exp_day = data.exp_day;
    decode.ID = data.ID;
    decode.Date = data.date;
    decode.trlno = data.trlno;
    st = num2str(decode.windows(1,1));
    stop = num2str(decode.windows(1,2));
    decode.window_name = strcat(st,'_',stop);
    decode.data_dir = data.root_dir; 
    decode.exp_group = data.exp_group;
    
    decode.filename = strcat(type, "decode_", decode.window_name, "_", data.ID, "_", data.Date, ".mat");
    decode.path = strcat(decode.data_dir, filesep, decode.filename);
    save(decode.path,'decode','-v7.3')

end