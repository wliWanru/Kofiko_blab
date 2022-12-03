function output = OcclusionAnalysis(mat)
try
    stimarea = [60 220];
    
    usePB = 1;
    strctUnit = load(mat);
    strctUnit = strctUnit.strctUnit;
    load('C:\PB\KofikoPB\trunk\strctDesign.mat');
    for i = 1:length(strctDesign.m_astrctMedia);
        cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    end
    %subjID = 'Rocco'; experiment = 'test'; foldername = '140827'; unitnumber = '008';
    % % if ~isempty(experiment)
    % %     matpath = ['C:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
    % % else
    % %     matpath = ['C:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
    % % end
    % % mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']);
    % % [matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']
    % % if isempty(mat)
    % %     strctUnit = [];
    % %     mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_TwoImage_*.mat']);
    % %     [matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']
    % %     if ~isempty(mat)
    % %         strctUnit = load([matpath mat(1).name]);
    % %         strctUnit = strctUnit.strctUnit;
    % %
    % %         %strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    % %         load('C:\PB\KofikoPB\trunk\strctDesign.mat');
    % %         for i = 1:length(strctDesign.m_astrctMedia);
    % %             cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    % %             filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    % %         end
    % %     else
    % %         output = nan;
    % %         return;
    % %     end
    % %
    % % else
    % %     strctUnit = load([matpath mat(1).name]);
    % %
    % %     strctUnit = strctUnit.strctUnit;
    % %
    % %     fid = fopen('\\192.168.50.15\StimulusSet\PB_TwoImages\twoimages.txt');
    % %     C = textscan(fid,'%s');
    % %     filename = C{1};
    % %     fclose(fid);
    % %
    % %
    % %
    % %
    % %     % strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    % %     % for i = 1:length(strctDesign.m_astrctMedia);
    % %     %     cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    % %     %     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    % %     % end
    % %
    % % end
    CondMatrix = zeros(length(filename),5);
    
    for i = 1:length(filename)
        fn = filename{i};
        xx = find(fn == '_');
        Name1 = fn(1:xx(1)-1);
        CondMatrix(i,1) = findcond(Name1);
        Name2 = fn(xx(1)+1:xx(2)-1);
        CondMatrix(i,2) = findcond(Name2);
        CC1 = fn(xx(2)+1:xx(2)+3);
        CondMatrix(i,3) = str2num(CC1(end-1:end));
        CC2 = fn(xx(3)+1:xx(3)+3);
        CondMatrix(i,4) = str2num(CC2(end-1:end));
        if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
            CondMatrix(i,5) = 1;
        else
            CondMatrix(i,5) = 2;
        end
    end
    
    for i = 1:7
        for j = 10:20:90
            CRFindex(i,(j+10)/20,1) = find(CondMatrix(:,1) == i & CondMatrix(:,2) == 0 & CondMatrix(:,3) == j & CondMatrix(:,5) == 2); % Center
            CRFindex(i,(j+10)/20,2) = find(CondMatrix(:,1) == i & CondMatrix(:,2) == 0 & CondMatrix(:,3) == j & CondMatrix(:,5) == 1); % Left
            CRFindex(i,(j+10)/20,3) = find(CondMatrix(:,2) == i & CondMatrix(:,1) == 0 & CondMatrix(:,4) == j & CondMatrix(:,5) == 1); % Right
        end
    end
    
    if exist('strctDesign')
        xx = size(strctDesign.m_a2bStimulusToCondition,1);
    else
        xx = length(filename);
    end
    
    if usePB
        [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, stimarea(1), stimarea(2));
        [strctUnit.m_afAvgStimulusResponseMinusBaseline, strctUnit.m_afAvgStimulusResponseMinusBaselineStd, aiCount] = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150,-25,25);
    else
        strctUnit.m_afAvgFirintRate_StimulusStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
        strctUnit.m_afAvgStimulusResponseMinusBaselineStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
        aiCount = ones(size(strctUnit.m_afAvgFirintRate_StimulusStd));
        strctUnit.m_afAvgStimulusResponseMinusBaseline = strctUnit.m_afAvgStimulusResponseMinusBaseline * 1000;
    end
    
    
    Single_Response = strctUnit.m_afAvgFirintRate_Stimulus(CRFindex);
    Single_Response_MinusBaseline = strctUnit.m_afAvgStimulusResponseMinusBaseline(CRFindex);
    
    
    
    
    
    count = 1;
    for i = 1:3
        for j = 4:6
            for k = 10:20:90
                index = find(CondMatrix(:,1) == i & CondMatrix(:,2) == j & CondMatrix(:,3) == k & CondMatrix(:,5) == 2);
                if ~isempty(index)
                    if length(index)>1
                        index = index(1);
                    end
                    Resp_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaseline(index)*1;
                    Resp_Predict_avg_mb(count) = Single_Response_MinusBaseline(i,(k+10)/20,1)*0.5 + Single_Response_MinusBaseline(j,(k+10)/20,1)*0.5;
                    Resp_Predict_PB_mb(count) = Single_Response_MinusBaseline(i,5,1)*k/100 + Single_Response_MinusBaseline(j,5,1)*(1-k/100);
                    Resp_std_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaselineStd(index)*1/sqrt(aiCount(index));
                    FaceResponse = Single_Response_MinusBaseline(i,(k+10)/20,1);
                    ObjectResponse = Single_Response_MinusBaseline(j,6-(k+10)/20,1);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    TwoImageResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline(index);
                    w_face_minusbaseline(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response_minusebasline(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    Resp(count) = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    Resp_Predict_avg(count) = Single_Response(i,(k+10)/20,1)*0.5 + Single_Response(j,(k+10)/20,1)*0.5;
                    Resp_Predict_PB(count) = Single_Response(i,5,1)*k/100 + Single_Response(j,5,1)*(1-k/100);
                    FaceResponse = Single_Response(i,(k+10)/20,1);
                    ObjectResponse = Single_Response(j,6-(k+10)/20,1);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    TwoImageResponse = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    w_face(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    count = count + 1;
                else
                    keyboard;
                end
            end
        end
    end
    snr = [10:20:90];
    
    
    legend('Center','left','right');
    
    tt = mean(Single_Response,3);
    CategoryResponse(1,:) = mean(tt(1:3,:)); % Face;
    CategoryResponse(2,:) = mean(tt(4:6,:)); % Object;
    CategoryResponse(3,:) = tt(7,:); % Noise
    tt = mean(Single_Response_MinusBaseline,3);
    CategoryResponse_MinusBaseline(1,:) = mean(tt(1:3,:)); % Face;
    CategoryResponse_MinusBaseline(2,:) = mean(tt(4:6,:)); % Object;
    CategoryResponse_MinusBaseline(3,:) = tt(7,:); % Noise
    
    r_twoimage = response(:,:,:,3);
    r_twoimage = reshape(r_twoimage,9,5);
    output(1,1,:) = [mean(r_twoimage)];
    face_twoimage = response(:,1,:,1);
    face_twoimage = reshape(face_twoimage,3,5);
    output(1,2,:) = [mean(face_twoimage)];
    
    obj_twoimage = response(1,:,:,2);
    obj_twoimage = reshape(obj_twoimage,3,5);
    output(1,3,:) = mean(obj_twoimage);
    % subplot(3,2,2);
    % r_twoimage = response_minusebasline(:,:,:,3);
    % r_twoimage = reshape(r_twoimage,12,5);
    % plot(snr,mean(r_twoimage),'ko--','linewidth',2);
    % hold on;
    % face_twoimage = response_minusebasline(:,1,:,1);
    % face_twoimage = reshape(face_twoimage,3,5);
    % plot(snr,mean(face_twoimage),'ro-','linewidth',2);
    % face_twoimage = response_minusebasline(1,:,:,2);
    % face_twoimage = reshape(face_twoimage,4,5);
    % plot(snr,mean(face_twoimage),'bo-','linewidth',2);
    
    
    % figure;
    % subplot(2,3,1);
    % bar(Resp,'k');
    % hold on;
    % plot(Resp_Predict_avg,'b-','linewidth',2);
    % plot(Resp_Predict_PB,'r-','linewidth',2);
    %
    %
    % subplot(2,3,2);
    % errorbar(1:length(Resp_mb),Resp_mb,Resp_std_mb,'k');
    % hold on;
    % plot(Resp_Predict_avg_mb,'b-','linewidth',2);
    % plot(Resp_Predict_PB_mb,'r-','linewidth',2);
    %
    % subplot(2,3,3);
    % plot(Resp,Resp_Predict_avg,'bo');
    % hold on;
    % plot(Resp,Resp_Predict_PB,'ro');
    
    mean(aiCount)
    %
    k = 1;
    for i = 1:3
        for j = 4:7
            for k = 10:20:90
                index = find(CondMatrix(:,1) == i & CondMatrix(:,2) == j & CondMatrix(:,3) == k & CondMatrix(:,5) == 1);
                if ~isempty(index)
                    %                 Resp_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaseline(index)*1;
                    %                 Resp_Predict_avg_mb(count) = Single_Response_MinusBaseline(i,(k+10)/20,1)*0.5 + Single_Response_MinusBaseline(j,(k+10)/20,1)*0.5;
                    %                 Resp_Predict_PB_mb(count) = Single_Response_MinusBaseline(i,5,1)*k/100 + Single_Response_MinusBaseline(j,5,1)*(1-k/100);
                    %                 Resp_std_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaselineStd(index)*1/sqrt(aiCount(index));
                    FaceResponse = Single_Response_MinusBaseline(i,(k+10)/20,2);
                    ObjectResponse = Single_Response_MinusBaseline(j,6-(k+10)/20,3);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    %                 TwoImageResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline(index);
                    w_face_minusbaseline_fl(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response_minusebasline_fl(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    Resp(count) = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    Resp_Predict_avg(count) = Single_Response(i,(k+10)/20,1)*0.5 + Single_Response(j,(k+10)/20,1)*0.5;
                    Resp_Predict_PB(count) = Single_Response(i,5,1)*k/100 + Single_Response(j,5,1)*(1-k/100);
                    FaceResponse = Single_Response(i,(k+10)/20,2);
                    ObjectResponse = Single_Response(j,6-(k+10)/20,3);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    TwoImageResponse = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    w_face_fl(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response_fl(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    count = count + 1;
                else
                    keyboard;
                end
            end
        end
    end
    
    %subplot(1,3,2);
    r_twoimage = response_fl(:,:,:,3);
    r_twoimage = reshape(r_twoimage,12,5);
    %plot(snr,mean(r_twoimage),'ko--','linewidth',2);
    output(2,1,:) = [mean(r_twoimage)];
    face_twoimage = response_fl(:,1,:,1);
    face_twoimage = reshape(face_twoimage,3,5);
    %plot(snr,mean(face_twoimage),'ro-','linewidth',2);
    output(2,2,:) = [mean(face_twoimage)];
    
    obj_twoimage = response_fl(1,:,:,2);
    obj_twoimage = reshape(obj_twoimage,4,5);
    %plot(snr,mean(obj_twoimage),'bo-','linewidth',2);
    output(2,3,:) = mean(obj_twoimage);
    % subplot(3,2,4);
    % r_twoimage = response_minusebasline_fl(:,:,:,3);
    % r_twoimage = reshape(r_twoimage,12,5);
    % plot(snr,mean(r_twoimage),'ko--','linewidth',2);
    % hold on;
    % face_twoimage = response_minusebasline_fl(:,1,:,1);
    % face_twoimage = reshape(face_twoimage,3,5);
    % plot(snr,mean(face_twoimage),'ro-','linewidth',2);
    % face_twoimage = response_minusebasline_fl(1,:,:,2);
    % face_twoimage = reshape(face_twoimage,4,5);
    % plot(snr,mean(face_twoimage),'bo-','linewidth',2);
    
    k = 1;
    for i = 1:3
        for j = 4:7
            for k = 10:20:90
                index = find(CondMatrix(:,1) == j & CondMatrix(:,2) == i & CondMatrix(:,4) == k & CondMatrix(:,5) == 1);
                if ~isempty(index)
                    Resp_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaseline(index)*1;
                    Resp_Predict_avg_mb(count) = Single_Response_MinusBaseline(i,(k+10)/20,1)*0.5 + Single_Response_MinusBaseline(j,(k+10)/20,1)*0.5;
                    Resp_Predict_PB_mb(count) = Single_Response_MinusBaseline(i,5,1)*k/100 + Single_Response_MinusBaseline(j,5,1)*(1-k/100);
                    Resp_std_mb(count) = strctUnit.m_afAvgStimulusResponseMinusBaselineStd(index)*1/sqrt(aiCount(index));
                    FaceResponse = Single_Response_MinusBaseline(i,(k+10)/20,3);
                    ObjectResponse = Single_Response_MinusBaseline(j,6-(k+10)/20,2);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    TwoImageResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline(index);
                    w_face_minusbaseline_fr(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response_minusebasline_fr(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    Resp(count) = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    Resp_Predict_avg(count) = Single_Response(i,(k+10)/20,1)*0.5 + Single_Response(j,(k+10)/20,1)*0.5;
                    Resp_Predict_PB(count) = Single_Response(i,5,1)*k/100 + Single_Response(j,5,1)*(1-k/100);
                    FaceResponse = Single_Response(i,(k+10)/20,3);
                    ObjectResponse = Single_Response(j,6-(k+10)/20,2);
                    %                 FaceResponse = mean(Single_Response_MinusBaseline(i,:,1));
                    %                 ObjectResponse = mean(Single_Response_MinusBaseline(j,:,1));
                    TwoImageResponse = strctUnit.m_afAvgFirintRate_Stimulus(index);
                    w_face_fr(i,j-3,(k+10)/20) = (TwoImageResponse - ObjectResponse)/(FaceResponse - ObjectResponse);
                    response_fr(i,j-3,(k+10)/20,1:3) = [FaceResponse ObjectResponse TwoImageResponse];
                    
                    count = count + 1;
                else
                    keyboard;
                end
            end
        end
    end
    
    r_twoimage = response_fr(:,:,:,3);
    r_twoimage = reshape(r_twoimage,12,5);
    output(3,1,:) = [mean(r_twoimage)];
    face_twoimage = response_fr(:,1,:,1);
    face_twoimage = reshape(face_twoimage,3,5);
    output(3,2,:) = [mean(face_twoimage)];
    
    obj_twoimage = response_fr(1,:,:,2);
    obj_twoimage = reshape(obj_twoimage,4,5);
    output(3,3,:) = mean(obj_twoimage);
    
    % subplot(3,2,6);
    % r_twoimage = response_minusebasline_fr(:,:,:,3);
    % r_twoimage = reshape(r_twoimage,12,5);
    % plot(snr,mean(r_twoimage),'ko--','linewidth',2);
    % hold on;
    % face_twoimage = response_minusebasline_fr(:,1,:,1);
    % face_twoimage = reshape(face_twoimage,3,5);
    % plot(snr,mean(face_twoimage),'ro-','linewidth',2);
    % face_twoimage = response_minusebasline_fr(1,:,:,2);
    % face_twoimage = reshape(face_twoimage,4,5);
    % plot(snr,mean(face_twoimage),'bo-','linewidth',2);
    
    
    % set(gcf,'Position',[ 438   489   921   253]);
    % epsfilename = [matpath '..\figure\' unitnumber '_PB_TwoImage.eps'];
    % if exist([matpath '..\figure\'],'dir');
    % else
    %     mkdir([matpath '..\figure\']);
    % end
    % set(gcf, 'PaperPositionMode', 'auto')
    % print('-depsc',epsfilename);
catch
    output = nan;
end

