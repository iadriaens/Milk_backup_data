function OUT = DLV_milkdata_v37(cd,FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_VMY)
% This function constructs the 'daily data' from the delaval backups
% constructed with software version v3.7
% INPUTS:   cd      current directory: where the xls/txt files are stored
%           FN_BA   Filename of the BasicAnimal table
%           FN_ALS  Filename of the Animal Lactation Summary table
%           FN_AHD  Filename of the Animal Historical Data table
%           FN_DM   Filename of the Daily Milk table
%
% OUTPUT    OUT     Merge and preprocessed table containing daily yields
%
% STEP 1: Load tables in matlab format
% STEP 2: Select columns we want to keep in each table & rename
% STEP 3: Merge tables into data table
% STEP 4: Preprocessing to correct for errors

% cd = 'D:\SQL databases\DLV_Deschutter\';
% FN_BA = 'F23DB5_BA';
% FN_ALS = 'F23DB5_ALS';
% FN_AHD = 'F23DB5_AHD';
% FN_SMY = 'F23DB5_SMY';
% FN_VMY = 'F23DB5_VMY';
% MILK.Deschutter = DLV_milkdata_v37(cd,FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_VMY);
% clear cd FN_BA FN_ALS FN_AHD FN_SMY FN_VMY
% datenum(max(MILK.Deschutter.EndTime) - datenum(min(MILK.Deschutter.EndTime))



%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_VMY};
for i = 1:5
    for j = 1:4
        if exist([cd FNS{i} ext{j}],'file')
            FN{i} = [cd FNS{i} ext{j}];
            exttype(i) = j;                 % track exttype
        end
    end
end
clear i j FN_BA FN_ALS FN_AHD FN_DM FNS cd ext FN_SMY FN_VMY

% first: replace all commas in the datafile IF NOT XLS
for j = 1:length(FN)    % all filenames
    if exttype(j)<3
        comma2point_overwrite(FN{j})    % overwrite commas with points for all files in folders
    end
end


% second: determine input formats and locate the position of these formats
% F1 = '%f %q %f %q %q %q %q %q %q %D %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q'; % BA
F2 = '%f %q %f %f %{yyyy-MM-dd HH:mm:ss}D %{yyyy-MM-dd HH:mm:ss}D %f %f %q %q';  % ALS
F3 = '%f %q %q %q %f %f %f %f %q %q %f %q %f %q %q'; % AHD

% third: read tables
a = readtable(FN{1});               % BA
b = readtable(FN{2},'Format',F2);   % ALS
c = readtable(FN{3},'Format',F3);   % AHD
d = readtable(FN{4});               % SMY

if exttype(5)>2
    opts = detectImportOptions(FN{5});
    opts = setvartype(opts,'double');
    e = readtable(FN{5},opts);               % VMY
else
    e = readtable(FN{5});
end

clear F1 F2 F3 F4 FN j
%% STEP 2 : select columns we want to keep in each table
col_BA = {'OID','Number','OfficialRegNo','Name','BirthDate'};
col_ALS = {'OID','Animal','LactationNumber','StartDate'};
col_AHD = {'OID','DateAndTime','BasicAnimal','DIM','LactationNumber','EndTime','PreviousEndTime'};
col_SMY = {'OID','TotalYield','Destination','SessionNo'};
col_VMY = {'OID','QuarterLFYield','QuarterRFYield','QuarterLRYield','QuarterRRYield','ConductivityLF','ConductivityRF','ConductivityLR','ConductivityRR','BloodLF','BloodRF','BloodLR','BloodRR','PeakFlowLF','PeakFlowRF','PeakFlowLR','PeakFlowRR','MeanFlowLF','MeanFlowRF','MeanFlowLR','MeanFlowRR','Mdi','NotMilkedTeats','Incomplete','Kickoff'};

idx_BA = zeros(1,5);        % to fill in - column indices
idx_ALS = zeros(1,4);       % to fill in - column indices
idx_AHD = zeros(1,7);       % to fill in - column indices
idx_SMY = zeros(1,4);       % to fill in - column indices
idx_VMY = zeros(1,25);       % to fill in - column indices

for i = 1:length(col_BA)
    idx_BA(i) = find(contains(a.Properties.VariableNames,col_BA{i})==1,1); 
end
for i = 1:length(col_ALS)
    idx_ALS(i) = find(contains(b.Properties.VariableNames,col_ALS{i})==1,1); 
end
for i = 1:length(col_AHD)
    idx_AHD(i) = find(contains(c.Properties.VariableNames,col_AHD{i})==1,1); 
end
for i = 1:length(col_SMY)
    idx_SMY(i) = find(contains(d.Properties.VariableNames,col_SMY{i})==1,1); 
end
for i = 1:length(col_VMY)
    idx_VMY(i) = find(contains(e.Properties.VariableNames,col_VMY{i})==1,1); 
end
clear col_BA col_ALS col_AHD col_SMY col_VMY i

% select columns - for d all columns are kept
a = a(:,idx_BA);    % select columns to keep
b = b(:,idx_ALS);   % select columns to keep
c = c(:,idx_AHD);   % select columns to keep
d = d(:,idx_SMY);   % select columns to keep
e = e(:,idx_VMY);   % select columns to keep


