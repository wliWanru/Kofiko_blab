clear;
close all;
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_013_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_001_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_002_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');%no clear tuning
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_006_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');%shape yellow;face green.
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_007_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');% all red prefered
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_010_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat');%red face; red shape; yellow animal (parrots)
%load('D:\Electrophysiology\150924\Processed\SingleUnitDataEntries\Ozomatli_2015-09-24_15-39-22_Exp_NaN_Ch_001_Unit_012_Passive_Fixation_New_color_objects_8hues_bw_0924_4.mat')

%load('D:\Electrophysiology\150930\Processed\SingleUnitDataEntries\Ozomatli_2015-09-30_14-20-27_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_color_objects_8_purehues_bw_0930_2.mat');
%load('D:\Electrophysiology\150930\Processed\SingleUnitDataEntries\Ozomatli_2015-09-30_14-20-27_Exp_NaN_Ch_001_Unit_014_Passive_Fixation_New_color_objects_8_purehues_bw_0930_2.mat');
%load('D:\Electrophysiology\150930\Processed\SingleUnitDataEntries\Ozomatli_2015-09-30_14-20-27_Exp_NaN_Ch_001_Unit_007_Passive_Fixation_New_color_objects_8_purehues_bw_0930_3.mat');
%load('D:\Electrophysiology\150930\Processed\SingleUnitDataEntries\Ozomatli_2015-09-30_14-20-27_Exp_NaN_Ch_001_Unit_008_Passive_Fixation_New_color_objects_8_purehues_bw_0930_3.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_002_Passive_Fixation_New_color_objects_8_purehues_bw_0930_4.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_005_Passive_Fixation_New_color_objects_8_purehues_bw_0930_1.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_006_Passive_Fixation_New_color_objects_8_purehues_bw_0930_2.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_010_Passive_Fixation_New_color_objects_8_purehues_bw_0930_2.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_016_Passive_Fixation_New_color_objects_8_purehues_bw_0930_2.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_014_Passive_Fixation_New_color_objects_8_purehues_bw_0930_4.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_019_Passive_Fixation_New_color_objects_8_purehues_bw_0930_4.mat');
%load('D:\Electrophysiology\151002\Processed\SingleUnitDataEntries\Ozomatli_2015-10-02_14-06-21_Exp_NaN_Ch_001_Unit_019_Passive_Fixation_New_color_objects_8_purehues_bw_0930_4.mat');
%load('D:\PB\EphysData\Fez\Test\151003\RAW\..\Processed\SingleUnitDataEntries\Fez_2015-10-03_17-01-17_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_color_objects_8_purehues_bw_0930.mat');
load('D:\PB\EphysData\Fez\Test\151005\RAW\..\Processed\SingleUnitDataEntries\Fez_2015-10-05_15-49-50_Exp_NaN_Ch_001_Unit_011_Passive_Fixation_New_color_objects_8_purehues_bw_0930.mat');
k=1;

for top=1:1
figure;
for k=1:83
    a0(1:2:19990)=1;
    a0(2:2:19990)=0;
uv=[];
uv(:,1)=a0(1:2:end);
uv(:,2)=a0(2:2:end);

UVt=(uv(:,1).^2+uv(:,2).^2).^0.5;
[I,B]=sort(UVt);
uvk=uv(B(round(end/3):end),:);
%figure;scatter(uvk(:,1),uvk(:,2));
athe=atan(uvk(:,2)./uvk(:,1));
athe(uvk(:,1)<0)=athe(uvk(:,1)<0)+pi;
spq(1:1000,k)=athe(randi(size(athe,1),[1000 1]));
sp(k)=std(athe);
sq(k)=mean(athe);
%figure;plot(athe);
%for j=-pi/2:pi/50:pi/2*3-pi/50
suo(1:100)=0;
for j=1:size(athe,1)    
    ak=(athe(j)+pi/2)/(2*pi)*100;
    bk=floor(ak)+1;
    suo(bk)=suo(bk)+1;
end
%hold('all');
subplot(9,10,k);
plot(-pi/2+pi/100:pi/50:3*pi/2,suo);
xlim([-pi/2 pi/2*3]);
end
figure;plot(sq);
figure;plot(sp<pi/4);
figure;plot(sq(sp<pi/4));
end


