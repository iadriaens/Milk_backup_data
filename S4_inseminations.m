%% S4_insemination: insemination and fertility data

clear variables
close all
clc
datetime.setDefaultFormats('defaultdate','dd-MM-yyyy HH:mm:ss');

%% STEP D0: detect data files in folder DELAVAL

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
clear i endLoc numLoc 

% select tables containing treatment / diagnosis data
selTables = {'EventInsemination','HistoryAnimalReproductionInfo'};
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
        if contains(selFiles.Table{i},'EventInsemination')
            EI.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HistoryAnimalReproductionInfo')
            HARI.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end
clear ind d C i savepath datapath headerpath


% BA & HA
for i = 1:height(files)
    if contains(files.Table{i},'HistoryAnimal') && ~contains(files.Table{i},'HistoryAnimalD') && ~contains(files.Table{i},'HistoryAnimalL') ...
                && ~contains(files.Table{i},'HistoryAnimalR') && ~contains(files.Table{i},'HistoryAnimalT') %&& sum(contains(fieldnames(EI),files.Farm{i}))>=1
        datapath = [cd files.FN{i} '.txt'];
        headerpath = [cd_H files.FN{i} '_headers.txt'];
                
        if month(files.Date(i)) < 10 && day(files.Date(i)) < 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
        elseif month(files.Date(i)) < 10 && day(files.Date(i)) >= 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
        elseif month(files.Date(i)) >= 10 && day(files.Date(i)) < 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
        else
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
        end
        
        HA.(C) = F1_CombineDataHeaders(datapath,headerpath);
        
    else
        if contains(files.Table{i},'BasicAnimal') && sum(contains(fieldnames(EI),files.Farm{i}))>=1
            datapath = [cd files.FN{i} '.txt'];
            headerpath = [cd_H files.FN{i} '_headers.txt'];

            if month(files.Date(i)) < 10 && day(files.Date(i)) < 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
            elseif month(files.Date(i)) < 10 && day(files.Date(i)) >= 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
            elseif month(files.Date(i)) >= 10 && day(files.Date(i)) < 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
            else
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
            end

            BA.(C) = F1_CombineDataHeaders(datapath,headerpath);
        end
    end
end


% Load HADD and AHD
for i = 1:height(files)
    if contains(files.Table{i},'HistoryAnimalDailyData') %&& sum(contains(fieldnames(EI),files.Farm{i}))>=1
        datapath = [cd files.FN{i} '.txt'];
        headerpath = [cd_H files.FN{i} '_headers.txt'];
                
        if month(files.Date(i)) < 10 && day(files.Date(i)) < 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
        elseif month(files.Date(i)) < 10 && day(files.Date(i)) >= 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
        elseif month(files.Date(i)) >= 10 && day(files.Date(i)) < 10
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
        else
            C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
        end
        
        HADD.(C) = F1_CombineDataHeaders(datapath,headerpath);
        
    else
        if contains(files.Table{i},'AnimalHistoricalData') % && sum(contains(fieldnames(EI),files.Farm{i}))>=1
            datapath = [cd files.FN{i} '.txt'];
            headerpath = [cd_H files.FN{i} '_headers.txt'];

            if month(files.Date(i)) < 10 && day(files.Date(i)) < 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
            elseif month(files.Date(i)) < 10 && day(files.Date(i)) >= 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) '0' num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
            elseif month(files.Date(i)) >= 10 && day(files.Date(i)) < 10
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) '0' num2str(day(files.Date(i)))];
            else
                C = [files.Farm{i} '_' num2str(year(files.Date(i))) num2str(month(files.Date(i))) num2str(day(files.Date(i)))];
            end

            AHD.(C) = F1_CombineDataHeaders(datapath,headerpath);
        end
    end
end
clear i C selFiles selTables

%%

% combine information in the different tables
fieldNamesHARI = fieldnames(HARI);
fieldNamesEI = fieldnames(EI);
varsBA = {'OID','Number','Name','BirthDate','ExitDate'};
varsHA = {'OID','Number','Name','BirthDate','ExitDate'};
varsHARI = {'OID','ActualInseminationNumber','Sire','PregCheckDay','CalvingDay','HeatSignDay','InsemDay'};
varsEI = {'OID','MotherID','InseminationNo'};
varsAHD = {'OID','BasicAnimal','DateAndTime'};
varsHADD = {'OID','BasicAnimal','DayDate','Animal','LactationNumber'};

