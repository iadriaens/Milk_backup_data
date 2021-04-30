%% S3_activity

clear variables
close all
clc


%% STEP 0: Store and collect file data

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT_Lelytxt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT_Lelyhead\';   % all header files

% define filenames manually
FNfiles = ls([cd '*Persey' '*.txt']);        % this is the list with files in the folder where I saved the MPR results of MCC

% directory of txt files with merged data
savedir_add = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\';


files = array2table((1:size(FNfiles,1))','VariableNames',{'No'});
files.Farm(:,:) = repmat({'na'},size(FNfiles,1),1);
files.Date(:,1) = NaT;
files.Table(:,:) = repmat({'na'},size(FNfiles,1),1);
files.FN(:,:) = repmat({'na'},size(FNfiles,1),1);
for i = 1:length(FNfiles(:,1))   % run through all the files in the folder
    numLoc = regexp(FNfiles(i,:),'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    endLoc = regexp(FNfiles(i,:),'.txt');    % this gives the end of the filename
    
    % Store data in 'files'
    files.Farm{i,1} = FNfiles(i,1:numLoc(1)-1);   % FarmName:length(FN(i,1:numLoc(1)-1))}
    files.Date(i,1) = datetime(FNfiles(i,numLoc(1)+1:numLoc(1)+8),'InputFormat','yyyyMMdd','Format','dd/MM/yyyy'); % Date
    files.Table{i,1} = FNfiles(i,numLoc(end)+1:endLoc-1);           % TableName
    files.FN{i,1} = FNfiles(i,1:endLoc-1);      % full FileName    
end
files = sortrows(files, {'Farm','Date'});

clear i endLoc numLoc 

% select tables containing treatment / diagnosis data
selTables = {'PrmActivityScr','RemLactation','HemAnimal'};
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
        if contains(selFiles.Table{i},'PrmActivityScr')
            ACT.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'RemLactation')
            LAC.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);   
        elseif contains(selFiles.Table{i},'HemAnimal')
            ANI.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);   
        end
    end
end
clear ind d C i savepath datapath headerpath

%% 
% combine information in the different tables
fieldNamesACT = fieldnames(ACT);
varsACT = {'AscId','AscAniId','AscCellTime','AscActivity','AscTotalRuminationTime','AscRuminationMinutes'};
varsANI = {'AniId','AniName','AniLifeNumber','AniBirthday'};

for i = 1:length(fieldNamesACT)
    
    % find indices
    varindxACT = find(contains(ACT.(fieldNamesACT{i}).Properties.VariableNames,varsACT));
    varindxANI = find(contains(ANI.(fieldNamesACT{i}).Properties.VariableNames,varsANI));
%     varindxLAC = find(contains(LAC.(fieldNamesACT{i}).Properties.VariableNames,varsLAC));
    
    ACTANI.(fieldNamesACT{i}) = innerjoin(ACT.(fieldNamesACT{i})(:,varindxACT),ANI.(fieldNamesACT{i})(:,varindxANI),'LeftKeys',{'AscAniId'},'RightKeys',{'AniId'});
end


ACTANI.(fieldNamesACT{i}) = innerjoin(ACT.(fieldNamesACT{i})(:,varindxACT),ANI.(fieldNamesACT{i})(:,varindxANI),'LeftKeys',{'AscAniId'},'RightKeys',{'AniId'});
    

% d
tic
for i = 1:length(fieldNamesACT)
    disp(num2str(i))
    data = ACTANI.(fieldNamesACT{i});
    data.idx = floor(datenum(data.AscCellTime));
    cowdays = unique(data(:,[2 13]),'rows');
    cowdays.subs = (1:size(cowdays,1))';
    data = innerjoin(data,cowdays);
    try 
        newdata = accumarray(data.subs,data.AscActivity,[],@nansum,NaN);
        newdata(:,2) = accumarray(data.subs,data.AscActivity,[],@nanmean,NaN);
    catch
        newdata = nan(height(cowdays),2);
    end
    try
        newdata2 = accumarray(data.subs,data.AscRuminationMinutes,[],@nansum,NaN);
        newdata2(:,2) = accumarray(data.subs,data.AscRuminationMinutes,[],@nanmean,NaN);
    catch
        newdata2 = nan(height(cowdays),2);
    end
    
    ACT_ac.(fieldNamesACT{i}) = cowdays;
    ACT_ac.(fieldNamesACT{i}).Date = datetime(ACT_ac.(fieldNamesACT{i}).idx,'ConvertFrom','datenum');
    ACT_ac.(fieldNamesACT{i}).TotalActivity = newdata(:,1);
    ACT_ac.(fieldNamesACT{i}).AverageActivity = newdata(:,2);
    ACT_ac.(fieldNamesACT{i}).TotalRumination = newdata2(:,1);
    ACT_ac.(fieldNamesACT{i}).AverageRumination = newdata2(:,2);
    
    ACT_ac.(fieldNamesACT{i}) = removevars(ACT_ac.(fieldNamesACT{i}),{'idx', 'subs'});
    clear newdata newdata2 data cowdays

end
toc  % 387.4s

%% add lactation number
tic
varsLAC = {'LacAniId','LacNumber','LacCalvingDate'};
for i = 1:length(fieldNamesACT)
    varindxLAC = find(contains(LAC.(fieldNamesACT{i}).Properties.VariableNames,varsLAC));
    
    disp(fieldNamesACT{i})
    lac = LAC.(fieldNamesACT{i})(LAC.(fieldNamesACT{i}).LacNumber ~= 0,varindxLAC);
    data = ACT_ac.(fieldNamesACT{i});
    test = outerjoin(lac,data,'LeftKeys',{'LacAniId'},'RightKeys',{'AscAniId'},'MergeKeys',1);
    test.dif =  datenum(test.Date)-datenum(test.LacCalvingDate);
    test.Properties.VariableNames{1} = 'AscAniId';
    test = test(test.dif>=0 & ~isnan(test.AscAniId),:);
    test = sortrows(test,{'AscAniId','Date'});
    [~,idx] = unique(test(:,[1 4]),'rows');
    
    Activity.(fieldNamesACT{i}) = test(idx,[1 2 3 4 5 6 7 8]);
    Activity.(fieldNamesACT{i}).Properties.VariableNames{1}= 'AniId';
    Activity.(fieldNamesACT{i}).Properties.VariableNames{2}= 'Lac';
    Activity.(fieldNamesACT{i}).Properties.VariableNames{3}= 'Calving';
end
toc


%% write tables

% save statements
fields = fieldnames(Activity);
savedir = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\';
for i = 1:length(fields)
    mindate = datestr(min(Activity.(fields{i}).Date),'yyyymmdd');
    maxdate = datestr(max(Activity.(fields{i}).Date),'yyyymmdd');
    locat = regexp(fields{i},'_');
    farmname = fields{i}(1:locat-1);
    
    disp(farmname)
    
    writetable(Activity.(fields{i}),[savedir 'Activity_' farmname '_' mindate '_' maxdate '.txt'],'Delimiter',';');
end
