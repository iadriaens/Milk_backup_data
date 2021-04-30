%% S7_milkyield

clear variables
close all
clc
% 
%% STEP 0: Store and collect file data

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3head\';   % all header files

% define filenames manually
FNfiles = ls([cd 'Geysen_*']);  %ls([cd]);%      % this is the list with files in the folder where I saved the MPR results of MCC
ind = []; for i  = 1:length(FNfiles); if isempty(find(contains(FNfiles(i,:),'.txt'))) == 1; ind = [ind; i]; end; end % find no filenames
FNfiles(ind,:) = []; clear ind     % delete


% directory of txt files with merged data
savedir_day = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLDAY\';
savedir_milk = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLMILK\';

% find all farmnames = for all files everything before '_'
files = array2table((1:length(FNfiles))','VariableNames',{'No'});
files.Farm(:,:) = repmat({'na'},length(FNfiles),1);
files.Date(:,1) = NaT;
files.Version(:,1) = repmat(0,length(FNfiles),1);
files.Table(:,:) = repmat({'na'},length(FNfiles),1);
files.FN(:,:) = repmat({'na'},length(FNfiles),1);
for i = 1:length(FNfiles(:,1))   % run through all the files that have to be added
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

files = files(files.Version ~= 0,:);


% clear variables
clear i endLoc numLoc 


%% STEP 1 : load, vertically merge and sort DAILY data of each farm
% unique farms in the dataset
Farms = unique(files.Farm);  % all unique farms in the dataset
allVarNames = {'OfficialRegNo','BA','Number','RefID','Name','BDate','Calving','Lac','Date','DIM','TDMY','A7DY','Dur','Milkings','Kickoffs','Incompletes'}; % all varNames

for i = 1:length(Farms)
    % find unique dates of the back up files for that farm
    bakdates = sortrows(unique(files.Date(contains(files.Farm,Farms{i})==1)),'descend');  % all unique back up dates
        
    % Show current farm
    disp(['      Current farm = ' Farms{i}])

    % initialize V
    V = 0; % never version 0 so last date will always be run
            
    % find the filenames
    for j = 1:length(bakdates) % for all the back ups of that farm - run from last to first back-up file
%         if files.Version(find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)),1,'first')) ~= V  % if it is a different version, run the loop
            V = files.Version(find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)),1,'first'));  % version
            D = ['BU' datestr(bakdates(j),'yyyymmdd') '_V' num2str(V*10)];   % prepare structure - names = dates
            
            % show current backup
            disp(['      Backup date = '  datestr(bakdates(j))])

            if V < 4     % determine version, if 3.7 < 4
                % FN_BA,FN_ALS,FN_AHD,FN_DM
                cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
                FN_BA = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'BasicAnimal')==1,1,'first')};
                FN_ALS = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'AnimalLactationSummary')==1,1,'first')};
                FN_AHD = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'AnimalHistoricalData')==1,1,'first')};
                FN_DM = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'DailyMilk')==1,1,'first')};

                % define function to use based on version
                fun = str2func(['DLV_dailydata_v' num2str(V*10)]);     % function to evaluate based on version
                DAY.(Farms{i}).(D) = fun(cd,FN_BA,FN_ALS,FN_AHD,FN_DM,cd_H);
            else
                cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
                FN_HA = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'HistoryAnimal')==1,1,'first')};
                FN_HALI = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'HistoryAnimalLactationInfo')==1,1,'first')};
                FN_HADD = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'HistoryAnimalDailyData')==1,1,'first')};

                % define function to use based on version
                fun = str2func(['DLV_dailydata_v' num2str(V*10)]);     % function to evaluate based on version
                DAY.(Farms{i}).(D) = fun(cd,FN_HA,FN_HALI,FN_HADD,cd_H);

            end
