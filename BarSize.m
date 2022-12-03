function ImageParameter = BarSize(ImageParameter);
        ImageParameter.ImageKind = 2;
        ImageParameter.Parameter_Name{1} = 'StimulusSizePix_X';
        ImageParameter.Parameter_Value{1} = [50:25:300]';
        ImageParameter.Parameter_Name{2} = 'StimulusSizePix_Y';
        ImageParameter.Parameter_Value{2} = [50:25:300]';

        for i = 1:length(ImageParameter.Parameter_Value{1});
            ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
        end
        
        
ImageParameter.DefaultValue.StimulusON_MS = 1000;
ImageParameter.DefaultValue.StimulusOFF_MS = 250;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];