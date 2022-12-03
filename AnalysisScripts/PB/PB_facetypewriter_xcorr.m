function PB_facetypewriter_SFC(subjID,experiment,day,time,unit1,unit2,doplot);

if nargin<7
    doplot = 1;
end

strctUnit1 = fnFindMat(subjID,day,experiment,unit1,'face_typewriter',time);
strctUnit2 = fnFindMat(subjID,day,experiment,unit2,'face_typewriter',time);


t1 = strctUnit1.m_afStimulusONTime;
t2 = strctUnit2.m_afStimulusONTime;
[junk i1 i2] = intersect(t1,t2);



if isempty(junk);
    return ;
end
raster1 = strctUnit1.m_a2bRaster_Valid(i1,:);
raster2 = strctUnit2.m_a2bRaster_Valid(i2,:);

trialtype = strctUnit2.m_aiStimulusIndexValid(i2);




[cc cc_control] = PB_xcorr(raster1,raster2,201:900,trialtype);
plot(-1600:1600,cc'-cc_control','linewidth',2);


