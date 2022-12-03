function rr = PB_STC(raster,lfp,timewindow,trialtype,lfpwindow);

for i = 1:max(trialtype);
    trialindex = find(trialtype == i);
    raster_type = raster(trialindex,:);
    lfp_type = lfp(trialindex,:);
    spikenumber = 0;
    stlfp = 0;
    stlfpenergy = 0;
    for j = 1:size(raster_type,1);
        
        for k = timewindow;
            if raster_type(j,k);
                spikenumber = spikenumber + raster_type(j,k);
                if ~sum(isnan(lfp_type(j,k-lfpwindow:k+lfpwindow)))
                stlfp = stlfp + raster_type(j,k) * lfp_type(j,k-lfpwindow:k+lfpwindow);
                stlfpenergy = stlfpenergy + raster_type(j,k) * pmtm(lfp_type(j,k-lfpwindow:k+lfpwindow));
                end
            end
        end
    end
    rr.stlfp(i,:) = stlfp/spikenumber;
    rr.stenergy(i,:) = pmtm(stlfp/spikenumber);
    rr.stlfpenergy(i,:) = (stlfpenergy/spikenumber);
end

