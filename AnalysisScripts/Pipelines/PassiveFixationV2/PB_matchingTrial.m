function [MLEvents AOEvents] = PB_matchingTrial(AOData,MLFile,fixation_window,Percent_Threshold, eyetrack_eye2);
aoev = AOData.Trigger.events;
aoev_t = AOData.Trigger.indices_44k_origin;

ao_index_begin = find(aoev == 9);
ao_index_end = find(aoev == 18);

rindex_begin = processindices(ao_index_begin,aoev_t);
rindex_end = processindices(ao_index_end,aoev_t);

if ~(length(rindex_begin) == length(MLFile))
    disp('Number of Starting Trigger 9 doesn''t match');
    if length(rindex_end) - length(MLFile) == 1 && length(rindex_end) ==  length(rindex_begin)
        disp('suspect ML crashed before AO ending; try to remove the last AO trial trigger');
        rindex_begin = rindex_begin(1:end-1, 1); 
        rindex_end = rindex_end(1:end-1, 1);
    end
end

if ~(length(rindex_end) == length(MLFile))
    disp('Number of Ending Trigger 18 doesn''t match')
    if length(MLFile) - length(rindex_end) == 1
        disp('suspect AO crashed before ML ending; try to remove the last ML trial');
        MLFile = MLFile(1:end-1); 
    end
end



element = 1;
for i = 1:length(MLFile)
    ct = MLFile(i).BehavioralCodes.CodeTimes;
    cn = MLFile(i).BehavioralCodes.CodeNumbers;
    aosttime = AOData.Trigger.indices_44k_origin(rindex_begin(i));
    aoendtime = AOData.Trigger.indices_44k_origin(rindex_end(i));
    ctstime = ct(1); ctendtime = ct(end);
    ml2ao = polyfit([ctstime ctendtime],[aosttime aoendtime],1);
    ct_transfer = ct*ml2ao(1) + ml2ao(2);
    index = find(cn>10000 & cn < 20000);
    indextokeep = logical(1:length(index));
    gapbetween = [];
    for j = 1:length(index)
        junkindex = 1;

        while(cn(index(j)+junkindex) == 14)
            junkindex = junkindex + 1;
        end
        if index(j) + junkindex > length(cn)
            indextokeep(j) = false;
        else
            if cn(index(j)+junkindex) == cn(index(j)) + 10000;
                indextokeep(j) = true;
            else
                indextokeep(j) = false;
            end
        end
        gapbetween(j) = junkindex;
    end
    indexvalid = index(indextokeep);
    gapbetween = gapbetween(indextokeep);
    for j = 1:length(indexvalid)
        iter = indexvalid(j);
        End_iter = indexvalid(j)+gapbetween(j);
        MLEvents(element).Trial = i;
        MLEvents(element).Dataset = MLFile(i).UserVars.DatasetName;
        MLEvents(element).ImageCode = MLFile(i).BehavioralCodes.CodeNumbers(iter)-10000;
        MLEvents(element).ML_OnTime = MLFile(i).BehavioralCodes.CodeTimes(iter);
        MLEvents(element).ML_OffTime = MLFile(i).BehavioralCodes.CodeTimes(End_iter);


        % --- for 303 half the sampling rate --- 
        ML_OnTime_Index_eye = floor(MLFile(i).BehavioralCodes.CodeTimes(iter) / MLFile(i).AnalogData.SampleInterval);
        ML_OffTime_Index_eye = floor(MLFile(i).BehavioralCodes.CodeTimes(End_iter) / MLFile(i).AnalogData.SampleInterval);
        Interval = ML_OnTime_Index_eye : ML_OffTime_Index_eye;
        % ----------------------------------------

        MLEvents(element).Eye = MLFile(i).AnalogData.Eye(Interval,:);
        EyeMoves = length(MLEvents(element).Eye);
        Eye_dis = sqrt(MLEvents(element).Eye(:,1).^2 + MLEvents(element).Eye(:,2).^2);

        if eyetrack_eye2
            MLEvents(element).Eye2 = MLFile(i).AnalogData.Eye2(Interval,:);
            Eye2_dis = sqrt(MLEvents(element).Eye2(:,1).^2 + MLEvents(element).Eye2(:,2).^2);
            ValidEyeMoves = sum(Eye2_dis<fixation_window | Eye_dis<fixation_window);
        else
            ValidEyeMoves = sum(Eye_dis<fixation_window);

        end

        MLEvents(element).ValidPer = ValidEyeMoves/EyeMoves;
        if MLEvents(element).ValidPer > Percent_Threshold
            MLEvents(element).IsValid = 1;
        else
            MLEvents(element).IsValid = 0;
        end
        MLEvents(element).ML_Ontime_AO = ct_transfer(iter);
        MLEvents(element).ML_Offtime_AO = ct_transfer(End_iter);
        element = element + 1;
    end

