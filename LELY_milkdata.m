function OUT = LELY_milkdata(cd, FN_DEV, FN_LAC, FN_ANI, FN_MVIS)

%%%% tekst en uitleg


clear variables
clc
cd = 'D:\SQL databases\LELY_DeBlaiser\';

FN_DEV = 'L2DB1_DEV';       % device visit
FN_MVIS = 'L2DB1_MVIS';     % milk visit
FN_LAC = 'L2DB1_LAC';       % lactation
FN_ANI = 'L2DB1_ANI';       % animal

%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt','.csv','.xls','.xlsx'};   % all possible file extensions
FNS = {FN_ANI,FN_LAC,FN_DEV,FN_MVIS};
for i = 1:length(FNS)
    for j = 1:length(FNS)
        if exist([cd FNS{i} ext{j}],'file')>0
            FN{i} = [cd FNS{i} ext{j}];
            exttype(i) = j;                 % track exttype
        end
    end
end
clear i j FN_MVIS FN_DEV FN_LAC FN_ANI cd ext

% first: replace all commas in the datafile IF NOT XLS
for j = 1:length(FN)    % all filenames
    if exttype(j)<3
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
    F3 = '%f %f %f %{yyyy-MM-dd HH:mm:ss}D %{yyyy-MM-dd HH:mm:ss}D %q %q %q %q %q %q %f %{yyyy-MM-dd HH:mm:ss}D %f %f %{yyyy-MM-dd HH:mm:ss}D %q %f';           % format DeviceVisit
    c = readtable(FN{3}, 'Format',F3);      % DDEV
catch
    c = readtable(FN{3});                   % DEV
end

d = readtable(FN{4});                   % MVIS

clear F1 F2 F3 F4 FN j exttype FNS ans


%%%%%%%%%%%%%%%%%%%%%
d2 = d; d = d2;
%%%%%%%%%%%%%%%%%%%%%

%% STEP 2  select columns we want to keep in each table
col_ANI = {'AniId','AniName','AniUserNumber','AniLifeNumber','AniBirthday'};
col_LAC = {'LacId','LacAniId','LacNumber','LacCalvingDate'};
col_DEV = {'DviId','DviAniId','DviStartTime','DviEndTime','DviIntervalTime'};
col_MVIS = {'MviId','MviDviId','MviMilkYield','MviMilkDuration','MviMilkSpeedMax','MviWeight','MviMilkTemperature','MviMilkDestination','MviMilkTime','MviLFMilkYield','MviRFMilkYield','MviLRMilkYield','MviRRMilkYield','MviLFConductivity','MviRFConductivity','MviLRConductivity','MviRRConductivity'};

idx_ANI = zeros(1,length(col_ANI));        % to fill in - column indices
idx_LAC = zeros(1,length(col_LAC));       % to fill in - column indices
idx_DEV = zeros(1,length(col_DEV));       % to fill in - column indices
idx_MVIS = zeros(1,length(col_MVIS));       % to fill in - column indices

for i = 1:length(col_ANI)
    idx_ANI(i) = find(contains(a.Properties.VariableNames,col_ANI{i})==1,1); 
end
for i = 1:length(col_LAC)
    idx_LAC(i) = find(contains(b.Properties.VariableNames,col_LAC{i})==1,1); 
end
for i = 1:length(col_DEV)
    idx_DEV(i) = find(contains(c.Properties.VariableNames,col_DEV{i})==1,1); 
end
for i = 1:length(col_MVIS)
    idx_MVIS(i) = find(contains(d.Properties.VariableNames,col_MVIS{i})==1,1); 
end
clear col_ANI col_LAC col_DEV col_MVIS i

% select columns - for d all columns are kept
a = a(:,idx_ANI);    % select columns to keep
b = b(:,idx_LAC);   % select columns to keep
c = c(:,idx_DEV);   % select columns to keep
d = d(:,idx_MVIS);   % select columns to keep

% adjust VariableNames for merging
a.Properties.VariableNames = {'AniId','Name','UserN','LifeNumber','BDate'};
b.Properties.VariableNames = {'LacId','AniId','Lac','Calving'};
c.Properties.VariableNames = {'DviId','AniId','StartTime','EndTime','MI'};
d.Properties.VariableNames = {'MviId','DviId','TMY','Dur','Speed','Weigth','MilkT','Dest','MilkTime','MYLF','MYLH','MYRF','MYRH','ECLF','ECLH','ECRF','ECRH'}; % VN MilkVisit


clear idx_ANI idx_LAC idx_DEV idx_MVIS ans

%% STEP 3: Merge tables to one

% per milking datasets

OUT = innerjoin(d,c,'Keys','DviId'); % join the per milking data
OUT = sortrows(OUT,{'AniId','StartTime'});           % sort on animal ID and date
OUT = AddLacN_LELY(OUT,b(:,[2 3 4])); % add lactation, DIM and calvingdate     
OUT = innerjoin(OUT,a,'Keys','AniId'); % add cow details to milk dataset
    
%% STEP 4: Sort and delete rows (preprocess)
OUT(isnan(OUT.MviId)==1,:) = [];     % delete visits that are no milkings for the per milking data
OUT.MviId = [];
OUT.DviId = [];

OUT = OUT(:,[16 23 24 25 26 22 21 17 18 20 19 1:15]); % select columns and delete redundant (= MviId, DviId, Milking, Date)
