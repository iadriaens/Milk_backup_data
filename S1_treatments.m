%% S1_treatments
% read, merge and save TREATMENT files
%



clear variables
close all
clc
% datetime.setDefaultFormats('defaultdate','dd-MM-yyyy HH:mm:ss');

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
selTables = {'Diagnosis','HistoryAnimalTreatment','DiagnosisTreatmentEvent'};
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
        if contains(selFiles.Table{i},'DiagnosisTreatmentEvent')
            DTE.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HistoryAnimalTreatment')
            HAT.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        else 
            diag.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end

% remove almost empty (less than 5 lines)
DTEfields = fieldnames(DTE);
for i = 1:length(fieldnames(DTE))
    if height(DTE.(DTEfields{i})) < 5
        DTE = rmfield(DTE,DTEfields{i});
    end
end

% AHD
for i = 1:height(files)
    if contains(files.Table{i},'AnimalHistoricalData') && files.Version(i) == 3.7
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

% innerjoin DTE and AHD
DTEfields = fieldnames(DTE);
for i = 1:length(fieldnames(DTE))
    DTE.(DTEfields{i}) = innerjoin(DTE.(DTEfields{i}),AHD.(DTEfields{i})(:,[1 4 5  7 8]),'Keys','OID');
    
end




% BA & HA
for i = 1:height(files)
    if contains(files.Table{i},'HistoryAnimal') && ~contains(files.Table{i},'HistoryAnimalD') && ~contains(files.Table{i},'HistoryAnimalL') ...
                && ~contains(files.Table{i},'HistoryAnimalR') && ~contains(files.Table{i},'HistoryAnimalT') && sum(contains(fieldnames(HAT),files.Farm{i}))>=1
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
        if contains(files.Table{i},'BasicAnimal') && (sum(contains(fieldnames(HAT),files.Farm{i}))>=1 || sum(contains(fieldnames(DTE),files.Farm{i}))>=1)
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

% combine BA information with HAT & diagnosis
fieldNamesHAT = fieldnames(HAT);
varsBA = {'OID','Number','Name','BirthDate','ExitDate','OfficialRegNo'};
varsHAT = {'Animal','LactationNumber','TreatStartDate','DurationInDays','DiagnosesName','TreatmentName'};
for i = 1:length(fieldNamesHAT)
    % find indices
    varindxHAT = find(contains(HAT.(fieldNamesHAT{i}).Properties.VariableNames,varsHAT));
    if contains(fieldnames(BA),fieldNamesHAT{i})
        varindxBA = find(contains(BA.(fieldNamesHAT{i}).Properties.VariableNames,varsBA));
        % combine tables
        HAT2.(fieldNamesHAT{i}) = innerjoin(HAT.(fieldNamesHAT{i})(:,varindxHAT),BA.(fieldNamesHAT{i})(:,varindxBA),'LeftKeys',{'Animal'},'RightKeys',{'OID'});
    else
        varindxHA = find(contains(HA.(fieldNamesHAT{i}).Properties.VariableNames,varsBA));
        lacindx = find(contains(HA.(fieldNamesHAT{i}).Properties.VariableNames,'LactationNumber'));
        if sum(ismember(varindxHA,lacindx)) > 0
            varindxHA(varindxHA == lacindx) = [];
        end
        % combine tables
        HAT2.(fieldNamesHAT{i}) = innerjoin(HAT.(fieldNamesHAT{i})(:,varindxHAT),HA.(fieldNamesHAT{i})(:,varindxHA),'LeftKeys',{'Animal'},'RightKeys',{'OID'});
    end
end


%=============================================================================================================
% agrivet names diag
diag.Agrivet_20191219.Properties.VariableNames = diag.Agrivet_20200608.Properties.VariableNames;

% dte
fieldNamesDTE = fieldnames(DTE);
varsBA = {'OID','Number','Name','BirthDate','ExitDate','OfficialRegNo'};
% varsDTE = {'OID','Diagnosis','TreatmentEndDate'};
varsDTE = {'OID','Diagnosis','TreatmentEndDate','DateAndTime','BasicAnimal','DIM','LactationNumber'};
varsDIAG = {'OID','Name'};
for i = 1:length(fieldNamesDTE)
    % find indices
    varindxDTE = find(contains(DTE.(fieldNamesDTE{i}).Properties.VariableNames,varsDTE));
    varindxBA = find(contains(BA.(fieldNamesDTE{i}).Properties.VariableNames,varsBA));
    varindxDIAG = find(contains(diag.(fieldNamesDTE{i}).Properties.VariableNames,varsDIAG)); 
    if length(varindxDIAG) > 2
        varindxDIAG(end) = [];
    end
    
    % HAT
    HAT2.(fieldNamesDTE{i}) = innerjoin(DTE.(fieldNamesDTE{i})(:,varindxDTE),BA.(fieldNamesDTE{i})(:,varindxBA),'LeftKeys',{'BasicAnimal'},'RightKeys',{'OID'});
    HAT2.(fieldNamesDTE{i}) = innerjoin(HAT2.(fieldNamesDTE{i}),diag.(fieldNamesDTE{i})(:,varindxDIAG),'LeftKeys',{'Diagnosis'},'RightKeys',{'OID'});
    
