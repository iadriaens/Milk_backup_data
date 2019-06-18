function OUT = Add_CowInfo_GEA(INPUT)
% this function fills in the empty rows of the GEA milkings dataset
%       CowID
%       DIM
%       Calving
% VariableNames = CowID, DIM, Date

% find indices of rows that are complete
ind_fill = find(isnan(INPUT.CowID)==0);

% find indices of the rows until where to fill in
ind_end = [ind_fill(2:end)-1;length(INPUT.CowID)];

% find position of the right columns
colnames = {'CowID','DIM','Date'};
colindex = zeros(1,length(colnames));
for i = 1:length(colnames)
    colindex(i) = find(contains(INPUT.Properties.VariableNames,colnames{i}),1);
end
    
% cow info to fill in
cowinfo = INPUT(ind_fill,colindex);
cowinfo.Calving(:,1) = datetime(floor(datenum(cowinfo.Date - cowinfo.DIM)),'ConvertFrom','datenum');

% fill in from index to index-1 (end)
OUT = INPUT;
OUT.Calving(:,1) = NaT;
for i= 1:length(ind_fill)
    OUT.CowID(ind_fill(i):ind_end(i),1)=cowinfo.CowID(i);
    OUT.Calving(ind_fill(i):ind_end(i),1)= cowinfo.Calving(i);
end

% correct days in milk
OUT.DIM(:,1) = datenum(INPUT.Date) - datenum(OUT.Calving);