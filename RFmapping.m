function ImageParameter = RFmapping(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.SurfaceColor = 255;
ImageParameter.Parameter_Name{1} = 'StimulusPos';
ImageParameter.Orientation = 0;
dist = -200:25:200;
k = 1;
for i = 1:length(dist)
    for j = 1:length(dist)
        pp(k,:) = [ImageParameter.StimulusPos] + [dist(i) dist(j)];
        
        ImageParameter.Cond_Name{k} = [num2str(dist(i)) '_' num2str(dist(j))];
        k = k + 1;
    end
end
ImageParameter.Parameter_Value{1} = pp;

ImageParameter.DefaultValue.StimulusON_MS = 50;
ImageParameter.DefaultValue.StimulusOFF_MS = 50;
ImageParameter.DefaultValue.StimulusSizePix_X = 50;
ImageParameter.DefaultValue.StimulusSizePix_Y = 50;
ImageParameter.DefaultValue.Orientation = 0;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
