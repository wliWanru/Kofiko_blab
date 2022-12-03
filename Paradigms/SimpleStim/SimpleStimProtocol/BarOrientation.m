function ImageParameter = BarOrientation(ImageParameter);
ImageParameter.ImageKind = 2;
ImageParameter.Parameter_Name{1} = 'Orientation';
ImageParameter.Parameter_Value{1} = [0:15:345]';
for i = 1:length(ImageParameter.Parameter_Value{1});
    ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
end
ImageParameter.DefaultValue.StimulusON_MS = 1000;
ImageParameter.DefaultValue.StimulusOFF_MS = 250;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
ImageParameter.DefaultValue.StimulusSizePix_X = 200;
ImageParameter.DefaultValue.StimulusSizePix_Y = 200;
