function OUT = DLV_dailydata_v51(cd,FN_HA,FN_HALI,FN_HADD)
% This function constructs the 'daily data' from the delaval backups
% constructed with software version v3.7
% INPUTS:   cd      current directory: where the xls/txt files are stored
%           FN_HA   Filename of the BasicAnimal table
%           FN_HALI  Filename of the Animal Lactation Summary table
%           FN_HADD  Filename of the Animal Historical Data table
%           FN_DM   Filename of the Daily Milk table
%
% OUTPUT    OUT     Merge and preprocessed table containing daily yields
%
% STEP 1: Load tables in matlab format
% STEP 2: Select columns we want to keep in each table & rename
% STEP 3: Merge tables into data table
% STEP 4: Preprocessing to correct for errors
% 
% % % % % clear variables
% % % % % clc
% % % % % cd = 'D:\SQL databases\DLV_VanDeVloet\';     %v5.1
% % % % % FN_HA = 'F17DB1_HA';
% % % % % FN_HALI = 'F17DB1_HALI';
% % % % % FN_HADD = 'F17DB1_HADD';






%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_HA,FN_HALI,FN_HADD};
for i = 1:3
    for j = 1:4
        if exist([cd FNS{i} ext{j}],'file')
            FN{i} = [cd FNS{i} ext{j}];
            exttype(i) = j;                 % track exttype
        end
    end
end
clear i j FN_HA FN_HALI FN_HADD FNS cd ext

% first: replace all commas in the datafile
% first: replace all commas in the datafile IF NOT XLS
for j = 1:length(FN)    % all filenames
    if exttype(j)<3
        comma2point_overwrite(FN{j})    % overwrite commas with points for all files in folders
    end
end

% second: determine input formats and locate the position of these formats

% third: read tables
try
    F1 = '%f %f %q %q %f %f %f %q %{yyyy-MM-dd HH:mm:ss}D %q %q %q %q %q %q %q %q %q'; % HA
    a = readtable(FN{1},'Format',F1);   % HA
catch
    a = readtable(FN{1});
end
b = readtable(FN{2});               % HALI
c = readtable(FN{3});   % HADD

clear F1  FN j exttype
%% STEP 2 : select columns we want to keep in each table
col_HA = {'OID','Number','OffRegNumber','Name','BirthDate'};
col_HALI = {'OID','Animal','LactationNumber','StartDate'};
col_HADD = {'OID','DayDate','Animal','DIM','LactationNumber','DailyYield','Last7DayAvg','MilkingDurationInSec','Milkings','Kickoffs','Incompletes'};
idx_HA = zeros(1,length(col_HA));        % to fill in - column indices
idx_HALI = zeros(1,length(col_HALI));       % to fill in - column indices
idx_HADD = zeros(1,length(col_HADD));       % to fill in - column indices

for i = 1:length(col_HA)
    idx_HA(i) = find(contains(a.Properties.VariableNames,col_HA{i})==1,1); 
end
for i = 1:length(col_HALI)
    idx_HALI(i) = find(contains(b.Properties.VariableNames,col_HALI{i})==1,1); 
end
for i = 1:length(col_HADD)
    idx_HADD(i) = find(contains(c.Properties.VariableNames,col_HADD{i})==1,1); 
end
clear col_HA col_HALI col_HADD i

% select columns - for d all columns are kept
a = a(:,idx_HA);    % select columns to keep
b = b(:,idx_HALI);   % select columns to keep
c = c(:,idx_HADD);   % select columns to keep

% rename columns for merging - there are in order of col_XXX
a.Properties.VariableNames = {'BA','Number','OfficialRegNo','Name','BDate'};    %HA
b.Properties.VariableNames = {'OID','BA','Lac','Calving'};      % HALI
c.Properties.VariableNames = {'OID2','Date','BA','DIM','Lac','TDMY','A7DY','Dur','Milkings','Kickoffs','Incompletes'};  % HADD

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