%         end
    end
    
    % find unique rows
    fields = sortrows(fieldnames(DAY.(Farms{i})));
    for j = 1:length(fields)
        if size(DAY.(Farms{i}).(fields{j}),2) > 14
            [~,uniRow] = unique(DAY.(Farms{i}).(fields{j})(:,[2 9]),'rows'); % one per date
        else
            [~,uniRow] = unique(DAY.(Farms{i}).(fields{j})(:,[2 8]),'rows');  % one per date v 3.7
        end
        
        DAY.(Farms{i}).(fields{j}) = DAY.(Farms{i}).(fields{j})(uniRow,:);
        
        % add rows that are missing to the tables (~version)
        for k = 1:length(allVarNames)
            if sum(contains(DAY.(Farms{i}).(fields{j}).Properties.VariableNames,allVarNames{k})) == 0
                if contains(allVarNames{k},'Name')
                    DAY.(Farms{i}).(fields{j}) = addvars(DAY.(Farms{i}).(fields{j}),repmat({''},height(DAY.(Farms{i}).(fields{j})),1),'NewVariableNames',allVarNames(k),'Before','BDate');
                else
                    if contains(allVarNames{k},'RefID')
                        DAY.(Farms{i}).(fields{j}) = addvars(DAY.(Farms{i}).(fields{j}),NaN*zeros(height(DAY.(Farms{i}).(fields{j})),1),'NewVariableNames',allVarNames(k),'After','Number');
                    else
                        DAY.(Farms{i}).(fields{j}) = addvars(DAY.(Farms{i}).(fields{j}),NaN*zeros(height(DAY.(Farms{i}).(fields{j})),1),'NewVariableNames',allVarNames(k));
                    end
                end
            end
        end
        
        % check whether there already exists a farmfile in savedir
%         if ~isempty(ls([savedir_day 'DAY_' Farms{i} '*']))
%             fnold = ls([savedir_day 'DAY_' Farms{i} '*']);
%             opts = detectImportOptions([savedir_day fnold]);
%             opts = setvartype(opts,{'OfficialRegNo','Name'},'char');
%             DAYm.(Farms{i}) = readtable([savedir_day fnold],opts);
%             clear fnold
%         end
        
        % merge 
        if j == 1 % & isempty(ls([savedir_day 'DAY_' Farms{i} '*']))
            DAYm.(Farms{i})= DAY.(Farms{i}).(fields{j});
        else
            DAYm.(Farms{i}) = [DAYm.(Farms{i});DAY.(Farms{i}).(fields{j})];
        end
        
        % select unique rows
        [~,ind] = unique(DAYm.(Farms{i})(:,[1 9 11]),'rows'); % BA Date TDMY
        DAYm.(Farms{i}) = DAYm.(Farms{i})(ind,:);
        
    end 
end
clear cd bakdates D fields FN_HA FN_HALI allVarNames FN_HADD fun i j k ind V uniRow opts 

% save statements
fields = fieldnames(DAYm);
savedir_day = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\New_DAY\';
for i = 1:length(fields)
    mindate = datestr(min(DAYm.(fields{i}).Date),'yyyymmdd');
    maxdate = datestr(max(DAYm.(fields{i}).Date),'yyyymmdd');

    writetable(DAYm.(fields{i}),[savedir_day 'DAY_' fields{i} '_' mindate '_' maxdate '.txt'],'Delimiter',';');
    
end

%% STEP 2 : load, vertically merge and sort PER MILKING data of each farm
% unique farms in the dataset
Farms = unique(files.Farm);  % all unique farms in the dataset
% allVarNames = {'OfficialRegNo','BA','Number','RefID','Name','BDate','Calving','Lac','Date','DIM','TDMY','A7DY','Dur','Milkings','Kickoffs','Incompletes'}; % all varNames