end


OnEvent = cat(1,MLEvents.ImageCode) + 10000;
OffEvent = cat(1,MLEvents.ImageCode) + 20000;

OnEvent_Time = cat(1,MLEvents.ML_Ontime_AO);
OffEvent_Time = cat(1,MLEvents.ML_Offtime_AO);

[corrindexON, corrtimeON] = findcorrinAO(AOData,OnEvent,OnEvent_Time);
[corrindexOff, corrtimeOff] = findcorrinAO(AOData,OffEvent,OffEvent_Time);

maskON = find(corrindexON == 0);
maskOff = find(corrindexOff == 0);
disp(sprintf('Cannot find the %d correspondece trial in AO for onTime',length(maskON)));
disp(sprintf('Cannot find the %d correspondece trial in AO for OFFTime',length(maskOff)));

fullmask = unique([maskON;maskOff]);

if ~isempty(fullmask)
    OnEvent(fullmask) = []; OffEvent(fullmask)= [];
    corrtimeON(fullmask) = []; OnEvent_time(fullmask) = [];
    corrtimeOff(fullmask) = []; OffEvent_Time(fullmask) = [];
    Trial(fullmask) = [];
end

maxdevOn = max(abs(corrtimeON-OnEvent_Time))/AOData.Trigger.att_SampleRate;
maxdevOff = max(abs(corrtimeOff-OffEvent_Time))/AOData.Trigger.att_SampleRate;

disp(sprintf('The largest deviation on time between AO and ML is %f ',maxdevOn));
disp(sprintf('The largest deviation on time between AO and ML is %f ',maxdevOff));


Trial = cat(1,MLEvents.Trial);

for i = 1:length(Trial)
    AOEvents(i).Trial = Trial(i);
    AOEvents(i).ImageCode = OnEvent(i) - 10000;
    AOEvents(i).AO_OnTime = corrtimeON(i)/AOData.Trigger.att_SampleRate;
    AOEvents(i).AO_OffTime = corrtimeOff(i)/AOData.Trigger.att_SampleRate;
end
if ~isempty(fullmask)

    MLEvents(fullmask) = [];
end
MLEventsvalid = rmfield(MLEvents,{'ML_Ontime_AO','ML_Offtime_AO'});
MLEvents = MLEventsvalid;


function [corrindex corrtime] = findcorrinAO(ao,OnEvent,OnEvent_Time)
corrindex = zeros(size(OnEvent));
corrtime = zeros(size(corrindex));
for i = 1:length(OnEvent)
    target = OnEvent(i);
    target_time = OnEvent_Time(i);
    mn = find(ao.Trigger.events == target);
    for j = 1:length(mn)
        if abs(ao.Trigger.indices_44k_origin(mn(j)) - target_time)<0.01*44000
            corrindex(i) = mn(j); corrtime(i) = ao.Trigger.indices_44k_origin(mn(j));
        end
    end
end
%

function [rindex todelete]= processindices(index,aoev_t)

% -- index: all AO trigger *index* of a certain value (begin 9, end 18)
% -- aoev_t: all AO trigger values
% -- index(i) and index(i-1) should be the timeStamp difference between two ML_Trial
%    beginning; if its a small value, it should be a very short ML_Trial (containing
%    few images)
% -- what kind of operation leads to this? 
% -- sometimes theres multiple starting and ending triggers 

index = sort(index);
todelete = [];
for i = 2:length(index)
    if aoev_t(index(i)) - aoev_t(index(i-1)) < 0.1*44000
        todelete =[todelete i];
    end
end

rindex = index;
rindex(todelete) = [];

