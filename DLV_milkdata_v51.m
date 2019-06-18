function OUT = DLV_milkdata_v51(cd,FN_BA,FN_ALS,FN_SMY,FN_VMY)
% This function constructs the 'milk data' from the delaval backups
% constructed with software version v5.1
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

% % % % % 
% % % % % clear variables
% % % % % clc
% % % % % cd = 'D:\SQL databases\DLV_VanDeVloet\';
% % % % % FN_BA = 'F17DB1_BA';
% % % % % FN_ALS = 'F17DB1_HALI';
% % % % % FN_SMY = 'F17DB1_SMY';
% % % % % FN_VMY = 'F17DB1_VMY';



%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_BA,FN_ALS,FN_SMY,FN_VMY};
for i = 1:length(FNS)
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
% F2 = '%f %q %f %f %{yyyy-MM-dd HH:mm:ss}D %{yyyy-MM-dd HH:mm:ss}D %f %f %q %q';  % ALS

% third: read tables
a = readtable(FN{1});               % BA
b = readtable(FN{2});               % ALS

try 
    a = readtable(FN{1});               % BA
catch 
    F1 = '%f %q %f %q %q %q %q %q %q %D %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q'; % BA
    a = readtable(FN{1}, 'Format',F1);               % BA
end
    
try 
    c = readtable(FN{3});   % SMY
catch
    F3 = '%f %f %f %f %f %q %q %f %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %f '; % SMY
    c = readtable(FN{3},'Format',F3);   % SMY
end

if exttype(4)>2
    opts = detectImportOptions(FN{4});
    opts = setvartype(opts,'double');
    d = readtable(FN{4},opts);               % VMY
else
    d = readtable(FN{4});
end

clear F1 F2 F3 F4 FN j exttype opts
%% STEP 2 : select columns we want to keep in each table
col_BA = {'OID','Number','OfficialRegNo','Name','BirthDate'};
col_ALS = {'OID','Animal','LactationNumber','StartDate'};
col_SMY = {'OID','BasicAnimal','TotalYield','BeginTime','EndTime','PreviousEndTime','Destination','SessionNo'};
col_VMY = {'OID','QuarterLFYield','QuarterRFYield','QuarterLRYield','QuarterRRYield','ConductivityLF','ConductivityRF','ConductivityLR','ConductivityRR','BloodLF','BloodRF','BloodLR','BloodRR','PeakFlowLF','PeakFlowRF','PeakFlowLR','PeakFlowRR','MeanFlowLF','MeanFlowRF','MeanFlowLR','MeanFlowRR','Mdi','NotMilkedTeats','Incomplete','Kickoff'};

idx_BA = zeros(1,length(col_BA));        % to fill in - column indices
idx_ALS = zeros(1,length(col_ALS));       % to fill in - column indices
idx_SMY = zeros(1,length(col_SMY));       % to fill in - column indices
idx_VMY = zeros(1,length(col_VMY));       % to fill in - column indices

for i = 1:length(col_BA)
    idx_BA(i) = find(contains(a.Properties.VariableNames,col_BA{i})==1); 
end
for i = 1:length(col_ALS)
    idx_ALS(i) = find(contains(b.Properties.VariableNames,col_ALS{i})==1); 
end
for i = 1:length(col_SMY)
    idx_SMY(i) = find(contains(c.Properties.VariableNames,col_SMY{i})==1,1); 
end
for i = 1:length(col_VMY)
    idx_VMY(i) = find(contains(d.Properties.VariableNames,col_VMY{i})==1); 
end
clear col_BA col_ALS col_SMY col_VMY i

% select columns - for d all columns are kept
a = a(:,idx_BA);    % select columns to keep
b = b(:,idx_ALS);   % select columns to keep
c = c(:,idx_SMY);   % select columns to keep
d = d(:,idx_VMY);   % select columns to keep


% rename columns for merging - there are in order of col_XXX
a.Properties.VariableNames = {'BA','Number','OfficialRegNo','Name','BDate'};    %BA
b.Properties.VariableNames = {'OID','BA','Lac','Calving'};      % ALS
c.Properties.VariableNames = {'OID2','BA','TMY','Date','EndTime','PEndTime','Dest','SesNo'};  % SMY
d.Properties.VariableNames = {'OID2','MYLF','MYRF','MYLR','MYRR','ECLF','ECRF','ECLR','ECRR','BloodLF','BloodF','BloodLR','BloodRR','PFLF','PFRF','PFLR','PFRR','MFLF','MFRF','MFLR','MFRR','MDI','NotMilkedTeats','Incomplete','Kickoff'};