end
clear varsBA varsHAT i ind varindxBA varindxHA selTables varindxHAT fieldnamesHAT C datapath headerpath savepath d selFiles

%=============================================================================================================

% merge farm files and save per farm
fieldNamesHAT = fieldnames(HAT2);
previousFarm = 'random';
for i = 1:length(fieldNamesHAT)
    numLoc = regexp(fieldNamesHAT{i,:},'_');       % this functions finds the unique positions of 2 successive numbers in a filename
    currentFarm = fieldNamesHAT(i,:);     % farmname
    currentFarm = currentFarm{:};
    currentFarm = currentFarm(1,1:numLoc-1);
    
    if ~contains(fieldNamesHAT{i},previousFarm) & height(HAT2.(fieldNamesHAT{i})) > 5
        HAT3.(currentFarm) = unique(HAT2.(fieldNamesHAT{i}));
        previousFarm = currentFarm;

    elseif height(HAT2.(fieldNamesHAT{i})) > 5
        try
            HAT3.(currentFarm) = unique([HAT3.(currentFarm); HAT2.(fieldNamesHAT{i})],'rows');     
            previousFarm = currentFarm;
        catch
            HAT3.(currentFarm).Name(:,1) = HAT2.(fieldNamesHAT{i}).Name(1);
            HAT3.(currentFarm) = unique([HAT3.(currentFarm); HAT2.(fieldNamesHAT{i})],'rows');         
            previousFarm = currentFarm;
        end
    end
end
clear ans I

% delete diag / treat of same cows and same diagnosis
fieldNamesHAT = fieldnames(HAT3);
for i = 1:length(fieldNamesHAT)
    try 
        HAT3.(fieldNamesHAT{i}) = sortrows(HAT3.(fieldNamesHAT{i}),{'Animal','TreatStartDate'});
    catch
        HAT3.(fieldNamesHAT{i}) = sortrows(HAT3.(fieldNamesHAT{i}),{'BasicAnimal','DateAndTime'});
    end
    HAT3.(fieldNamesHAT{i}).DEL(:,1) = 0;
    for ii = 2:height(HAT3.(fieldNamesHAT{i}))
        try
            if HAT3.(fieldNamesHAT{i}).Animal(ii) == HAT3.(fieldNamesHAT{i}).Animal(ii-1) & (datenum(HAT3.(fieldNamesHAT{i}).TreatStartDate(ii))- datenum(HAT3.(fieldNamesHAT{i}).TreatStartDate(ii-1))) <= 5
                HAT3.(fieldNamesHAT{i}).DEL(ii) = 1;
            end
        catch
            if HAT3.(fieldNamesHAT{i}).BasicAnimal(ii) == HAT3.(fieldNamesHAT{i}).BasicAnimal(ii-1) & (datenum(HAT3.(fieldNamesHAT{i}).DateAndTime(ii))- datenum(HAT3.(fieldNamesHAT{i}).DateAndTime(ii-1))) <= 5
                HAT3.(fieldNamesHAT{i}).DEL(ii) = 1;
            end
        end
    end
    HAT3.(fieldNamesHAT{i})(HAT3.(fieldNamesHAT{i}).DEL==1,:) = [];
end

% save in excel
fieldNamesHAT = fieldnames(HAT3);
for i = 1:length(fieldNamesHAT)
    writetable(HAT3.(fieldNamesHAT{i}), 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\TreatmentRegisters_new.xlsx','Sheet',fieldNamesHAT{i});     % write table in each sep tablad per MPR period
end


% Delete default sheets
% Open Excel file.
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open('C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\TreatmentRegisters_new.xlsx'); % Full path is necessary!  FN 1
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

    

%% STEP D0: detect data files in folder LELY
clear variables
clc

% directory of txt files with data
cd = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT_Lelytxt\';     % all data files in txt format
cd_H = 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\testSQLOUTPUT_Lelyhead\';   % all header files

% find all the files in the folder
FNfiles = ls(cd);        % this is the list with files in the folder where I saved the MPR results of MCC
ind = []; 
for i  = 1:length(FNfiles);if isempty(find(contains(FNfiles(i,:),'.txt'))) == 1; ind = [ind; i];end;end % find no filenames
FNfiles(ind,:) = []; clear ind     % delete

% find all farmnames = for all files everything before '_'
files = array2table((1:length(FNfiles))','VariableNames',{'No'});
files.Farm(:,:) = repmat({'na'},length(FNfiles),1);
files.Date(:,1) = NaT;
files.Table(:,:) = repmat({'na'},length(FNfiles),1);
files.FN(:,:) = repmat({'na'},length(FNfiles),1);
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

% clear variables
clear i endLoc numLoc 

% select tables containing treatment / diagnosis data
selTables = {'HemDiagnoses','HemDiagnosesAction','LimDisease'};
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
        
        C = selFiles.Farm{i};
        
        if month(selFiles.Date(i)) < 10 && day(selFiles.Date(i)) < 10
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) '0' num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        elseif month(selFiles.Date(i)) < 10 && day(selFiles.Date(i)) >= 10
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) '0' num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        elseif month(selFiles.Date(i)) >= 10 && day(selFiles.Date(i)) < 10
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) '0'  num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        else
            savepath = ['C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\' selFiles.Farm{i} '_' num2str(year(selFiles.Date(i))) num2str(month(selFiles.Date(i))) num2str(day(selFiles.Date(i))) '_' selFiles.Table{i} '.txt'];
        end
        
        % combine and save
        if contains(selFiles.Table{i},'HemDiagnosesAction')
            diagaction.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'HemDiagnoses')
            diagnosis.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        elseif contains(selFiles.Table{i},'LimDisease')
            disease.(C) = F1_CombineDataHeaders(datapath,headerpath,savepath);
        end
    end
