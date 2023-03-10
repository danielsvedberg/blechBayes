function tbl = filesanddatestable(filelist)

nfiles = length(filelist);

animal = regexp(filelist,'DS\d\d','match');
animal = [animal{:}]';

date = regexp(filelist,'\d\d\d\d\d\d','match');
date = [date{:}];
date = reshape(date,[],nfiles);
date = date';
date = date(:,1);
date = datetime(date,'InputFormat','yyMMdd');

tbl = table(animal,date,filelist);

tbl = grouptransform(tbl,'animal',@min,'date','ReplaceValues',false);
tbl.session = days((tbl.date-tbl.fun_date)+1);

end 