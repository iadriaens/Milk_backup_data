function OUT = DLV_milkdata_v5x(cd,FN_BA,FN_ALS,FN_SMY,FN_VMY)
% This function constructs the 'milk data' from the delaval backups
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

% % clear variables
% % clc
% % cd = 'D:\SQL databases\DLV_Dellepierre\';       %v5.2
% % FN_BA = 'F18DB1_BA';
% % FN_ALS = 'F18DB1_ALS';
% % FN_SMY = 'F18DB1_SMY';
% % FN_VMY = 'F18DB1_VMY';
% % clear variables
% % clc
% % cd = 'D:\SQL databases\DLV_VanMieghem\';    %v5.3
% % FN_BA = 'F20DB2_BA';
% % FN_ALS = 'F20DB2_ALS';
% % FN_SMY = 'F20DB2_SMY';
% % FN_VMY = 'F20DB2_VMY';



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
% F1 = '%f %q %f %q %q %q %q %q %q %D %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q'; % BA
% F2 = '%f %q %f %f %{yyyy-MM-dd HH:mm:ss}D %{yyyy-MM-dd HH:mm:ss}D %f %f %q %q';  % ALS

% third: read tables
a = readtable(FN{1});               % BA
b = readtable(FN{2});               % ALS

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

if isdatetime(b.Calving(1))==0
    dates = table(datetime(cellstr(b.Calving)),'VariableNames',{'Calving'});
    b.Calving = [];      % delete original column with text dates
    b.Calving(:,1) = NaT;     % prepare insertion of dates
    b.Calving(:,1) = dates.Calving;   % add new dates in datetime format to OUT
end
if isnumeric(b.BA(1))==0
    m = zeros(size(b.BA,1),size(b.BA,2));
    m = str2double(b.BA);
    b.BA = [];
    b.BA = m;
    try m = str2double(b.Lac);   b.Lac = [];    b.Lac = m; end
    b = b(:,[1 3 4 2]);
end



clear idx_ALS idx_BA idx_AHD idx_VMY idx_SMY
clear exttype opts ans m

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
% SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
% SUM.NUniAn(1,1) = length(unique(OUT.BA));
% SUM.NUniLac(1,1) = length(unique(OUT{:,[1 8]},'rows'));
% SUM.Start(1,1) = min(OUT.BeginTime);
% SUM.End(1,1) = max(OUT.BeginTime);