end
clear i ind headerpath datapath savepath

% Animal
for i = 1:height(files)
    if contains(files.Table{i},'HemAnimal') && sum(contains(fieldnames(diagnosis),files.Farm{i}))>=1
        datapath = [cd files.FN{i} '.txt'];
        headerpath = [cd_H files.FN{i} '_headers.txt'];
         
        C = files.Farm{i};
  
        Animal.(C) = F1_CombineDataHeaders(datapath,headerpath);
    end
end

% combine BA information with HAT & diagnosis
fieldNamesDIA = fieldnames(diagnosis);
varsANI = {'AniId','AniName','AniUserNumber','AniLifeNumber','AniBirthday'};
varsDIA = {'DiaAniId','DiaDisId','DiaDate','DiaLocationLF','DiaLocationRF','DiaLocationLR','DiaLocationRR'};
varsDIS = {'DisId','DisName','DisDescription'};
for i = 1:length(fieldNamesDIA)
    % find indices
    varindxANI = find(contains(Animal.(fieldNamesDIA{i}).Properties.VariableNames,varsANI));
    varindxDIA = find(contains(diagnosis.(fieldNamesDIA{i}).Properties.VariableNames,varsDIA));
    varindxDIS = find(contains(disease.(fieldNamesDIA{i}).Properties.VariableNames,varsDIS));

    % combine tables
    TR.(fieldNamesDIA{i}) = innerjoin(diagnosis.(fieldNamesDIA{i})(:,varindxDIA),Animal.(fieldNamesDIA{i})(:,varindxANI),'LeftKeys',{'DiaAniId'},'RightKeys',{'AniId'});
    TR.(fieldNamesDIA{i}) = innerjoin(TR.(fieldNamesDIA{i}),disease.(fieldNamesDIA{i})(:,varindxDIS),'LeftKeys',{'DiaDisId'},'RightKeys',{'DisId'});
    if height(TR.(fieldNamesDIA{i})) < 10
        TR = rmfield(TR,fieldNamesDIA{i});
    else
        TR.(fieldNamesDIA{i}) = sortrows(TR.(fieldNamesDIA{i}),{'DiaDate','DiaAniId'});
    end
end
clear varsANI varsDIA varsDIS i ind varindxANI varindxDIA varindxDIS selTables varindxHAT fieldnamesHAT C datapath headerpath savepath d selFiles

%--------------------------------------------------------
% delete treatmetns with only drying off
fieldNamesTR = fieldnames(TR);
for i = 1:length(fieldNamesTR)
    TR.(fieldNamesTR{i}).DEL(:,1) = 0;
    TR.(fieldNamesTR{i}).DEL(contains(TR.(fieldNamesTR{i}).DisName,'Drying-off'))=1;
    TR.(fieldNamesTR{i}) = sortrows(TR.(fieldNamesTR{i}),{'DiaAniId','DiaDate'});
    for ii = 2:height(TR.(fieldNamesTR{i}))
        if TR.(fieldNamesTR{i}).DiaAniId(ii) == TR.(fieldNamesTR{i}).DiaAniId(i) &  contains(TR.(fieldNamesTR{i}).DisName(ii),TR.(fieldNamesTR{i}).DisName(i)) & abs(datenum(TR.(fieldNamesTR{i}).DiaDate(ii))-datenum(TR.(fieldNamesTR{i}).DiaDate(i))) < 5 
            TR.(fieldNamesTR{i}).DEL(ii) = 1;
        end
    end
    TR.(fieldNamesTR{i})(TR.(fieldNamesTR{i}).DEL ==1,:)=[];
end



% -------------------------------------------------------



% save in excel
fieldNamesTR = fieldnames(TR);
for i = 1:length(fieldNamesTR)
    writetable(TR.(fieldNamesTR{i}), 'C:\Users\u0084712\Documents\Box Sync\Documents\MastiMan\Data\Data sets\Backup files\ALLADD\TreatmentRegisters_new.xlsx','Sheet',fieldNamesTR{i});     % write table in each sep tablad per MPR period
end




