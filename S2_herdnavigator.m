%% S2_HerdNavigator
% thiçs script will mine the herd navigator data
% the table names are:
%       HNBiometricData
%       HNBiometricMeasurement
%       HNCowData
%       HNDiagnose
%       HNHeatDetection
%       HNHistoricalData

% Animal information needed is in: HistoriAnimal + AnimalHistoricalData
clear variables
clc
farmname = 'Geysen';



%% STEP 1: set directory and combine headers

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3head\';   % all header files

% find all the files in the folder
% FNfiles = ls(cd);        % this is the list with files in the folder where I saved the MPR results of MCC
FNfiles = ls([cd farmname '_*']);        % this is the list with files in the folder where I saved the MPR results of MCC
FNfiles = FNfiles(1:end,:);

ind = []; for i  = 1:size(FNfiles,1); if isempty(find(contains(FNfiles(i,:),'.txt'))) == 1; ind = [ind; i]; end; end % find no filenames
FNfiles(ind,:) = []; clear ind     % delete

% find all farmnames = for all files everything before '_'
files = array2table((1:length(FNfiles))','VariableNames',{'No'});
files.Farm(:,:) = repmat({'na'},length(FNfiles),1);
files.Date(:,1) = NaT;
files.Version(:,1) = repmat(0,length(FNfiles),1);
files.Table(:,:) = repmat({'na'},length(FNfiles),1);
files.FN(:,:) = repmat({'na'},length(FNfiles),1);
for i = 1:length(FNfiles(:,1))   % run through all the files in the folder
    numLoc = regexp(FNfiles(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    endLoc = regexp(FNfiles(i,:),'.txt');    % this gives the end of the filename
    
    % Store data in 'files'
    files.Farm{i,1} = FNfiles(i,1:numLoc(1)-1);   % FarmName:length(FN(i,1:numLoc(1)-1))}
    files.Date(i,1) = datetime(FNfiles(i,numLoc(1)+1:numLoc(1)+8),'InputFormat','yyyyMMdd','Format','dd/MM/yyyy'); % Date
    files.Version(i,1) = str2double(FNfiles(i,numLoc(3)+1:numLoc(4)-1));     % Version
    files.Table{i,1} = FNfiles(i,numLoc(end)+1:endLoc-1);           % TableName
    files.FN{i,1} = FNfiles(i,1:endLoc-1);      % full FileName    
end
files = sortrows(files, {'Farm','Date'});

% clear variables
clear i endLoc numLoc  FNfiles

% select tables containing treatment / diagnosis data
selTables = {'HNBiometricData','HNBiometricMeasurement','HNCowData','HNDiagnose','HNHeatDetection','HNHistoricalData'};
ind = find(ismember(files.Table, selTables) & ismember(files.Farm,farmname));
selFiles = files(ind,:);

% unique farms in the dataset
Farms = unique(selFiles.Farm);  % all unique farms in the dataset

% combine headers with datafiles 
for i = 1:height(selFiles)
    d = dir([cd selFiles.FN{i} '.txt']); 
    
    if d.bytes ~= 0
        datapath = [cd selFiles.FN{i} '.txt'];
        headerpath = [cd_H selFiles.FN{i} '_headers.txt'];
        
        if month(selFiles.Date(i)) < 10 && day(selFiles.Date(i)) < 10
            C = [selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) '0' num2str(day(selFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) '0' num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        elseif month(selFiles.Date(i)) < 10 && day(selFiles.Date(i)) >= 10
            C = [selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        elseif month(selFiles.Date(i)) >= 10 && day(selFiles.Date(i)) < 10
            C = [selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) '0' num2str(day(selFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) '0'  num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        else
            C = [selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        end
        
        % combine and save
        if contains(selFiles.Table{i},'HNBiometricData')
            HNBMD.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HNBiometricMeasurement')
            HNBMM.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HNCowData')
            HNCow.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HNDiagnose')
            HNDiag.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HNHeatDetection')
            HNHeat.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        else % HistoricalData
            HNHist.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end

% check formats and contents
clear C d i ind savepath datapath
clear HNHist % contains no information
clear HNCow  % contains only the 'reprostatus' = no additional information
% clear HNBMM  % contains link between tables, not needed

% HNBMD contains the raw and smoothed data + type. 2
%       Type 1 = BHB
%       Type 2 = P4
%       Type 3 = LDH
% HNDiag contains diagnosis data
%       Type  200 ==> P4 'alerts' > 
%       Type >= 200 & < 300 ==> >BHB 'alerts' corresponds to Biometric TYPE 1
%       Type >= 300 ==> LDH alerts (No = equal to measurements)

% read animal historical data information
ind = find((ismember(files.Table, 'AnimalHistoricalData') & contains(files.FN,'_HN_') & ismember(files.Farm,farmname)));
aniFiles = files(ind,:);

% combine headers with datafiles 
for i = 1:height(aniFiles)
    d = dir([cd aniFiles.FN{i} '.txt']); 
    
    if d.bytes ~= 0
        datapath = [cd aniFiles.FN{i} '.txt'];
        headerpath = [cd_H aniFiles.FN{i} '_headers.txt'];
        
        if month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) >= 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) >= 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0'  num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        else
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        end
        
        % combine and save
        AHD.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
    end
end

% read animaldata from HistoryAnimal
ind = find((endsWith(files.Table, 'HistoryAnimal') & contains(files.FN,'_HN_') & ismember(files.Farm,farmname)));
aniFiles = files(ind,:);

% combine headers with datafiles 
for i = 1:height(aniFiles)
    d = dir([cd aniFiles.FN{i} '.txt']); 
    
    if d.bytes ~= 0
        datapath = [cd aniFiles.FN{i} '.txt'];
        headerpath = [cd_H aniFiles.FN{i} '_headers.txt'];
        
        if month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) >= 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) >= 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0'  num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        else
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        end
        
        % combine and save
        ANI.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
    end
end

% read lactation data from AnimalLactationSummary
ind = find((endsWith(files.Table, 'AnimalLactationSummary') & contains(files.FN,'_HN_') & ismember(files.Farm,farmname)));
aniFiles = files(ind,:);

% combine headers with datafiles 
for i = 1:height(aniFiles)
    d = dir([cd aniFiles.FN{i} '.txt']); 
    
    if d.bytes ~= 0
        datapath = [cd aniFiles.FN{i} '.txt'];
        headerpath = [cd_H aniFiles.FN{i} '_headers.txt'];
        
        if month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) < 10 && day(aniFiles.Date(i)) >= 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) '0' num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        elseif month(aniFiles.Date(i)) >= 10 && day(aniFiles.Date(i)) < 10
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0' num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) '0'  num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        else
            C = [aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i)))];
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' aniFiles.Farm{i} '_' num2str(year(aniFiles.Date(i))) num2str(month(aniFiles.Date(i))) num2str(day(aniFiles.Date(i))) '_' aniFiles.Table{i} '.txt'];
        end
        
        % combine and save
        LAC.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
    end
