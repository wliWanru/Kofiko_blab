function faceRF_populationAnalysis
Subject = 'Rocco';
ExpDate = '140814';
Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
matname = dir([Datafolder '*_*FaceRF2.mat']);
length(matname)
imall = zeros(301,301);
for i = 1:length(matname)
        strctUnit = load([Datafolder matname(i).name]);
        strctUnit = strctUnit.strctUnit;
        im = faceRF(strctUnit);
        imall = im/max(im(:)) + imall;
end
figure;
imshow(imall,[]);