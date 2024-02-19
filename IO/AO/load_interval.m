function astrctUnitIntervals = load_interval(ao, a2fActiveUnitsTable, strSessionName, strRawFolder)

% [~, time44] = AO_GetLatestTimeStamp;
% TimeNow = int32(time44/44)-BAM_config.StartingTime;


NumEntries = size(a2fActiveUnitsTable,1);
iIntervalCounter = 0;
for iEntryIter=1:NumEntries
    if a2fActiveUnitsTable(iEntryIter,1) == 1
        % New interval defined!
        iIntervalCounter = iIntervalCounter + 1;
        astrctUnitIntervals(iIntervalCounter).m_strRawFolder = strRawFolder;
        astrctUnitIntervals(iIntervalCounter).m_strSession = strSessionName;
        astrctUnitIntervals(iIntervalCounter).m_iUniqueID = iIntervalCounter;
        astrctUnitIntervals(iIntervalCounter).m_iChannel = a2fActiveUnitsTable(iEntryIter,2);
        astrctUnitIntervals(iIntervalCounter).m_iUnit = a2fActiveUnitsTable(iEntryIter,3) - 1;
        astrctUnitIntervals(iIntervalCounter).m_fStartTp_AO_origin = a2fActiveUnitsTable(iEntryIter, 4);

        astrctUnitIntervals(iIntervalCounter).m_fStartTS_AO = a2fActiveUnitsTable(iEntryIter, 4) / 44000 - ao.t_TimeBegin;

        astrctUnitIntervals(iIntervalCounter).m_fEndTp_AO_origin = NaN;
        astrctUnitIntervals(iIntervalCounter).m_fEndTS_AO = NaN;


        astrctUnitIntervals(iIntervalCounter).m_bStillOpen = true;
    else
        % Old interval closed.
        % find the relevant interval
        aiChannels = cat(1,astrctUnitIntervals.m_iChannel);
        aiUnits = cat(1,astrctUnitIntervals.m_iUnit);
        %       aiPlexonFrames = cat(1,astrctUnitIntervals.m_iPlexonFrame);
        afStartTS_AO = cat(1,astrctUnitIntervals.m_fStartTS_AO);

        iChannel = a2fActiveUnitsTable(iEntryIter,2);
        iUnit = a2fActiveUnitsTable(iEntryIter,3) - 1;

        fEndTp_AO_origin = a2fActiveUnitsTable(iEntryIter, 4);
        fEndTS_AO = a2fActiveUnitsTable(iEntryIter, 4) / 44000 - ao.t_TimeBegin;



        iOpenInterval  = find(aiChannels == iChannel & aiUnits == iUnit & afStartTS_AO < fEndTS_AO,1,'last');

        if isempty(iOpenInterval)
            fprintf('Critical error ! cannnot find the start interval for this closing interval (%d)!\n',iEntryIter);
        else
            if astrctUnitIntervals(iOpenInterval).m_bStillOpen == false
                fprintf('Critical error ! the interval has been closed already (%d)!\n',iEntryIter);
            else
                astrctUnitIntervals(iOpenInterval).m_fEndTp_AO_origin = fEndTp_AO_origin;
                astrctUnitIntervals(iOpenInterval).m_fEndTS_AO = fEndTS_AO;
                astrctUnitIntervals(iOpenInterval).m_bStillOpen = false;
            end
        end
    end
end


%%
% Check each interval for an NaN end time and assign the next interval's start time if necessary
for iInterval = 1:iIntervalCounter
    if isnan(astrctUnitIntervals(iInterval).m_fEndTp_AO_origin)
        if iInterval < iIntervalCounter
            astrctUnitIntervals(iInterval).m_fEndTp_AO_origin = astrctUnitIntervals(iInterval + 1).m_fStartTp_AO_origin;
            astrctUnitIntervals(iInterval).m_fEndTS_AO = astrctUnitIntervals(iInterval + 1).m_fStartTS_AO;
        else
            astrctUnitIntervals(iInterval).m_fEndTp_AO_origin = max(ao.SEG(1).waveforms_timestamps);
            astrctUnitIntervals(iInterval).m_fEndTS_AO = astrctUnitIntervals(iInterval).m_fEndTp_AO_origin/44000 - ao.t_TimeBegin;
            warning('Warning: Last interval does not have an end time. Assume it will last to the end.\n');        
        end
    end
end


astrctUnitIntervals = rmfield(astrctUnitIntervals,'m_bStillOpen');

return;
