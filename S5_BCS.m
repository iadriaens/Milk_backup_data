%% S5_BCS

clear variables
close all
clc

%% Set directory and detect tables

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3head\';   % all header files

% find all the files in the folder
FNfiles = ls([cd 'Geysen' '*']);        % this is the list with files in the folder where I saved the MPR results of MCC
ind = []; for i  = 1:length(FNfiles); if isempty(find(contains(FNfiles(i,:),'.txt'))) == 1; ind = [ind; i]; end; end % find no filenames
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
clear i endLoc numLoc 

% select tables containing treatment / diagnosis data
selTables = {'BcsCameraRawData','BcsDailyData','EventBCS'};
ind = ismember(files.Table, selTables);
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
        if contains(selFiles.Table{i},'BcsCameraRawData')
            RAW.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'BcsDailyData')
            BCS.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        else 
            BCSEvent.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end

% add date and time
farms = fieldnames(RAW);
for i = 1:length(fieldnames(RAW))
    RAW.(farms{i}).Date(:,1) =  datetime(datenum(RAW.(farms{i}).DateAndTime),'ConvertFrom','datenum','Format','dd/MM/yyyy HH:mm:ss');
end

% read animal information
ind = find(ismember(files.Table, 'HistoryAnimal') & contains(files.FN,'_BCS_'));
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

%% merge ANI with BCS and RAW


% combine HA information with BCS
fieldNamesBCS = fieldnames(BCS);
varsHA = {'OID','Number','BirthDate','ExitDate','OfficialRegNo'};
varsBCS = {'Animal','Date','BcsValue'};
for i = 1:length(fieldNamesBCS)
    % find indices
    varindxHA = find(contains(ANI.(fieldNamesBCS{i}).Properties.VariableNames,varsHA) & ~contains(ANI.(fieldNamesBCS{i}).Properties.VariableNames,'LactationNumber'));
    varindxBCS = find(contains(BCS.(fieldNamesBCS{i}).Properties.VariableNames,varsBCS));
       
    % combine tables
    BCSall.(fieldNamesBCS{i}) = sortrows(innerjoin(BCS.(fieldNamesBCS{i})(:,varindxBCS),ANI.(fieldNamesBCS{i})(:,varindxHA),'LeftKeys',{'Animal'},'RightKeys',{'OID'}),[1 2]);
end

% combine HA information with RAW
fieldNamesRAW = fieldnames(RAW);
varsHA = {'OID','Number','BirthDate','ExitDate','OfficialRegNo'};
varsRAW = {'Animal','Date','BcsRawValue','Quality','BcsCamera'};
for i = 1:length(fieldNamesRAW)
    % find indices
    varindxHA = find(contains(ANI.(fieldNamesRAW{i}).Properties.VariableNames,varsHA) & ~contains(ANI.(fieldNamesRAW{i}).Properties.VariableNames,'LactationNumber'));
    varindxRAW = find(contains(RAW.(fieldNamesRAW{i}).Properties.VariableNames,varsRAW)& ~contains(RAW.(fieldNamesRAW{i}).Properties.VariableNames,'DateAndTime'));
       
    % combine tables
    BCSraw.(fieldNamesRAW{i}) = sortrows(innerjoin(RAW.(fieldNamesRAW{i})(:,varindxRAW),ANI.(fieldNamesRAW{i})(:,varindxHA),'LeftKeys',{'Animal'},'RightKeys',{'OID'}),[1 5]);
end

%% combine different files of the same farm

% BCS
for i = 1:length(fieldNamesBCS)
    numLoc = regexp(fieldNamesBCS(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    numLoc = numLoc{:};
    
    test = fieldNamesBCS{i};
    allFarms{i} = test(1:numLoc-1);
end

farms = unique(allFarms);
for i = 1:length(unique(allFarms))
    ind = find(contains(allFarms,farms{i}));
    BCSfarm.(farms{i}) = BCSall.(fieldNamesBCS{ind(1)});
    if length(ind)>1
        for j = 2:length(ind)
            BCSfarm.(farms{i}) = vertcat(BCSfarm.(farms{i}),BCSall.(fieldNamesBCS{ind(j)}));
        end
    end
    [~,ind] = unique(BCSfarm.(farms{i})(:,[1 2 3 4 6]),'rows');
    BCSfarm.(farms{i}) = BCSfarm.(farms{i})(ind,:);
end

% RAW
clear allFarms
for i = 1:length(fieldNamesRAW)
    numLoc = regexp(fieldNamesRAW(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    numLoc = numLoc{:};
    
    test = fieldNamesRAW{i};
    allFarms{i} = test(1:numLoc-1);
end

farms = unique(allFarms);
for i = 1:length(unique(allFarms))
    ind = find(contains(allFarms,farms{i}));
    BCSrawFarm.(farms{i}) = BCSraw.(fieldNamesRAW{ind(1)});
    if length(ind)>1
        for j = 2:length(ind)
            BCSrawFarm.(farms{i}) = vertcat(BCSrawFarm.(farms{i}),BCSraw.(fieldNamesRAW{ind(j)}));
        end
    end
    [~,ind] = unique(BCSrawFarm.(farms{i})(:,[1 2 3 4 5 6]),'rows');
    BCSrawFarm.(farms{i}) = BCSrawFarm.(farms{i})(ind,:);
end

clear allFarms aniFiles C cd cd_H d datapath headerpath FNfiles i ind j numLoc test varindexHA varindexRAW varindexBCS varsBCS varsHA varsRAW savepath farms Farms selFiles selTables varindxBCS varindxHA varindxRAW

% delete zeros




%% writetable HBH
writetable(BCSrawFarm.Hooibeekhoeve,'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\BCS_HBH.xlsx','Sheet','BCSraw')
writetable(BCSfarm.Hooibeekhoeve,'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\BCS_HBH.xlsx','Sheet','BCSdaily')

%% writetable gEYSEN
writetable(BCSfarm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.xlsx','Sheet','BCS')
writetable(BCSfarm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\BCS_Geysen_newdata.txt')


