function OUT = GEA_milkdata(cd, FN_milk)
% this function loads  GEA data and puts it in the right format
% constructs the 'milkings' table, and we added for completeness a column
% with the daily data
%

% 
clear variables
cd = 'D:\RAFT_data\GEA_Banks\Banks - Wildon Grange Data\';

FN_milk = 'Banks Milk data  29062017.txt';


%% STEP 1: load milkings data
try 
    OUT = readtable([cd FN_milk],'Format','%f %f %f %f %q %{H:mm}D %{dd-MM-yy}D');        % 73306 x 7
catch
    OUT = readtable([cd FN_milk]);
end

% adjust dates
OUT.Date(:,1) = datetime(datenum(OUT.Var7) + datenum(OUT.Var6)-datenum(today()),'ConvertFrom','datenum');
OUT.Var6 = [];
OUT.Var7 = [];
OUT.Var4 = [];
OUT.Var3 = [];

OUT.Properties.VariableNames = {'CowID','DIM','TMY','Date'};
if isnumeric(OUT.TMY(1))==0
    m = zeros(size(OUT.TMY,1),size(OUT.TMY,2));
    m = str2double(OUT.TMY);
    OUT.TMY = [];
    OUT.TMY = m;
end
clear m cd FN_milk

OUT = Add_CowInfo_GEA(OUT);

OUT = sortrows(OUT,{'CowID','Date'});

%% STEP 2: ADD daily sum (independent of the number of milkings)

% find index of first day of each cow
cows = unique(OUT(:,[1 5]));
OUT.DIM2(:,1) = ceil(OUT.DIM);
TDMY = [];
OUT(isnan(OUT.DIM)==1,:)=[];    % delete emptys
for i = 1:length(cows.CowID)
    ind = find(OUT.CowID == cows.CowID(i) & OUT.Calving == cows.Calving(i));
    
    TMY = OUT.TMY(ind);
    SUBS = ceil(OUT.DIM(ind)); % max(SUBS) = [4070 639];
    SZ = [];
    a = accumarray(SUBS,TMY,SZ,@nansum);
    a(1:min(SUBS)-1) = [];
    a = array2table([a (min(SUBS):max(SUBS))' ones(length(min(SUBS):max(SUBS)),1)*cows.CowID(i)],'VariableNames',{'TDMY','DIM2','CowID'});
    a.Calving(:,1) = cows.Calving(i);
    TDMY = [TDMY ; a]; clear a
end

OUT = outerjoin(OUT,TDMY,'Keys',{'CowID','DIM2','Calving'},'MergeKeys',1);
OUT.TDMY(OUT.TDMY == 0) = NaN;
[~,ind] = unique(OUT(:,[1 6 5]),'rows'); ind = sortrows(ind);
idx = find(ismember(1:length(OUT.CowID),ind)==0); idx = idx';
OUT.TDMY(idx) = NaN;