end



clear cd cd_H d C Farms ind i selFiles selTables savepath headerpath datapath date ans


%% merge ANI with AHD and HN data

% merge HN datasets & select variables
varsBMD = {'HNBiometricMeasurement','BiometricType','RawLevel','SmoothedLevel'};
varsBMM = {'OID','HNDiagnoseObject'};
varsDIAG = {'OID','HNBiometricMeasurement','DateAndTime','DaysSincePreviousMastitisAlarm','DiagnoseType','Risk','Reliability'};
varsHEAT = {'HNBiometricMeasurement','TimeLowProg','InseminationTime','Likelihood'};

% fieldnames 
fieldnamesHN = fieldnames(HNBMM);

% combine and select
for i = 1:length(fieldnamesHN)
    % find indices
    varindexBMD = find(contains(HNBMD.(fieldnamesHN{i}).Properties.VariableNames,varsBMD));
    varindexBMM = find(contains(HNBMM.(fieldnamesHN{i}).Properties.VariableNames,varsBMM));
    varindexDIAG = find(contains(HNDiag.(fieldnamesHN{i}).Properties.VariableNames,varsDIAG));
    varindexHEAT = find(contains(HNHeat.(fieldnamesHN{i}).Properties.VariableNames,varsHEAT));
    
    % select and merge
    HN.(fieldnamesHN{i}) = outerjoin(HNBMD.(fieldnamesHN{i})(:,varindexBMD),HNBMM.(fieldnamesHN{i})(:,varindexBMM),'Leftkeys','HNBiometricMeasurement','RightKeys','OID','MergeKeys',1);
    HN.(fieldnamesHN{i}).Properties.VariableNames = {'OIDBMM','TypeMeas','Raw','Smooth','OIDDiag'};
    HN.(fieldnamesHN{i}) = outerjoin(HN.(fieldnamesHN{i}),HNHeat.(fieldnamesHN{i})(:,varindexHEAT),'LeftKeys','OIDBMM','RightKeys','HNBiometricMeasurement','MergeKeys',1);
    HN.(fieldnamesHN{i}).Properties.VariableNames = {'OIDBMM','TypeMeas','Raw','Smooth','OIDDiag','TimeLowP4','Ins','Likelihood'};

    
    % here also merging with diagnosis is possible, but I chose not to
    % currently implement that
    
