function ImageParameter = V4DorisNoise(ImageParameter);
ImageParameter.ImageKind = 7;
ImageParameter.Parameter_Name{1} = 'Nothing';
ImageParameter.Parameter_Value{1} = 1:1000;
% for i = 1:length(ImageParameter.Parameter_Value{1});
%     ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
% end
ImageParameter.DefaultValue.StimulusON_MS = 100;
ImageParameter.DefaultValue.StimulusOFF_MS = 0;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
ImageParameter.STA.Name = 'DorisV4';
ImageParameter.TrialToConditionMode = 2;