function OUT = LELY_dailydata(cd, FN_MDP, FN_LAC, FN_ANI)


%%%% tekst en uitleg


% % % % clear variables
% % % % clc
% % % % cd = 'D:\SQL databases\LELY_DeBlaiser\';
% % % % FN_MDP = 'L2DB1_DAY';
% % % % FN_LAC = 'L2DB1_LAC';
% % % % FN_ANI = 'L2DB1_ANI';
% % % % clc
% % % % clc
% cd = 'D:\SQL databases\LELY_Vanderstraeten\';
% FN_MDP = 'L9DB1_MDP';
% FN_LAC = 'L9DB1_LAC';
% FN_ANI = 'L9DB1_ANI';
% 



%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_ANI,FN_LAC,FN_MDP};
for i = 1:length(FNS)
    for j = 1:length(ext)
        if exist([cd FNS{i} ext{j}],'file')~=0
            FN{i} = [cd FNS{i} ext{j}];
            exttype(i) = j;                 % track exttype
        end
    end
end
clear i j FN_MDP FN_LAC FN_ANI cd ext

% first: replace all commas in the datafile IF NOT XLS
for j = 1:length(FN)    % all filenames
    if exttype(j)<2
        comma2point_overwrite(FN{j})    % overwrite commas with points for all files in folders
    end
end

% second: read tables
a = readtable(FN{1});                       % ANI

try 
    F2 = '%f %f %f %q %{yyyy-MM-dd HH:mm:ss}D %q %q %q %q %q %q %q %q %q %q';
    b = readtable(FN{2},'Format',F2);       % LAC
catch
    b = readtable(FN{2});                   % LAC
end

try
    F3 = '%f %f %D %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %q %q';  % format Milk Day Production
    c = readtable(FN{3});                   % MDP
catch
    c = readtable(FN{3});                   % MDP
end

clear F1 F2 F3 FN j exttype FNS ans

%% STEP 2  select columns we want to keep in each table
col_ANI = {'AniId','AniName','AniUserNumber','AniLifeNumber','AniBirthday'};
col_LAC = {'LacId','LacAniId','LacNumber','LacCalvingDate'};
col_MDP = {'MdpId','MdpAniId','MdpProductionDate','MdpDayProduction','MdpISK','MdpMilkings','MdpRefusals','MdpFailures','MdpFatPercentage','MdpProteinPercentage','MdpLactosePercentage','MdpSCC','MdpAverageWeight'};
idx_ANI = zeros(1,length(col_ANI));        % to fill in - column indices
idx_LAC = zeros(1,length(col_LAC));       % to fill in - column indices
idx_MDP = zeros(1,length(col_MDP));       % to fill in - column indices

for i = 1:length(col_ANI)
    idx_ANI(i) = find(contains(a.Properties.VariableNames,col_ANI{i})==1,1); 
end
for i = 1:length(col_LAC)
    idx_LAC(i) = find(contains(b.Properties.VariableNames,col_LAC{i})==1,1); 
end
for i = 1:length(col_MDP)
    idx_MDP(i) = find(contains(c.Properties.VariableNames,col_MDP{i})==1,1); 
end
clear col_ANI col_LAC col_MDP i

% select columns - for d all columns are kept
a = a(:,idx_ANI);    % select columns to keep
b = b(:,idx_LAC);   % select columns to keep
c = c(:,idx_MDP);   % select columns to keep

% adjust VariableNames for merging
a.Properties.VariableNames = {'AniId','Name','UserN','LifeNumber','BDate'};
b.Properties.VariableNames = {'LacId','AniId','Lac','Calving'};
c.Properties.VariableNames = {'MdpId','AniId','Date','TDMY','ISK','Milkings','Refusals','Failures','Fat','Protein','Lactose','SCC','Weight'};

% if no numbers, set to numbers
% change variables in a to right formats
if isdatetime(a.BDate(1))==0
    dates = table(datetime(cellstr(a.BDate)),'VariableNames',{'BDate'});
    a.BDate = [];      % delete original column with text dates
    a.BDate(:,1) = NaT;     % prepare insertion of dates
    a.BDate(:,1) = dates.BDate;   % add new dates in datetime format to OUT
end
% convert to numbers
if isnumeric(a.AniId(1))==0
    m = zeros(size(a.AniId,1),size(a.AniId,2));
    m = str2double(a.AniId);
    a.AniId = [];
    a.AniId = m;
    try m = str2double(a.UserN);  a.UserN = [];  a.UserN = m; end
    a = a(:,[4 1 5 2 3]);
end



clear idx_ANI idx_LAC idx_MDP ans

%% STEP 3: Merge tables to one
    
OUT = AddLacN_LELY(c,b(:,[2 3 4]));              % add calving, lac and DIM
OUT = sortrows(OUT,[2 3]);                       % sort on animal ID and date
OUT = innerjoin(OUT,a,'Keys','AniId'); % add Animal information

%% STEP 4: Sort and delete rows (preprocess)

OUT(isnan(OUT.MdpId)==1,:) = [];
OUT.MdpId = [];

OUT = OUT(:,[1 16 17 18 19 15 14 2 13 3 4 5 6 7 8 9 10 11 12 ]);




