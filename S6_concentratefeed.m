%% S6_FeedIntake
% concentrate intake

clear variables
close all
clc


%% STEP 1: set directory and combine headers

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3head\';   % all header files

% find all the files in the folder
FNfiles = ls(cd);        % this is the list with files in the folder where I saved the MPR results of MCC
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
clear i endLoc numLoc  FNfiles

% select tables containing treatment / diagnosis data
selTables = {'AnimalFeed','AnimalFeedConsumed'};
ind = find(ismember(files.Table, selTables) & ismember(files.Farm,'Geysen'));
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
        if contains(selFiles.Table{i},'AnimalFeedConsumed')
            AFC.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        else % AnimalFeed
            AF.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end

% read animaldata from HistoryAnimal
ind = find((endsWith(files.Table, 'HistoryAnimal') & contains(files.FN,'_HN_') & ismember(files.Farm,'Geysen')));
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

clear aniFiles C cd cd_H datapath Farms headerpath savepath i ind selFiles selTables d ans

%% combine daily intakes from AFC using AnimalDaily

% daily intakes
fieldnamesAFC = fieldnames(AFC);

% daily intake
for i = 1:length(fieldnamesAFC)
    
    [a,~,c] = unique(AFC.(fieldnamesAFC{i}){:,5}); 
    DAYIN.(fieldnamesAFC{i}) = [a, accumarray(c,AFC.(fieldnamesAFC{i}).Consumed)];
%     dailyIntake2.(fieldnamesAFC{i}) = innerjoin(array2table(dailyIntake2.(fieldnamesAFC{i}),'VariableNames',{'AnimalDaily','DailyIntake'}),unique(AFC.(fieldnamesAFC{i})(:,[4 5]),'rows'));
    AFC.(fieldnamesAFC{i}).NumDate = floor(datenum(AFC.(fieldnamesAFC{i}).DateAndTime));
    AFC.(fieldnamesAFC{i}).DayDate = datetime(floor(datenum(AFC.(fieldnamesAFC{i}).DateAndTime)),'ConvertFrom','datenum');
    DAYIN.(fieldnamesAFC{i}) = innerjoin(array2table(DAYIN.(fieldnamesAFC{i}),'VariableNames',{'AnimalDaily','DailyIntake'}),unique(AFC.(fieldnamesAFC{i})(:,[4 5 13]),'rows'));
end

% combine with ANI
varsAFC = {'BasicAnimal','AnimalDaily','DateAndTime','Feedstuff','Consumed'};
for i = 1:length(fieldnamesAFC)
    try
        varsANI = {'ReferenceId','Number','Name','OffRegNumber','BirthDate'};
        varindexANI = find(contains(ANI.(fieldnamesAFC{i}).Properties.VariableNames,varsANI));
        DAYINall.(fieldnamesAFC{i}) = innerjoin(ANI.(fieldnamesAFC{i})(:,varsANI),DAYIN.(fieldnamesAFC{i}),'LeftKeys','ReferenceId','RightKeys','BasicAnimal');
        
        varindexAFC = find(contains(AFC.(fieldnamesAFC{i}).Properties.VariableNames,varsAFC));
        AFCall.(fieldnamesAFC{i}) = innerjoin(ANI.(fieldnamesAFC{i})(:,varsANI),AFC.(fieldnamesAFC{i})(:,varindexAFC),'LeftKeys','ReferenceId','RightKeys','BasicAnimal');
    catch
        varsANI = {'BasicAnimal','Number','Name','OffRegNumber','BirthDate'};
        varindexANI = find(contains(ANI.(fieldnamesAFC{i}).Properties.VariableNames,varsANI));
        DAYINall.(fieldnamesAFC{i}) = innerjoin(ANI.(fieldnamesAFC{i})(:,varsANI),DAYIN.(fieldnamesAFC{i}),'LeftKeys','BasicAnimal','RightKeys','BasicAnimal');
        
        varindexAFC = find(contains(AFC.(fieldnamesAFC{i}).Properties.VariableNames,varsAFC));
        AFCall.(fieldnamesAFC{i}) = innerjoin(ANI.(fieldnamesAFC{i})(:,varsANI),AFC.(fieldnamesAFC{i})(:,varindexAFC),'LeftKeys','BasicAnimal','RightKeys','BasicAnimal');
    end
end

%% combine tables of same farm into one
% Feed
for i = 1:length(fieldnamesAFC)
    numLoc = regexp(fieldnamesAFC(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    numLoc = numLoc{:};
    
    test = fieldnamesAFC{i};
    allFarms{i} = test(1:numLoc-1);
end

farms = unique(allFarms);
for i = 1:length(unique(allFarms))
    ind = find(contains(allFarms,farms{i}));
    % AFC
    FEEDfarm.(farms{i}) = AFCall.(fieldnamesAFC{ind(1)});
    if length(ind)>1
        for j = 2:length(ind)
            FEEDfarm.(farms{i}) = vertcat(FEEDfarm.(farms{i}),AFCall.(fieldnamesAFC{ind(j)}));
        end
    end
    [~,ind] = unique(FEEDfarm.(farms{i})(:,[1 6 8 9]),'rows');
    FEEDfarm.(farms{i}) = sortrows(FEEDfarm.(farms{i})(ind,:),[2 6 8]);
    
    % daily AFC
    ind = find(contains(allFarms,farms{i}));
    FEEDdaily.(farms{i}) = DAYINall.(fieldnamesAFC{ind(1)});
    if length(ind)>1
        for j = 2:length(ind)
            FEEDdaily.(farms{i}) = vertcat(FEEDdaily.(farms{i}),DAYINall.(fieldnamesAFC{ind(j)}));
        end
    end
    [~,ind] = unique(FEEDdaily.(farms{i})(:,[1 6]),'rows');
    FEEDdaily.(farms{i}) = FEEDdaily.(farms{i})(ind,:);
end

%% writetables gEYSEN
writetable(FEEDdaily.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.xlsx','Sheet','FEED')
