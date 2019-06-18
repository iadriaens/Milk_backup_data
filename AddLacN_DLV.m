function [OUT] = AddLacN_DLV(INPUT,Lacdata)
% this function aims to add the lactation number to the Lely datasets
% INPUTS:   INPUT = milk yield dataset, with Animal Identifier = BA, and
%                       containing a date variable 'EndTime'
%           Lacdata = dataset containing 'BA'
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


% identify and split
T =0;
while isempty(Lacdata) == 0
    T = T+1;
    L = sprintf('Lac%d',T);
    
    [~,ind] = unique([Lacdata.BA],'rows','first');

    lacd.(L) = Lacdata(ind,:);
    Lacdata(ind,:) = [];
end

% prepare output dataset
OUT = INPUT;
OUT.DIMr(:,1) = NaN;
OUT.Lacr(:,1) = NaN;
OUT.Calvingr(:,1) = NaT;

    if sum(contains(OUT.Properties.VariableNames,'Lac'))>1
        OUT.Lac = [];
    end
        
for i = T:-1:1
    L = sprintf('Lac%d',i);
    
    OUT = outerjoin(OUT,lacd.(L),'Keys','BA','MergeKeys',1);
    if sum(contains(OUT.Properties.VariableNames,'EndTime'))>0
        OUT.DIMnew(:,1) = datenum(OUT.EndTime(:,1)+0.1) - datenum(OUT.Calving(:,1));
    else
        OUT.DIMnew(:,1) = datenum(OUT.Date(:,1)+0.1) - datenum(OUT.Calving(:,1));
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
    