for i = 1:length(Farms)
    % find unique dates of the back up files for that farm
    bakdates = sortrows(unique(files.Date(contains(files.Farm,Farms{i})==1)),'ascend');  % all unique back up dates - run in order (no need for descending order)
    % print FarmName 
    Farms{i}
   
    % find the filenames
    for j = 1:length(bakdates) % for all the back ups of that farm - run from first to last back-up file
        % show current backup
        disp(['      Backup date = '  datestr(bakdates(j))])
        
        % detect characteristics of bak file
        V = files.Version(find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)),1,'first'));  % version
        D = ['BU' datestr(bakdates(j),'yyyymmdd') '_V' num2str(V*10)];   % prepare structure - names = dates
        
        if V < 4     % determine version, if 3.7 < 4
            % define files FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_SMY
            cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
            FN_BA = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'BasicAnimal')==1,1,'first')};
            FN_ALS = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'AnimalLactationSummary')==1,1,'first')};
            FN_AHD = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'AnimalHistoricalData')==1,1,'first')};
            FN_SMY = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'SessionMilkYield')==1,1,'first')};
            FN_VMY = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'VoluntarySessionMilkYield')==1,1,'first')};
            
            % define function to use based on version
            fun = str2func(['DLV_milkdata_v' num2str(V*10)]);     % function to evaluate based on version
            MILK.(Farms{i}).(D) = fun(cd,FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_VMY,cd_H);
        else
            % define files FN_BA,FN_ALS,FN_AHD,FN_SMY,FN_SMY
            cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT3txt\';     % all data files in txt format
            FN_BA = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'BasicAnimal')==1,1,'first')};
            FN_ALS = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'AnimalLactationSummary')==1,1,'first')};
            FN_SMY = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'SessionMilkYield')==1,1,'first')};
            FN_VMY = files.FN{find(contains(files.Farm,Farms{i})== 1 & datenum(files.Date) == datenum(bakdates(j)) & contains(files.Table,'VoluntarySessionMilkYield')==1,1,'first')};
            
            % define function to use based on version
            fun = str2func(['DLV_milkdata_v' num2str(V*10)]);     % function to evaluate based on version
            MILK.(Farms{i}).(D) = fun(cd,FN_BA,FN_ALS,FN_SMY,FN_VMY,cd_H);
        end
    end
    
    % find unique rows
    fields = fieldnames(MILK.(Farms{i}));
    for j = 1:length(fields)
      
        % check whether there already exists a farmfile in savedir
        if ~isempty(ls([savedir_milk 'MILK_' Farms{i} '*']))
            fnold = ls([savedir_milk 'MILK_' Farms{i} '*']);
            opts = detectImportOptions([savedir_milk fnold]);
            opts = setvartype(opts,'Name','char');
            MILKm.(Farms{i}) = readtable([savedir_milk fnold],opts);
            clear fnold
        end
        
        % merge 
        if j == 1 & isempty(ls([savedir_milk 'MILK_' Farms{i} '*']))
            MILKm.(Farms{i})= MILK.(Farms{i}).(fields{j});
        else
            MILKm.(Farms{i}) = [MILKm.(Farms{i});MILK.(Farms{i}).(fields{j})];
        end
        
        % select unique rows
        [~,ind] = unique(MILKm.(Farms{i})(:,[1 9 12]),'rows'); % BA Date TMY
        MILKm.(Farms{i}) = MILKm.(Farms{i})(ind,:);
        
    end 
end


% save statements
fields = fieldnames(MILKm);
for i = 1:length(fields)
    mindate = datestr(min(MILKm.(fields{i}).EndTime),'yyyymmdd');
    maxdate = datestr(max(MILKm.(fields{i}).EndTime),'yyyymmdd');
    writetable(MILKm.(fields{i}),[savedir_milk 'MILK_' fields{i} '_' mindate '_' maxdate '.txt'],'Delimiter',';');
end




%% writetable
% writetable(DAYm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Geysen.xlsx','Sheet','DAY')
% writetable(MILKm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Geysen.xlsx','Sheet','MILK')

% writetable(DAYm.Hooibeekhoeve(datenum(DAYm.Hooibeekhoeve.Date) >= datenum(2014,03,09),:),'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Hooibeekhoeve.xlsx','Sheet','DAY')
% writetable(MILKm.Hooibeekhoeve,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Hooibeekhoeve.xlsx','Sheet','MILK')

% writetable(DAYm.Sanders,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Sanders.xlsx','Sheet','DAY')
% writetable(MILKm.Sanders,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Sanders.xlsx','Sheet','MILK')

% writetable(DAYm.Leenaerts,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Leenaerts.xlsx','Sheet','DAY')
% writetable(MILKm.Leenaerts,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Leenaerts.xlsx','Sheet','MILK')

% writetable(DAYm.Vandenmeijdenberg,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Vandenmeijdenberg.xlsx','Sheet','DAY')
% writetable(MILKm.Vandenmeijdenberg,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Wei Xu\MILK_Vandenmeijdenberg.xlsx','Sheet','MILK')

writetable(DAYm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.xlsx','Sheet','DAY')
writetable(MILKm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\HN_Geysen_newdata.xlsx','Sheet','MILK')
writetable(DAYm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\DAY_Geysen_20181127_20210315.txt')
writetable(MILKm.Geysen,'C:\Users\u0084712\Documents\Box Sync\Documents\Add_Documents\Werk voor anderen\Stijn Heirbout\MILK_Geysen_20181127_20210315.txt')