hface=1:11;
monkey=[14:15 44 53 54 66];
abody=[16 25:26 32:33 36 42:43 64:65 67:68 71 20:24 55:58 27:30 40];
fruit=[12:13 17:19 34 37:39 41 59:61 70];
magic=45:52;
shape=[31 35 62:63 69 72:74];
shapel=[31 35 62:63 69];
%shapel=73:74;
shapeh=72:74;
scramble=75:83;

stimulusid=strctUnit.m_aiStimulusIndexValid;
raster=strctUnit.m_a2bRaster_Valid;
frr=mean(raster(:,250:500),2)*1000-mean(raster(:,180:250),2)*1000*0;
numtr(1:max(stimulusid))=0;
ni=length(stimulusid);
k0=randi(20);
for i=1:size(frr,1)
    i2=mod(i-1,ni)+1;
    numtr(stimulusid(i2))=numtr(stimulusid(i2))+1;
    frtr(stimulusid(i2),numtr(stimulusid(i2)))=frr(i);
end
%frtrial=mean(raster(:,250:450),2);
frs=strctUnit.m_a2fAvgFirintRate_Stimulus;
%figure;plot(mean(fr,1));
%fr=mean(frs(:,250:420),2);
for i=1:max(stimulusid)
    if numtr(i)==0
        fr3(i)=0;
    else
        fr3(i)=mean(frtr(i,1:numtr(i)));
        fro(i)=std(frtr(i,1:numtr(i)))/sqrt(numtr(i)-1);
    end
end
fr=fr3(1:max(stimulusid))';
%figure;plot(mean(raster,1));
%hold('all');
%lo=mean(raster(2001:2100,:),1);
%ws=50;
%plot(filter(ones(1,ws)/ws,1,lo));
%frr=mean(raster(:,330:550),2)*1000;


afr=strctUnit.m_afAvgFirintRate_Stimulus;
afr=fr;
atk=reshape(afr,83,10);
atksd=reshape(fro,83,10);
figure;imshow(atk',[]);
figure;
for j=1:9
    subplot(3,3,j);
    plot(atk(:,j));
end
figure;subplot(1,2,1);plot(mean(atk(:,2:9),2));subplot(1,2,2);plot(mean(atk(:,1),2));
figure;plot(mean(atk(:,1:9),1));
figure;subplot(2,4,1);
plot(mean(atk(hface,1:9),1));
subplot(2,4,2);plot(mean(atk(monkey,1:9),1));
subplot(2,4,3);plot(mean(atk(abody,1:9),1));
subplot(2,4,4);plot(mean(atk(fruit,1:9),1));
subplot(2,4,5);plot(mean(atk(shape,1:9),1));
subplot(2,4,6);plot(mean(atk(scramble,1:9),1));
subplot(2,4,7);plot(mean(atk(magic,1:9),1));
figure;plot(atk(1:11,1:9)');
lko(1:9)=mean(atk(shape,9));
hold('all');plot(0:8,lko);
figure;
for j=1:30
    subplot(6,5,j);
    errorbar(0:8,atk(j,1:9),atksd(j,1:9),'MarkerSize',20,'Marker','.');
    lko(1:9)=mean(atk(shape,9));
    hold('all');plot(0:8,lko);
    xlim([-0.5 8.5]);
    ylim([-1 max(max(atk))]);
end
figure;
for j=1:30
    subplot(6,5,j);
    errorbar(0:8,atk(j+30,1:9),atksd(j,1:9),'MarkerSize',20,'Marker','.');
        lko(1:9)=mean(atk(shape,9));
    hold('all');plot(0:8,lko);
        xlim([-0.5 8.5]);
    ylim([-1 max(max(atk))]);
end
figure;
for j=1:22
    subplot(6,5,j);
    errorbar(0:8,atk(j+60,1:9),atksd(j,1:9),'MarkerSize',20,'Marker','.');
        lko(1:9)=mean(atk(shape,9));
    hold('all');plot(0:8,lko);
        xlim([-0.5 8.5]);
    ylim([-1 max(max(atk))]);
end


for j=1:83
    atu=atk(j,1:8);
    so(j,1:2)=0;
    for m=1:8
      so(j,1)=so(j,1)+cos(sq(j)-pi/4*(m-1))*atu(m);
      so(j,2)=so(j,2)+sin(sq(j)-pi/4*(m-1))*atu(m);
    end
    so(j,:)=so(j,:)/sum(atu);
end
figure;scatter(so(:,1),so(:,2));
for j=1:83
    %atu=atk(j,1:8);
    atu(2:8)=0;atu(1)=1;
    sog(j,1:2)=0;
    for m=1:8
      for k=1:1000  
        sog(j,1)=sog(j,1)+cos(spq(k,j)-pi/4*(m-1))*atu(m);
        sog(j,2)=sog(j,2)+sin(spq(k,j)-pi/4*(m-1))*atu(m);
      end
    end
    sog(j,:)=sog(j,:)/sum(atu)/1000;
end

for j=1:83
    atu=atk(j,1:8);
    %atu(2:8)=0;atu(1)=1;
    so(j,1:2)=0;
    for m=1:8
      for k=1:1000  
        so(j,1)=so(j,1)+cos(spq(k,j)-pi/4*(m-1))*atu(m);
        so(j,2)=so(j,2)+sin(spq(k,j)-pi/4*(m-1))*atu(m);
      end
    end
    so(j,:)=so(j,:)/sum(atu)/1000;
end
figure;scatter(so(:,1),so(:,2));
figure;scatter(so(sp<pi/8,1),so(sp<pi/8,2));
pure=sp<pi*2;
figure;hold('all');%scatter(so(:,1),so(:,2));
kl(1:83)=0;
kl(hface)=1;
scatter(so(kl==1&pure,1),so(kl==1&pure,2));
kl(1:83)=0;
kl(shape)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
kl(1:83)=0;
kl(monkey)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
kl(1:83)=0;
kl(fruit)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
kl(1:83)=0;
kl(abody)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
kl(1:83)=0;
kl(magic)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
kl(1:83)=0;
kl(scramble)=1;
scatter(so(kl&pure,1),so(kl&pure,2));
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);
kl(1:83)=0;
kl(shape)=1;

figure;
subplot(2,3,1);
hold('all');
sos=so(shapel,:);
xui=mean(sos(mean(sos,2)<1000,:),1);
scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(hface)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,2);
hold('all');
scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(monkey)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,3);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(abody)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);