end


% combine information of AHD/ANI with HN
varsAHD = {'OID','BasicAnimal','DateAndTime'};

% combine and select
for i = 1:length(fieldnamesHN)
    varindexAHD = find(contains(AHD.(fieldnamesHN{i}).Properties.VariableNames,varsAHD));
    HN.(fieldnamesHN{i}) = innerjoin(AHD.(fieldnamesHN{i})(:,varindexAHD),HN.(fieldnamesHN{i}),'LeftKeys','OID','RightKeys','OIDBMM');
    HN.(fieldnamesHN{i}) = removevars(HN.(fieldnamesHN{i}),{'OID','OIDDiag'});
    
    try
        varsANI = {'ReferenceId','Number','Name','OffRegNumber','BirthDate'};
        varindexANI = find(startsWith(ANI.(fieldnamesHN{i}).Properties.VariableNames,varsANI));
        HN.(fieldnamesHN{i}) = innerjoin(ANI.(fieldnamesHN{i})(:,varindexANI),HN.(fieldnamesHN{i}),'LeftKeys','ReferenceId','RightKeys','BasicAnimal');
    catch
        try
            varsANI = {'BasicAnimal','Number','Name','OffRegNumber','BirthDate'};
            varindexANI = find(startsWith(ANI.(fieldnamesHN{i}).Properties.VariableNames,varsANI));
            HN.(fieldnamesHN{i}) = innerjoin(ANI.(fieldnamesHN{i})(:,varindexANI),HN.(fieldnamesHN{i}),'LeftKeys','BasicAnimal','RightKeys','BasicAnimal');
        catch
            varsANI = {'OID','Number','OffRegNumber','BirthDate'};
            varindexANI = find(startsWith(ANI.(fieldnamesHN{i}).Properties.VariableNames,varsANI));
            HN.(fieldnamesHN{i}) = innerjoin(ANI.(fieldnamesHN{i})(:,varindexANI),HN.(fieldnamesHN{i}),'LeftKeys','OID','RightKeys','BasicAnimal');
        end
    end
    HN.(fieldnamesHN{i}).Properties.VariableNames{1} = 'CowID';
end


%% add lactation info startdate
varsLAC = {'Animal','LactationNumber','StartDate'};   % animal corresponds to cowID

% combine and select
for i = 1:length(fieldnamesHN)
    varindexLAC = find(contains(LAC.(fieldnamesHN{i}).Properties.VariableNames,varsLAC));
    
    LAC.(fieldnamesHN{i}) = sortrows(LAC.(fieldnamesHN{i})(:,varindexLAC),1:3);
    
    for j = 1:height(HN.(fieldnamesHN{i}))
        ind = find(LAC.(fieldnamesHN{i}).Animal == HN.(fieldnamesHN{i}).CowID(j) & ...
                   datenum(LAC.(fieldnamesHN{i}).StartDate) < ...
                   datenum(HN.(fieldnamesHN{i}).DateAndTime(j)),...
                   1,'last');
        if ~isempty(ind)
            HN.(fieldnamesHN{i}).Calving(j) = LAC.(fieldnamesHN{i}).StartDate(ind);
            HN.(fieldnamesHN{i}).DIM(j) = datenum(HN.(fieldnamesHN{i}).DateAndTime(j))-...
                datenum(LAC.(fieldnamesHN{i}).StartDate(ind));
            HN.(fieldnamesHN{i}).Lac(j) = LAC.(fieldnamesHN{i}).LactationNumber(ind);

        end
    end
