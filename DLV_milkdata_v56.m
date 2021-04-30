function OUT = DLV_milkdata_v56(cd,FN_BA,FN_ALS,FN_SMY,FN_VMY,cd_H)
% This function constructs the 'milk data' from the delaval backups
% >>> software version v5.5
%
% INPUTS:   cd      current directory: where the xls/txt files are stored
%           FN_BA   Filename of the BasicAnimal table
%           FN_ALS  Filename of the Animal Lactation Summary table
%           FN_SMY  Filename of the Session Milk Yield table
%           FN_VMY  Filename of the Voluntary Session Yield 
%
% OUTPUT    OUT     Merge and preprocessed table containing daily yields
%
% STEP 0: Preprocess and merge tables with headers
% STEP 1: Load tables in matlab format
% STEP 2: Select columns we want to keep in each table & rename
% STEP 3: Merge tables into data table
% STEP 4: Preprocessing to correct for errors
%
%% STEP 0: combine header and results files
newdir = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Research\Data mining\BAKfiles scripts\tempFiles\';    % in this folder we store the tempfiles

% Basic Animal
ba_H = readtable([cd_H FN_BA '_headers.txt'],'ReadVariableNames',0);    % read variable names
ba_H = ba_H{:,:}';                          % convert to cell array and transpose
writecell(ba_H,[newdir 'FN_BA.txt'],'Delimiter',';');  % write headernames to file
system(['copy "' newdir 'FN_BA.txt"+' '"' cd FN_BA '.txt" "'  newdir 'FN_BA.txt"']);  % combine files using system cmd
fid = fopen([newdir 'FN_BA.txt'],'r'); f=fread(fid,'*char')'; fclose(fid);
f=f(1:length(f)-1);
fid = fopen([newdir 'FN_BA.txt'],'w');fwrite(fid,f); fclose(fid);

% Animal Lactation Summary
als_H = readtable([cd_H FN_ALS '_headers.txt'],'ReadVariableNames',0);    % read variable names
als_H = als_H{:,:}';                          % convert to cell array and transpose
writecell(als_H,[newdir 'FN_ALS.txt'],'Delimiter',';');  % write headernames to file
system(['copy "' newdir 'FN_ALS.txt"+' '"' cd FN_ALS '.txt" "'  newdir 'FN_ALS.txt"']);  % combine files using system cmd
fid = fopen([newdir 'FN_ALS.txt'],'r'); f=fread(fid,'*char')'; fclose(fid);
f=f(1:length(f)-1);
fid = fopen([newdir 'FN_ALS.txt'],'w');fwrite(fid,f); fclose(fid);

% Session Milk Yield
smy_H = readtable([cd_H FN_SMY '_headers.txt'],'ReadVariableNames',0);    % read variable names
smy_H = smy_H{:,:}';                          % convert to cell array and transpose
writecell(smy_H,[newdir 'FN_SMY.txt'],'Delimiter',';');  % write headernames to file
system(['copy "' newdir 'FN_SMY.txt"+' '"' cd FN_SMY '.txt" "'  newdir 'FN_SMY.txt"']);  % combine files using system cmd
fid = fopen([newdir 'FN_SMY.txt'],'r'); f=fread(fid,'*char')'; fclose(fid);
f=f(1:length(f)-1);
fid = fopen([newdir 'FN_SMY.txt'],'w');fwrite(fid,f); fclose(fid);

% Voluntary Session Milk Yield
vmy_H = readtable([cd_H FN_VMY '_headers.txt'],'ReadVariableNames',0);    % read variable names
vmy_H = vmy_H{:,:}';                          % convert to cell array and transpose
writecell(vmy_H,[newdir 'FN_VMY.txt'],'Delimiter',';');  % write headernames to file
system(['copy "' newdir 'FN_VMY.txt"+' '"' cd FN_VMY '.txt" "'  newdir 'FN_VMY.txt"']);  % combine files using system cmd
fid  = fopen([newdir 'FN_VMY.txt'],'r'); f=fread(fid,'*char')'; fclose(fid);
f = strrep(f,'=ja;','deletesemicolon');f = strrep(f,';TotalFlow','deletesemicolon');f = strrep(f,';MsEv','deletesemicolon');f = strrep(f,';KFC','deletesemicolon');f=f(1:length(f)-1);
fid  = fopen([newdir 'FN_VMY.txt'],'w'); fwrite(fid,f);fclose(fid);

clear als_H ba_H smy_H vmy_H ans