subplot(2,3,4);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(fruit)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);

subplot(2,3,5);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(shapeh)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,6);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(scramble)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
for j=1:size(som,1)
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0 0 0]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);



figure;
subplot(2,3,1);
hold('all');
%sos=so(shapel,:);
%xui=mean(sos(mean(sos,2)<1000,:),1);
scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(hface)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,2);
hold('all');
scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(monkey)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,3);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(abody)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);

subplot(2,3,4);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(fruit)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);

subplot(2,3,5);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(shapeh)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);


subplot(2,3,6);
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(scramble)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(kl==1,:);
som2=sog(kl==1,:);
for j=1:size(som,1)
    plot([som2(j,1) som(j,1)],[som2(j,2) som(j,2)],'color',[0 0 0]);
    plot([xui(1) som(j,1)],[xui(2) som(j,2)],'color',[0.5 0.5 0.5]);
end
scatter(som(:,1),som(:,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(:,1),som2(:,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);

figure;
hold('all');

scatter(xui(1),xui(2),'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0]);
kl(1:83)=0;
kl(scramble)=1;
%scatter(so(kl==1,1),so(kl==1,2));
som=so(:,:);
som2=so(:,:);
for j=1:8
    plot([som2(74+j,1) som((j-1)*10+1,1)],[som2(74+j,2) som((j-1)*10+1,2)],'color',[0 0 0]);
    plot([xui(1) som2(74+j,1)],[xui(2) som2(74+j,2)],'color',[0.5 0.5 0.5]);
end
tp=1:8;
scatter(som((tp-1)*10+1,1),som((tp-1)*10+1,2),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[0 0 0]);
scatter(som2(74+tp,1),som2(74+tp,2),'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0]);
for j=0.2:0.2:1
    xu=0:0.01:2*pi;
    plot(cos(xu)*j,sin(xu)*j,'color',[0 0 0]);
end
xlim([-1 1]);ylim([-1 1]);




 figure;subplot(2,1,1);plot(1:length(hface),std(atk(hface,1:8),0,2),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),std(atk(monkey,1:8),0,2),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),std(atk(abody,1:8),0,2),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),std(atk(fruit,1:8),0,2),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),std(atk(shape,1:8),0,2),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),std(atk(scramble,1:8),0,2),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),std(atk(magic,1:8),0,2),'DisplayName','magiccube');
  
