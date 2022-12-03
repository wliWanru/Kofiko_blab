function FiringRate_BOS = SimpleStim(ExpDate,Unit,Subject);
FiringRate_BOS = zeros(4,1);    ;
Close all;
figure;
if nargin < 3
    Subject = 'Rocco';
end

Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];



matname = dir([Datafolder '*_Unit_' Unit '_*_ContrastBorderOwner.mat']);
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_5.mat']);
end
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription AllRepeat] = SimpleStimAnalysisAux( strctUnit,20,500 )
    [junk index] = max(AllRepeat)
    if size(AllFiringRate,2) > 1;
        Resp_BarSize = AllFiringRate(:,index);
    else
        Resp_BarSize = AllFiringRate;
    end
    FiringRate_BOS = Resp_BarSize;
    bar(1:4,Resp_BarSize')
    box off;
    Title('BorderOwnerCell');
    
   
end