% redefine files
FN_BA = 'FN_BA';        % Basic Animal
FN_ALS = 'FN_ALS';      % Animal Lactation Summary
FN_SMY = 'FN_SMY';      % Session Milk Yield
FN_VMY = 'FN_VMY';      % Voluntary Session Milk Yield
cd = newdir;            % new current directory


%% STEP 1 - load tables in matlab
% determine file extension, should be '.txt','csv','xls','xslx'
ext = {'.txt'};   % all possible file extensions
FNS = {FN_BA,FN_ALS,FN_SMY,FN_VMY};
for i = 1:length(FNS)           % length
    FN{i} = [cd FNS{i} ext{1}]; % all three
end
clear i j FN_BA FN_ALS FN_SMY FN_VMY FNS cd ext FN_SMY FN_VMY


% BASIC ANIMAL
opts = detectImportOptions(FN{1});
opts = setvartype(opts,{'OID','Number'},'double');
opts = setvartype(opts,{'BirthDate'},'datetime');
opts = setvartype(opts,{'Name','OfficialRegNo'},'char');
opts.SelectedVariableNames = {'OID','Number','OfficialRegNo','Name','BirthDate'};
a = readtable(FN{1},opts);
    
% ANIMAL LACTATION SUMMARY
opts = detectImportOptions(FN{2});
opts = setvartype(opts,{'OID','Animal','LactationNumber'},'double');
opts = setvartype(opts,{'StartDate'},'datetime');
opts.SelectedVariableNames = {'OID','Animal','LactationNumber','StartDate'};
b = readtable(FN{2},opts);   % ALS

% SESSION MILK YIELD
opts = detectImportOptions(FN{3});
opts = setvartype(opts,{'OID','BasicAnimal','TotalYield','Destination','SessionNo'},'double');
opts = setvartype(opts,{'BeginTime','EndTime','PreviousEndTime'},'datetime');
opts.SelectedVariableNames = {'OID','BasicAnimal','TotalYield','BeginTime','EndTime','PreviousEndTime','Destination','SessionNo'};
c = readtable(FN{3},opts);               % SMY

% VOLUNTARY SESSION MILK YIELD
opts = detectImportOptions(FN{4});
opts = setvartype(opts,{'OID','QuarterLFYield','QuarterRFYield','QuarterLRYield','QuarterRRYield','ConductivityLF','ConductivityRF','ConductivityLR','ConductivityRR','BloodLF','BloodRF','BloodLR','BloodRR','PeakFlowLF','PeakFlowRF','PeakFlowLR','PeakFlowRR','MeanFlowLF','MeanFlowRF','MeanFlowLR','MeanFlowRR','Mdi','NotMilkedTeats','Incomplete','Kickoff','MilkType'},'double');
opts.SelectedVariableNames = {'OID','QuarterLFYield','QuarterRFYield','QuarterLRYield','QuarterRRYield','ConductivityLF','ConductivityRF','ConductivityLR','ConductivityRR','BloodLF','BloodRF','BloodLR','BloodRR','PeakFlowLF','PeakFlowRF','PeakFlowLR','PeakFlowRR','MeanFlowLF','MeanFlowRF','MeanFlowLR','MeanFlowRR','Mdi','NotMilkedTeats','Incomplete','Kickoff','MilkType'};
d = readtable(FN{4},opts);               % VMY

clear F1 F2 F3 F4 FN j exttype opts 

%% STEP 2 : select columns we want to keep in each table
col_BA = {'OID','Number','OfficialRegNo','Name','BirthDate'};
col_ALS = {'OID','Animal','LactationNumber','StartDate'};
col_SMY = {'OID','BasicAnimal','TotalYield','BeginTime','EndTime','PreviousEndTime','Destination','SessionNo'};
col_VMY = {'OID','QuarterLFYield','QuarterRFYield','QuarterLRYield','QuarterRRYield','ConductivityLF','ConductivityRF','ConductivityLR','ConductivityRR','BloodLF','BloodRF','BloodLR','BloodRR','PeakFlowLF','PeakFlowRF','PeakFlowLR','PeakFlowRR','MeanFlowLF','MeanFlowRF','MeanFlowLR','MeanFlowRR','Mdi','NotMilkedTeats','Incomplete','Kickoff','MilkType'};

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
c.Properties.VariableNames = {'OID2','BA','TMY','BeginTime','EndTime','PEndTime','Dest','SesNo'};  % SMY
d.Properties.VariableNames = {'OID2','MYLF','MYRF','MYLR','MYRR','ECLF','ECRF','ECLR','ECRR','BloodLF','BloodRF','BloodLR','BloodRR','PFLF','PFRF','PFLR','PFRR','MFLF','MFRF','MFLR','MFRR','MDI','NotMilkedTeats','Incomplete','Kickoff','MilkType'};

