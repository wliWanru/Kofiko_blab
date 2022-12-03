function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)

if nargin<5;
    doplot = 1;
end


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'OcclusionFace_PB');

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

a2bStimulusToCondition = zeros(length(filename),20);
%1-7 Face (full/Occluded_left/Occluded_Right center left right);
%8- 12 Obj (8:full 9 left full 10 left occluded 11 right full right
%occluded)

%13 1face 1face nothing
%14 nothing 1face 1obj
%15 1face 1face nothing
%16 1obj 1face nothing
%17 nothing 0Face 0 face
%18 nothng 0face 0 obj
%19 0face 0face nothing
%20 0obj 0face nothing

for i = 1:length(filename);
    fn = filename{i};
    [junk fn ext] = fileparts(fn);
    tt = find(fn=='_');
    if length(tt) == 1;
        if strcmpi(fn(1:tt(1)-1),'face');
            cond = 1;
        else
            cond = 8;
        end
    else
        f1 = fn(1:tt(1)-1); f2 = fn(tt(1)+1:tt(2)-1); f3 = fn(tt(2)+1:tt(3)-1); f4 = fn(tt(3)+1:end);
        if strcmpi(f1,'avgmask')
            fb = strcmpi(f2(1:4),'face'); fo = strcmpi(f3,'full'); lr = strcmpi(f4,'rh');
            if fb == 1;
                cond = 3 + 2*(1-lr)  + 2-fo;
            else
                cond = 8 + 2*(1-lr) +2- fo;
            end
        elseif strcmpi(f2,'avgmask');
            lr = strcmpi(f4,'rh');
            cond = 3 - lr;
        end
        
        if ~(strcmpi(f1,'avgmask') || strcmpi(f2,'avgmask'))
            fb = strcmpi(f2(1:4),'face'); fo = strcmpi(f3,'centerup'); lr = strcmpi(f4,'rh');
            cond = 12 + (1-fo) * 4 + (1-lr) *2 + 2 - fb;
        end
    end
    a2bStimulusToCondition(i,cond) = 1;
    cc(i) = cond;
end
[fr, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition, 10,1);
if doplot
    figure;
    subplot(2,2,1);
    hold on;
    title('1face-0face-RH');
    plot(-200:900,fr(13,:),'k-','linewidth',2);
    plot(-200:900,fr(1,:),'b-','linewidth',2);
    plot(-200:900,fr(5,:),'r-','linewidth',2);
    
    subplot(2,2,2);
    hold on;
    
    title('1face-0face-LH');
    plot(-200:900,fr(15,:),'k-','linewidth',2);
    plot(-200:900,fr(1,:),'b-','linewidth',2);
    plot(-200:900,fr(7,:),'r-','linewidth',2);
    
    subplot(2,2,3);
    hold on;
    
    title('0face-1face-RH');
    plot(-200:900,fr(17,:),'k-','linewidth',2);
    plot(-200:900,fr(2,:),'b-','linewidth',2);
    plot(-200:900,fr(4,:),'r-','linewidth',2);
    
    subplot(2,2,4);
    hold on;
    
    title('0face-1face-LH');
    plot(-200:900,fr(19,:),'k-','linewidth',2);
    plot(-200:900,fr(3,:),'b-','linewidth',2);
    plot(-200:900,fr(8,:),'r-','linewidth',2);
    
    
    figure;
    subplot(2,2,1);
    hold on;
    
    title('1face-0obj-RH');
    plot(-200:900,fr(14,:),'k-','linewidth',2);
    plot(-200:900,fr(1,:),'b-','linewidth',2);
    plot(-200:900,fr(10,:),'r-','linewidth',2);
    
    subplot(2,2,2);
    hold on;
    
    title('1face-0obj-LH');
    plot(-200:900,fr(16,:),'k-','linewidth',2);
    plot(-200:900,fr(1,:),'b-','linewidth',2);
    plot(-200:900,fr(12,:),'r-','linewidth',2);
    
    subplot(2,2,3);
    hold on;
    
    title('0face-1obj-RH');
    plot(-200:900,fr(18,:),'k-','linewidth',2);
    plot(-200:900,fr(2,:),'b-','linewidth',2);
    plot(-200:900,fr(9,:),'r-','linewidth',2);
    
    subplot(2,2,4);
    hold on;
    
    title('0face-1obj-LH');
    plot(-200:900,fr(20,:),'k-','linewidth',2);
    plot(-200:900,fr(3,:),'b-','linewidth',2);
    plot(-200:900,fr(11,:),'r-','linewidth',2);
end