% rename columns for merging - there are in order of col_XXX
a.Properties.VariableNames = {'BA','Number','OfficialRegNo','Name','BDate'};    %BA
b.Properties.VariableNames = {'OID','BA','Lac','Calving'};      % ALS
c.Properties.VariableNames = {'OID2','Date','BA','DIM','Lac','EndTime','PEndTime'};  % AHD
d.Properties.VariableNames = {'OID2','TMY','Dest','SesNo'};      % SMY
e.Properties.VariableNames = {'OID2','MYLF','MYRF','MYLR','MYRR','ECLF','ECRF','ECLR','ECRR','BloodLF','BloodF','BloodLR','BloodRR','PFLF','PFRF','PFLR','PFRR','MFLF','MFRF','MFLR','MFRR','MDI','NotMilkedTeats','Incomplete','Kickoff'};

% change variables in a to right formats
if isdatetime(a.BDate(1))==0
    dates = table(datetime(cellstr(a.BDate)),'VariableNames',{'BDate'});
    a.BDate = [];      % delete original column with text dates
    a.BDate(:,1) = NaT;     % prepare insertion of dates
    a.BDate(:,1) = dates.BDate;   % add new dates in datetime format to OUT
end
% convert to numbers
if isnumeric(a.BA(1))==0
    m = zeros(size(a.BA,1),size(a.BA,2));
    m = str2double(a.BA);
    a.BA = [];
    a.BA = m;
end
if isnumeric(a.Number(1))==0
    m = zeros(size(a.Number,1),size(a.Number,2));
    m = str2double(a.Number);
    a.Number = [];
    a.Number = m;
    a = a(:,[4 5 1 2 3]);
end



clear idx_ALS idx_BA idx_AHD idx_VMY idx_SMY
clear exttype opts ans

%% STEP 3: Correct Lactation numbers if not possible (similar to LELY)
% we notice that in very rare cases the laction number is increased while
% no new lactation is started. In AnimalLactationSummary, these records are
% associated with no calving date, and can be detected and corrected for as
% such.
b = sortrows(b,2);      % sort per BA
cows = b.BA(isnat(b.Calving)==1);  % find all cows for which this happens
b.LacNew(:,1) = b.Lac;
for i = 1:length(cows)
    ind = find(b.BA == cows(i));
    idx = find(isnat(b.Calving(ind))==1);
    
    if b.Lac(ind(idx))~= 1
        b.Calving(ind(idx))= b.Calving(ind(idx-1));
        b.LacNew(ind(idx))= b.Lac(ind(idx-1));
    end
end

clear i cows idx ind

%% STEP 3: Merge tables to one
OUT = innerjoin(d,e,'Keys','OID2');      % join AHD and DM
OUT = innerjoin(c,OUT,'Keys','OID2');
dates1 = table(datetime(cellstr(OUT.Date)),'VariableNames',{'Date'});
dates2 = table(datetime(cellstr(OUT.EndTime)),'VariableNames',{'EndTime'});
dates3 = table(datetime(cellstr(OUT.PEndTime)),'VariableNames',{'PEndTime'});

OUT.Date = [];      % delete original column with text dates
OUT.EndTime = [];   % delete original column with text dates
OUT.PEndTime = [];  % delete original column with text dates

OUT.BeginTime(:,1) = NaT;     % prepare insertion of dates         
OUT.EndTime(:,1) = NaT;       % prepare insertion of dates         
OUT.PEndTime(:,1) = NaT;      % prepare insertion of dates         

OUT.BeginTime(:,1) = dates1.Date;   % add new dates in datetime format to OUT
OUT.EndTime(:,1) = dates2.EndTime;   % add new dates in datetime format to OUT
OUT.PEndTime(:,1) = dates3.PEndTime;   % add new dates in datetime format to OUT

OUT = innerjoin(OUT, a,'Keys', {'BA'});   % add BasicAnimal data
OUT = innerjoin(OUT, b,'Keys',{'BA','Lac'}); % add lactation data

% correct LactationNumber
OUT.Lac = OUT.LacNew; OUT.LacNew = [];

% correct DIM
OUT.DIM2(:,1) = datenum(OUT.EndTime)-datenum(OUT.Calving);

clear dates dates1 dates2 dates3 ind test

%% STEP 4: preprocessing of table OUT
OUT.DIM = OUT.DIM2; OUT.DIM2 = [];  % keep correct DIM

% delete redundant columns
OUT.OID = [];
OUT.OID2 = [];

% Change order of columns
OUT = OUT(:,[1 34 35 36 37 38 3 31 32 33 2 6 4 5 28 29 30 7:27]);


%% STEP 5: construct summary table
% number of unique animals
% number of unique lactations
% startdate
% enddate
SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
SUM.NUniAn(1,1) = length(unique(OUT.BA));
SUM.NUniLac(1,1) = length(unique(OUT{:,[1 7]},'rows'));
SUM.Start(1,1) = min(OUT.BeginTime);
SUM.End(1,1) = max(OUT.BeginTime);