subplot(2,1,2);plot(1:length(hface),mean(atk(hface,1:8),2),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),mean(atk(monkey,1:8),2),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),mean(atk(abody,1:8),2),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),mean(atk(fruit,1:8),2),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),mean(atk(shape,1:8),2),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),mean(atk(scramble,1:8),2),'DisplayName','scramble');
plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),mean(atk(magic,1:8),2),'DisplayName','magiccube');
plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic)+length(shape),atk(shape,9),'DisplayName','gray');
  
figure;
hold('all');
 plot(1+length(hface):length(hface)+length(monkey),std(atk(monkey,1:8),0,2)./mean(atk(monkey,1:8),2),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),std(atk(abody,1:8),0,2)./mean(atk(abody,1:8),2),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),std(atk(fruit,1:8),0,2)./mean(atk(fruit,1:8),2),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),std(atk(shape,1:8),0,2)./mean(atk(shape,1:8),2),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),std(atk(scramble,1:8),0,2)./mean(atk(scramble,1:8),2),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),std(atk(magic,1:8),0,2)./mean(atk(magic,1:8),2),'DisplayName','magiccube');

  figure;errorbar(1:length(hface),mean(atk(hface,1:8),2),std(atk(hface,1:8),0,2),'DisplayName','face');
 hold('all');
errorbar(1+length(hface):length(hface)+length(monkey),mean(atk(monkey,1:8),2),std(atk(monkey,1:8),0,2),'DisplayName','monkey');
errorbar(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),mean(atk(abody,1:8),2),std(atk(abody,1:8),0,2),'DisplayName','animalbody');
errorbar(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),mean(atk(fruit,1:8),2),std(atk(fruit,1:8),0,2),'DisplayName','fruit');
errorbar(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),mean(atk(shape,1:8),2),std(atk(shape,1:8),0,2),'DisplayName','shape');
errorbar(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),mean(atk(scramble,1:8),2),std(atk(scramble,1:8),0,2),'DisplayName','scramble');
errorbar(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),mean(atk(magic,1:8),2),std(atk(magic,1:8),0,2),'DisplayName','magiccube');

 figure;
 subplot(4,1,1);
 plot(1:length(hface),atk(hface,10),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),atk(monkey,10),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),atk(abody,10),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),atk(fruit,10),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),atk(shape,10),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),atk(scramble,10),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),atk(magic,10),'DisplayName','magiccube');
sp=4;
  subplot(4,1,2);
 plot(1:length(hface),atk(hface,sp),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),atk(monkey,sp),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),atk(abody,sp),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),atk(fruit,sp),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),atk(shape,sp),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),atk(scramble,sp),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),atk(magic,sp),'DisplayName','magiccube');


 sp=7;
  subplot(4,1,3);
 plot(1:length(hface),atk(hface,sp),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),atk(monkey,sp),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),atk(abody,sp),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),atk(fruit,sp),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),atk(shape,sp),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),atk(scramble,sp),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),atk(magic,sp),'DisplayName','magiccube');
 
subplot(4,1,4);
plot(1:length(hface),atk(hface,9),'DisplayName','face');
 hold('all');
 plot(1+length(hface):length(hface)+length(monkey),atk(monkey,9),'DisplayName','monkey');
 plot(1+length(hface)+length(monkey):length(hface)+length(monkey)+length(abody),atk(abody,9),'DisplayName','animalbody');
 plot(1+length(hface)+length(monkey)+length(abody):length(hface)+length(monkey)+length(abody)+length(fruit),atk(fruit,9),'DisplayName','fruit');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape),atk(shape,9),'DisplayName','shape');
 plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble),atk(scramble,9),'DisplayName','scramble');
  plot(1+length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble):length(hface)+length(monkey)+length(abody)+length(fruit)+length(shape)+length(scramble)+length(magic),atk(magic,9),'DisplayName','magiccube');
figure;scatter(sp,std(atk(:,1:8),0,2)')
corr(sp',std(atk(:,1:8),0,2))
corr(sp(abody)',std(atk(abody,1:8),0,2))