%% STEP 3: Correct Lactation numbers if not possible (similar to LELY)
% we notice that in very rare cases the laction number is increased while
% no new lactation is started. In AnimalLactationSummary, these records are
% associated with no calving date, and can be detected and corrected for as
% such.
% % % b = sortrows(b,2);      % sort per BA
% % % b(b.Lac==0,:) =[];        % delete entry date = 0th lactations
% % % cows = b.BA(isnat(b.Calving)==1);  % find all cows for which this happens
% % % b.LacNew(:,1) = b.Lac;
% % % b.Calving2(:,1) = b.Calving;
% % % for i = 1:length(cows)
% % %     ind = find(b.BA == cows(i));
% % %     idx = find(isnat(b.Calving(ind))==1);
% % %     
% % %     if b.Lac(ind(idx))~= 1
% % %         b.Calving2(ind(idx),1)= b.Calving(ind(idx-1));
% % %         b.LacNew(ind(idx),1)= b.Lac(ind(idx-1));
% % %     end
% % % end



%% STEP 3: Merge tables to one
c(c.Lac==0,:) = [];
c(isnan(c.TDMY)==1,:) = [];% delete empty rows
c = sortrows(c,{'BA','Date'});

OUT = innerjoin(c, a,'Keys', {'BA'});   % add BasicAnimal data

OUT = AddLacN_DLV(OUT,b(:,[2 3 4]));


% % % OUT = innerjoin(b,c,'Keys',{'BA','Lac'});      % join HADD and DM
% % % OUT = sortrows(OUT,[2 6]);


%% STEP 4: preprocessing of table OUT
% Step 1 : delete records for animals without milkings
% OUT(isnan(OUT.OID2)==1,:) = [];     % delete
% 
% % Step 2: correct records for which no calving date is available
% OUT.Calving(isnat(OUT.Calving)==1) = OUT.Date(isnat(OUT.Calving)==1) - OUT.DIM(isnat(OUT.Calving)==1);
% 
% % Step 3: c
% OUT.DIM2(:,1) = datenum(OUT.Date)-floor(datenum(OUT.Calving));
% OUT = sortrows(OUT,[2 6]);

% sub = OUT(OUT.DIM2-OUT.DIM ~=0,:);
% cows = unique(sub.BA);
% close all
% for i = 1:length(cows)
%     figure(i); subplot(2,1,1); hold on
%     ind = find(OUT2.BA == cows(i));
%     plot(OUT2.Date(ind), OUT2.TDMY(ind),'.--','LineWidth',2,'MarkerSize',14)
%     yyaxis right
%     plot(OUT2.Date(ind),OUT2.Lac(ind),'--','LineWidth',2)
%     plot(OUT2.Date(ind),OUT2.LacNew(ind),'--','LineWidth',2,'Color',[1 0 0])
%     subplot(2,1,2); hold on
%     plot(OUT2.Date(ind), OUT2.TDMY(ind),'.--','LineWidth',2,'MarkerSize',14)
%     yyaxis right
%     plot(OUT2.Date(ind),OUT2.DIM(ind),'--','LineWidth',2,'Color',[1 0 0])     % red
% %     plot(OUT.Date(ind),OUT.DIM2(ind),'--','LineWidth',2,'Color',[1 0 1])    % cyan
% end

% OUT.DIM = OUT.DIM2; OUT.DIM2 = [];  % keep correct DIM

% delete redundant columns
OUT.OID2 = [];
OUT.DIM = OUT.DIM-0.1; OUT.DIM(OUT.DIM<0.0001) = 0;

% Change order of columns
OUT = OUT(:,[2 10 11 12 13 15 14 1 3 4 5 6 7 8 9]);

clear m dates 
%% STEP 5: construct summary table
% number of unique animals
% number of unique lactations
% startdate
% enddate
% SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
% SUM.NUniAn(1,1) = length(unique(OUT.BA));
% SUM.NUniLac(1,1) = length(unique(OUT{:,[1 7]},'rows'));
% SUM.Start(1,1) = min(OUT.Date);
% SUM.End(1,1) = max(OUT.Date);