% clear variables
clear idx_ALS idx_BA idx_AHD idx_VMY idx_SMY
clear exttype opts ans m dates dates1 dates2



%% STEP 3: Correct Lactation numbers if not possible (similar to LELY)
% we notice that in some cases the laction number is increased while in the
% data it seems that no new lactation is started. 
% In AnimalLactationSummary, these records are
% associated with no calving date, and can be detected and corrected for as
% such.

b = sortrows(b,[2 3]);      % sort per BA
idx = find(isnat(b.Calving) == 1);   % find all cases for which this happens
cows = b.BA(idx);                    % select BA identity of these cows
for i = 1:length(cows)
    sub = sortrows(c(c.BA == cows(i),:),2); % select all time data of this cow
    sub2 = innerjoin(sub, d,'Keys','OID2'); % merge with DAILY data to obtain only the milkings in the datasets

    if isempty(sub2) == 0       % if no per milking data for this cow: do nothing
        ind = find(datenum(sub2.BeginTime) > datenum(b.Calving(idx(i)-1))+100 & datenum(sub2.BeginTime) < datenum(b.Calving(idx(i)+1))-150 & sub2.DIM < 10,1,'first');

        if isempty(ind)==1
            ind = find(datenum(sub2.BeginTime) > datenum(b.Calving(idx(i)-1))+100 & sub2.DIM < 10,1,'first'); % if it is the last lactation
        end

        DIM = sub2.DIM(ind);                    % find DIM of this calving
        b.Calving(idx(i)) = sub2.BeginTime(ind)-DIM; % correct calving date
        b.IsCorrected(idx(i),1) = 1;            % add tracer that this is corrected
    end
end

clear cows i idx


%% STEP 4: fill in missing BA 

ind = find(isnan(c.BA)==1);
for i = 1:length(ind)
    idx = find(datenum(b.Calving) == floor(datenum(c.BeginTime(ind(i))))-c.DIM(ind(i)) & b.Lac == c.Lac(ind(i)));
    if length(idx)==1
        c.BA(ind(i)) = b.BA(idx);
    end
end

clear ind idx i


%% STEP 5: Merge tables to one

OUT = innerjoin(c,d,'Keys','OID2');      % join AHD and DM
OUT = sortrows(OUT,{'BA','BeginTime'});
OUT = innerjoin(a, OUT,'Keys', {'BA'});   % add BasicAnimal data
OUT = CorLacN_DLV(OUT,b(:,[2 3 4]));        % merge with part of ALS that contains BA, Lac, Calving

OUT.DIM(:,1) = datenum(OUT.EndTime)-datenum(OUT.Calving);

% add time fraction to DIM
OUT.DIM(:,1) = floor(OUT.DIM(:,1)) + rem(datenum(datestr(OUT.EndTime(:,1))),1);


%% STEP 6: preprocessing of table OUT

% Select the cols needed
col_OUT = {'OfficialRegNo','BA','Number','Name','BDate','Calving','Lac',...
           'DIM','BeginTime','EndTime','PEndTime','TMY','Dest','SesNo',...
           'MDI','NotMilkedTeats','Incomplete','Kickoff','MilkType',...
           'MYLF','MYRF','MYLR','MYRR','ECLF','ECRF','ECLR','ECRR','BloodLF','BloodRF','BloodLR','BloodRR',...
           'PFLF','PFRF','PFLR','PFRR','MFLF','MFRF','MFLR','MFRR'};
% prepare indices
idx_OUT = zeros(1,length(col_OUT));        % to fill in - column indices
% find indices
for i = 1:length(col_OUT)
    idx_OUT(i) = find(contains(OUT.Properties.VariableNames,col_OUT{i})==1,1,'first'); 
end
% Change order of columns
OUT = OUT(:,idx_OUT);


%% STEP 5: construct summary table
% number of unique animals
% number of unique lactations
% startdate
% % % enddate
% % SUM = array2table([0 0], 'VariableNames',{'NUniAn','NUniLac'});
% % SUM.NUniAn(1,1) = length(unique(OUT.BA));
% % SUM.NUniLac(1,1) = length(unique(OUT{:,[2 7]},'rows'));
% % SUM.Start(1,1) = min(OUT.BeginTime);
% % SUM.End(1,1) = max(OUT.BeginTime);