end

for i = 1:length(fieldnamesHN)
    if size(HN.(fieldnamesHN{i}),2) == 12
        for j = 1:height(HN.(fieldnamesHN{i}))
            ind = find(LAC.(fieldnamesHN{i}).Animal == HN.(fieldnamesHN{i}).ReferenceId(j) & ...
                       datenum(LAC.(fieldnamesHN{i}).StartDate) < ...
                       datenum(HN.(fieldnamesHN{i}).DateAndTime(j)),...
                       1,'last');
            if ~isempty(ind)
                HN.(fieldnamesHN{i}).Calving(j) = LAC.(fieldnamesHN{i}).StartDate(ind);
                HN.(fieldnamesHN{i}).DIM(j) = datenum(HN.(fieldnamesHN{i}).DateAndTime(j))-...
                    datenum(LAC.(fieldnamesHN{i}).StartDate(ind));
                HN.(fieldnamesHN{i}).Lac(j) = LAC.(fieldnamesHN{i}).LactationNumber(ind);
            end
        end
        try
            HN.(fieldnamesHN{i}) = removevars(HN.(fieldnamesHN{i}),'ReferenceId');
        catch
            % nothing
        end
    end
end

% delete 'Name' and rename
% ind = find(


%% combine different files of the same farm


% HN
for i = 1:length(fieldnamesHN)
    numLoc = regexp(fieldnamesHN(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    numLoc = numLoc{:};
    
    test = fieldnamesHN{i};
    allFarms{i} = test(1:numLoc-1);
end

farms = unique(allFarms);
for i = 1:length(unique(allFarms))
    ind = find(contains(allFarms,farms{i}));
    HNfarm.(farms{i}) = HN.(fieldnamesHN{ind(1)});
    c = 0;
    if length(ind)>1
        for j = 2:length(ind)
            try
                HNfarm.(farms{i}) = vertcat(HNfarm.(farms{i}),HN.(fieldnamesHN{ind(j)}));
            catch
                HN.(fieldnamesHN{ind(j)}) = removevars(HN.(fieldnamesHN{ind(j)}),'Name');
                HN.(fieldnamesHN{ind(j)}).Properties.VariableNames{1} = 'Number';
                HNfarm.(farms{i}) = removevars(HNfarm.(farms{i}),'CowID');
                HNfarm.(farms{i}) = vertcat(HNfarm.(farms{i}),HN.(fieldnamesHN{ind(j)}));
                c = 1;
            end
        end
    end
    if c == 1
        [~,ind] = unique(HNfarm.(farms{i})(:,[1 6 7]),'rows');
    else
        [~,ind] = unique(HNfarm.(farms{i})(:,[1 6 7 8]),'rows');
    end
    HNfarm.(farms{i}) = HNfarm.(farms{i})(ind,:);
    HNfarm.(farms{i}) = sortrows(HNfarm.(farms{i}),{'Number','TypeMeas','DateAndTime'});
end






%% writetable HBH
% writetable(HNfarm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen.xlsx','Sheet','HN')

% select and save data
HNselect = HNfarm.Sanders;%(HNfarm.Sanders.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Sanders.xlsx','Sheet','allHN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Sanders_allHN.txt')

% select and save data
HNselect = HNfarm.Geysen;%(HNfarm.Geysen.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Geysen.xlsx','Sheet','allHN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Geysen.txt')

% select and save data
HNselect = HNfarm.Vandenmeijdenberg;%(HNfarm.Vandenmeijdenberg.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Vandenmeijdenberg.xlsx','Sheet','allHN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Vandenmeijdenberg.txt')

% select and save data
HNselect = HNfarm.Leenaerts;%(HNfarm.Leenaerts.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Leenaerts.xlsx','Sheet','allHN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Leenaerts.txt')

HNselect = HNfarm.Hooibeekhoeve;%(HNfarm.Hooibeekhoeve.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Hooibeekhoeve.xlsx','Sheet','allHN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\P4_Hooibeekhoeve.txt')



% select and save data for STIJN HEIRBAUT
HNselect = HNfarm.Geysen;%(HNfarm.Geysen.TypeMeas == 2,:);
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.xlsx','Sheet','HN')
writetable(HNselect,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.txt')

