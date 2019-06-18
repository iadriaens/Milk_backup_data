function [OUT] = AddLacN_LELY(INPUT,Lacdata)
% this function aims to add the lactation number to the Lely datasets
% INPUTS:   INPUT = milk yield dataset, with Animal Identifier = AniId, and
%                       containing a date variable 'Date'
%           Lacdata = dataset containing 'AniId'
%                                        'Calving'
%                                        'Lac'
%
% OUTPUTS:  INPUT with 3 columns added 'DIM', 'Calving', and 'Lac'
%
% STEP 1: identify the maximum lactation number in the Lacdata
% STEP 2: split Lacdata in unique parts containing at most 1 lactation per
%         animal
% STEP 3: stepwise add lactationnumber, calving and DIM to INPUT dataset

% sort per AniId and lactationnumber
Lacdata = sortrows(Lacdata, [1 2]);

% preprocess lactation data so 'too short lactations' are corrected (these
% orginate possibly from manuel errors introduced by the farmer, e.g. after
% an abortion)

cows = unique(Lacdata.AniId);       % all unique cows in the dataset
Lacdata.days(:,1) = NaN;            % prepare column for days between calving
Lacdata.order(:,1) = NaN;
Lacdata.corr(:,1) = 0;
Lacdata.Calving2(:,1) = NaT;
Lacdata.Delete(:,1) = NaN;
for i = 1:length(cows)              % for all cows
    ind = find(Lacdata.AniId == cows(i));   % find all calvings for this cow
    Lacdata.order(ind) = 1:length(ind);
    if length(ind)>1                % if she has a calving (not only birth)
        Lacdata.days(ind(1)) = NaN; % first array is NaN
        Lacdata.days(ind(2:end)) = datenum(Lacdata.Calving(ind(2:end)))-datenum(Lacdata.Calving(ind(1:end-1))); % second is days between two successive calvings
        
        % correct the incorrect calving dates
        idx = find(Lacdata.days(ind) < (280+25) & Lacdata.order(ind) ~= 2);
        
        if (isempty(idx) == 1)| (Lacdata.days(ind(idx-1))>750)
        else
            Lacdata.corr(ind(idx(end)),1) = 1;
            Lacdata.Calving2(ind(idx(end)-1:end-1),1) = Lacdata.Calving(ind(idx(end):end));
            Lacdata.Delete(ind(end),1) = 1;
        end
    end
end
Lacdata(Lacdata.Delete==1,:) = [];
Lacdata.Calving(isnat(Lacdata.Calving2) == 0,1) = Lacdata.Calving2(isnat(Lacdata.Calving2)==0,1);
Lacdata(:,4:8) = [];

% identify and split
T =0;
while isempty(Lacdata) == 0
    T = T+1;
    L = sprintf('Lac%d',T);
    
    [~,ind] = unique([Lacdata.AniId],'rows','first');

    lacd.(L) = Lacdata(ind,:);
    Lacdata(ind,:) = [];
end
 
% prepare output dataset
OUT = INPUT;
OUT.DIMr(:,1) = NaN;
OUT.Lacr(:,1) = NaN;
OUT.Calvingr(:,1) = NaT;

for i = T:-1:1
    L = sprintf('Lac%d',i);
    
    OUT = outerjoin(OUT,lacd.(L),'Keys','AniId','MergeKeys',1);
    
    if sum(contains(OUT.Properties.VariableNames,'Date')) > 0
        OUT.DIMnew(:,1) = datenum(OUT.Date(:,1)+0.1) - datenum(OUT.Calving(:,1));  
    else
        OUT.DIMnew(:,1) = datenum(OUT.StartTime(:,1)) - datenum(OUT.Calving(:,1));  
    end
    idx = find(OUT.DIMnew>0 & isnan(OUT.DIMr) == 1);
    OUT.DIMr(idx,1) = OUT.DIMnew(idx,1);
    OUT.Lacr(idx,1) = OUT.Lac(idx,1);
    OUT.Calvingr(idx,1) = OUT.Calving(idx,1);
    OUT.Calving = [];
    OUT.DIMnew = [];
    OUT.Lac = [];
    
end
    
OUT.DIM(:,1) = OUT.DIMr(:,1); OUT.DIMr = [];
OUT.Lac(:,1) = OUT.Lacr(:,1); OUT.Lacr = [];
OUT.Calving(:,1) = OUT.Calvingr(:,1); OUT.Calvingr = [];

if sum(contains(OUT.Properties.VariableNames,'TMY')) > 0    % check whether the varnames contain TMY
    OUT(OUT.Lac ==0 & isnan(OUT.TMY)==1,:) = [];
elseif sum(contains(OUT.Properties.VariableNames,'TDMY')) > 0    % check whether the varnames contain TMY
    OUT(OUT.Lac ==0,:) = [];      % this deletes also DHI data
end


% second step is do the preprocessing and the checkup to verify the
% lactation numbers and DIM that are assigned to each measurment.
% the observation is that 
    