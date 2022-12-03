function ImageParameter = BarOrientation(ImageParameter);
ImageParameter.ImageKind = 6;
ImageParameter.Parameter_Name{1} = 'Nothing';
ImageParameter.Parameter_Value{1} = 1:1000;
for i = 1:length(ImageParameter.Parameter_Value{1});
    ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
end
ImageParameter.DefaultValue.StimulusON_MS = 1000;
ImageParameter.DefaultValue.StimulusOFF_MS = 0;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
