function OUT = DLV_dailydata_v37(cd,FN_BA,FN_ALS,FN_AHD,FN_DM)
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

% % % % % clear variables
% % % % % clc
% % % % % cd = 'D:\SQL databases\DLV_Veramme\';
% % % % % FN_BA = 'F19DB1_BA';
% % % % % FN_ALS = 'F19DB1_ALS';
% % % % % FN_AHD = 'F19DB1_AHD';
% % % % % FN_DM = 'F19DB1_DM';
% % % % % clc
% % % % cd = 'C:\Users\u0084712\BOX SYNC\Documents\IWT-LA mastitis\SQL_databases\SQL databases\DLV_Dewulf\';
% % % % FN_BA = 'F8DB1_BA';
% % % % FN_ALS = 'F8DB1_ALS';
% % % % FN_AHD = 'F8DB1_AHD';
% % % % FN_DM = 'F8DB1_DM';





%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_BA,FN_ALS,FN_AHD,FN_DM};
for i = 1:4
    for j = 1:4
        if exist([cd FNS{i} ext{j}],'file')
            FN{i} = [cd FNS{i} ext{j}];
            exttype(i) = j;                 % track exttype
        end
    end
end
clear i j FN_BA FN_ALS FN_AHD FN_DM FNS cd ext

% first: replace all commas in the datafile
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
F4 = '%f %f %f %f'; % DM

% third: read tables
try
    a = readtable(FN{1});               % BA
catch
    F1 = '%f %q %f %q %q %q %q %q %q %D %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q'; % BA
    a = readtable(FN{1},'Format',F1);
end
b = readtable(FN{2},'Format',F2);   % ALS
c = readtable(FN{3},'Format',F3);   % AHD
d = readtable(FN{4},'Format',F4);   % DM

clear F1 F2 F3 F4 FN j
%% STEP 2 : select columns we want to keep in each table
col_BA = {'OID','Number','OfficialRegNo','Name','BirthDate'};
col_ALS = {'OID','Animal','LactationNumber','StartDate'};
col_AHD = {'OID','DateAndTime','BasicAnimal','DIM','LactationNumber'};
idx_BA = zeros(1,5);        % to fill in - column indices
idx_ALS = zeros(1,4);       % to fill in - column indices
idx_AHD = zeros(1,5);       % to fill in - column indices

for i = 1:length(col_BA)
    idx_BA(i) = find(contains(a.Properties.VariableNames,col_BA{i})==1); 
end
for i = 1:length(col_ALS)
    idx_ALS(i) = find(contains(b.Properties.VariableNames,col_ALS{i})==1); 
end
for i = 1:length(col_AHD)
    idx_AHD(i) = find(contains(c.Properties.VariableNames,col_AHD{i})==1); 
end
clear col_BA col_ALS col_AHD i

% select columns - for d all columns are kept
a = a(:,idx_BA);    % select columns to keep
b = b(:,idx_ALS);   % select columns to keep
c = c(:,idx_AHD);   % select columns to keep

% rename columns for merging - there are in order of col_XXX
a.Properties.VariableNames = {'BA','Number','OfficialRegNo','Name','BDate'};    %BA
b.Properties.VariableNames = {'OID','BA','Lac','Calving'};      % ALS
c.Properties.VariableNames = {'OID2','Date','BA','DIM','Lac'};  % AHD
d.Properties.VariableNames = {'OID2','TDMY','Dur','A7DY'};      % DM


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
    try m = str2double(a.Number);  a.Number = [];  a.Number = m; end
a = a(:,[ 4 5 1 2 3]);
end


clear idx_HALI idx_HA idx_HADD exttype Number



clear idx_ALS idx_BA idx_AHD

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



%% STEP 3: Merge tables to one
OUT = innerjoin(d,c,'Keys','OID2');      % join AHD and DM
dates = table(datetime(cellstr(OUT.Date)),'VariableNames',{'Date'});
OUT.Date = [];      % delete original column with text dates
OUT.Date(:,1) = NaT;     % prepare insertion of dates         
OUT.Date = dates.Date;   % add new dates in datetime format to OUT

OUT = outerjoin(OUT, a,'Keys', {'BA'},'MergeKeys',1);   % add BasicAnimal data
OUT = outerjoin(OUT, b,'Keys',{'BA','Lac'},'MergeKeys',1);

% correct LactationNumber
OUT.Lac = OUT.LacNew; OUT.LacNew = [];

% correct DIM
OUT.DIM2(:,1) = datenum(OUT.Date)-datenum(OUT.Calving);



%% STEP 4: preprocessing of table OUT
% Step 1 : delete records for animals without milkings
OUT(isnan(OUT.OID2)==1,:) = [];     % delete

% Step 2: correct records for which no calving date is available
OUT.Calving(isnat(OUT.Calving)==1) = OUT.Date(isnat(OUT.Calving)==1) - OUT.DIM(isnat(OUT.Calving)==1);

% Step 3: c
OUT.DIM2(:,1) = datenum(OUT.Date)-datenum(OUT.Calving);

% sub = OUT(OUT.DIM2-OUT.DIM ~=0,:);
% cows = unique(sub.BA);
% close all
% for i = 1:length(cows)
%     figure(i); subplot(2,1,1); hold on
%     ind = find(OUT.BA == cows(i));
%     plot(OUT.Date(ind), OUT.TDMY(ind),'.--','LineWidth',2,'MarkerSize',14)
%     yyaxis right
%     plot(OUT.Date(ind),OUT.Lac(ind),'--','LineWidth',2)
%     subplot(2,1,2); hold on
%     plot(OUT.Date(ind), OUT.TDMY(ind),'.--','LineWidth',2,'MarkerSize',14)
%     yyaxis right
%     plot(OUT.Date(ind),OUT.DIM(ind),'--','LineWidth',2,'Color',[1 0 0])     % red
%     plot(OUT.Date(ind),OUT.DIM2(ind),'--','LineWidth',2,'Color',[1 0 1])    % cyan
% end

OUT.DIM = OUT.DIM2; OUT.DIM2 = [];  % keep correct DIM

% delete redundant columns
OUT.OID = [];
OUT.OID2 = [];

% Change order of columns
OUT = OUT(:,[4 8 9 10 6 11 12 7 5 1 2 3 ]);


%% STEP 5: construct summary table
% number of unique animals
% number of unique lactations
% startdate
% enddate
SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
SUM.NUniAn(1,1) = length(unique(OUT.BA));
SUM.NUniLac(1,1) = length(unique(OUT{:,[1 5]},'rows'));
SUM.Start(1,1) = min(OUT.Date);
SUM.End(1,1) = max(OUT.Date);