for i = 1:length(fieldNamesEI)
    
    try
        % find indices
        varindxEI = find(contains(EI.(fieldNamesEI{i}).Properties.VariableNames,varsEI));

        varindxAHD = find(contains(AHD.(fieldNamesEI{i}).Properties.VariableNames,varsAHD));
        EI2.(fieldNamesEI{i}) = innerjoin(EI.(fieldNamesEI{i})(:,varindxEI),AHD.(fieldNamesEI{i})(:,varindxAHD),'LeftKeys',{'OID'},'RightKeys',{'OID'});
        
        if sum(contains(fieldnames(BA),fieldNamesEI{i}))>0
            varindxBA = find(contains(BA.(fieldNamesEI{i}).Properties.VariableNames,varsBA));
            % combine tables
            EI3.(fieldNamesEI{i}) = innerjoin(EI2.(fieldNamesEI{i}),BA.(fieldNamesEI{i})(:,varindxBA),'LeftKeys',{'BasicAnimal'},'RightKeys',{'OID'});
            EI3.(fieldNamesEI{i}) = removevars(EI3.(fieldNamesEI{i}),'OID');
            EI3.(fieldNamesEI{i}) = sortrows(EI3.(fieldNamesEI{i}),5);
            EI3.(fieldNamesEI{i}) = movevars(EI3.(fieldNamesEI{i}),[4 5 6 7 8 ],'before','MotherID');
        else
            varindxHA = find(contains(HA.(fieldNamesEI{i}).Properties.VariableNames,varsBA));
            lacindx = find(contains(HA.(fieldNamesEI{i}).Properties.VariableNames,'LactationNumber'));
            if sum(ismember(varindxHA,lacindx)) > 0
                varindxHA(varindxHA == lacindx) = [];
            end
            % combine tables
            EI3.(fieldNamesEI{i}) = innerjoin(EI2.(fieldNamesEI{i}),HA.(fieldNamesEI{i})(:,varindxHA),'LeftKeys',{'BasicAnimal'},'RightKeys',{'OID'});
            EI3.(fieldNamesEI{i}) = removevars(EI3.(fieldNamesEI{i}),'OID');
            EI3.(fieldNamesEI{i}) = sortrows(EI3.(fieldNamesEI{i}),5);
            EI3.(fieldNamesEI{i}) = movevars(EI3.(fieldNamesEI{i}),[4 5 6 7 8 ],'before','MotherID');
        end
    catch
        % do nothing
    end
end

for i = 1:length(fieldNamesHARI)
    try
        % find indices
        varindxHARI = find(contains(HARI.(fieldNamesHARI{i}).Properties.VariableNames,varsHARI));

        varindxHADD = find(contains(HADD.(fieldNamesHARI{i}).Properties.VariableNames,varsHADD));
        HARI2.(fieldNamesHARI{i}) = innerjoin(HARI.(fieldNamesHARI{i})(:,varindxHARI),HADD.(fieldNamesHARI{i})(:,varindxHADD),'LeftKeys',{'OID'},'RightKeys',{'OID'});
        
        if sum(contains(fieldnames(HA),fieldNamesHARI{i}))>0
            varindxHA = find(contains(HA.(fieldNamesHARI{i}).Properties.VariableNames,varsHA));
            lacindx = find(contains(HA.(fieldNamesHARI{i}).Properties.VariableNames,'LactationNumber'));
            if sum(ismember(varindxHA,lacindx)) > 0
                varindxHA(varindxHA == lacindx) = [];
            end
            % combine tables
            HARI3.(fieldNamesHARI{i}) = innerjoin(HARI2.(fieldNamesHARI{i}),HA.(fieldNamesHARI{i})(:,varindxHA),'LeftKeys',{'Animal'},'RightKeys',{'OID'});
            HARI3.(fieldNamesHARI{i}) = removevars(HARI3.(fieldNamesHARI{i}),'OID');
            HARI3.(fieldNamesHARI{i}) = sortrows(HARI3.(fieldNamesHARI{i}),8);
            HARI3.(fieldNamesHARI{i}) = movevars(HARI3.(fieldNamesHARI{i}),[8 9 10 11 12 13],'before','ActualInseminationNumber');
        end
    catch 
        % do nothing
    end
end
clear test varindxAHD varindxEI varindxHADD varsAHD varsBA varsHARI varsHA varsEI varsHADD i ind varindxBA varindxHA selTables varindxHARI fieldnamesHAT C datapath headerpath savepath d selFiles EI2 fieldNamesEI fieldNamesHARI ans lacindx 




% merge farm files and save per farm
fieldNamesHAT = fieldnames(HAT2);
previousFarm = 'random';
for i = 1:length(fieldNamesHAT)
    numLoc = regexp(fieldNamesHAT{i,:},'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    currentFarm = fieldNamesHAT(i,:);     % farmname
    currentFarm = currentFarm{:};
    currentFarm = currentFarm(1,1:numLoc-1);
    
    if ~contains(fieldNamesHAT{i},previousFarm) & height(HAT2.(fieldNamesHAT{i})) > 10
        HAT3.(currentFarm) = HAT2.(fieldNamesHAT{i});
        
    elseif height(HAT2.(fieldNamesHAT{i})) > 10
        try
            HAT3.(currentFarm) = unique([HAT3.(currentFarm); HAT2.(fieldNamesHAT{i})],'rows');     
        catch
            HAT3.(currentFarm).Name(:,1) = HAT2.(fieldNamesHAT{i}).Name(1);
            HAT3.(currentFarm) = unique([HAT3.(currentFarm); HAT2.(fieldNamesHAT{i})],'rows');         
        end
    end

    previousFarm = currentFarm;
    
end
clear ans I 

% save in excel
fieldNamesHAT = fieldnames(HAT3);
for i = 1:length(fieldNamesHAT)
    writetable(HAT3.(fieldNamesHAT{i}), 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\TreatmentRegisters.xlsx','Sheet',fieldNamesHAT{i});     % write table in each sep tablad per MPR period
end


% Delete default sheets
% Open Excel file.
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile(cd_SV, FN1)); % Full path is necessary!  FN 1
% Delete sheets.
try
      % Throws an error if the sheets do not exist.
      objExcel.ActiveWorkbook.Worksheets.Item('Sheet1').Delete;
      objExcel.ActiveWorkbook.Worksheets.Item('Sheet2').Delete;
      objExcel.ActiveWorkbook.Worksheets.Item('Sheet3').Delete;
catch
       % Do nothing.
end
% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;

clear cd cd_H