% BA
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

% check whether data is cell of SMY
if isdatetime(c.Date(1))==0
    dates = table(datetime(cellstr(c.Date)),'VariableNames',{'Date'});
    c.Date = [];      % delete original column with text dates
    c.Date(:,1) = NaT;     % prepare insertion of dates
    c.Date(:,1) = dates.Date;   % add new dates in datetime format to OUT
end
if isdatetime(c.EndTime(1))==0
    dates1 = table(datetime(cellstr(c.EndTime)),'VariableNames',{'EndTime'});
    dates2 = table(datetime(cellstr(c.PEndTime)),'VariableNames',{'PEndTime'});
    c.EndTime = [];      % delete original column with text dates
    c.PEndTime = [];      % delete original column with text dates
    c.EndTime(:,1) = NaT;     % prepare insertion of dates
    c.PEndTime(:,1) = NaT;     % prepare insertion of dates
    c.EndTime(:,1) = dates1.EndTime;   % add new dates in datetime format to OUT
    c.PEndTime(:,1) = dates2.PEndTime;   % add new dates in datetime format to OUT
end
if isnumeric(c.OID2(1))==0
    m = zeros(size(c.OID2,1),size(c.OID2,2));
    m = str2double(c.OID2);  c.OID2 = [];  c.OID2 = m;
    try m = str2double(c.TMY);  c.TMY = [];  c.TMY = m; end
    try m = str2double(c.BA);  c.BA = [];  c.BA = m; end
    try m = str2double(c.Dest);  c.Dest = [];  c.Dest = m; end
    try m = str2double(c.SesNo);  c.SesNo = [];  c.SesNo = m; end
c = c(:,[4 6 5 1 2 3 7 8]);
end






clear idx_ALS idx_BA idx_AHD idx_VMY idx_SMY
clear exttype opts ans m dates dates1 dates2

%% STEP 3: Correct Lactation numbers if not possible (similar to LELY)
% we notice that in very rare cases the laction number is increased while
% no new lactation is started. In AnimalLactationSummary, these records are
% associated with no calving date, and can be detected and corrected for as
% such.
% % % b = sortrows(b,2);      % sort per BA
% % % cows = b.BA(isnat(b.Calving)==1);  % find all cows for which this happens
% % % b.LacNew(:,1) = b.Lac;
% % % for i = 1:length(cows)
% % %     ind = find(b.BA == cows(i));
% % %     idx = find(isnat(b.Calving(ind))==1);
% % %     
% % %     if b.Lac(ind(idx))~= 1
% % %         b.Calving(ind(idx))= b.Calving(ind(idx-1));
% % %         b.LacNew(ind(idx))= b.Lac(ind(idx-1));
% % %     end
% % % end
% % % 
% % % clear i cows idx ind

%% STEP 3: Merge tables to one
OUT = innerjoin(c,d,'Keys','OID2');      % join AHD and DM
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

OUT = innerjoin(OUT, a,'Keys', {'BA'});         % add BasicAnimal data

% add lactation number using AddLacN_DLV
OUT = AddLacN_DLV(OUT,b(:,[2 3 4]));

clear dates1 dates2 dates3 ind test



%% STEP 4: preprocessing of table OUT
% delete rows without OID2
OUT(isnan(OUT.OID2)==1,:)= [];
% delete redundant columns
OUT.OID2 = [];

% Change order of columns
OUT = OUT(:,[1 32 33 34 35 38 36 37 29 30 31 4 2 3 26 27 28 5:25]);


%% STEP 5: construct summary table
% number of unique animals
% number of unique lactations
% startdate
% enddate
SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
SUM.NUniAn(1,1) = length(unique(OUT.BA));
SUM.NUniLac(1,1) = length(unique(OUT{:,[1 8]},'rows'));
SUM.Start(1,1) = min(OUT.BeginTime);
SUM.End(1,1) = max(OUT.BeginTime);




