load('D:\PB\TwoImageResult\Rocco_TwoImageContrast_population.mat');
populationresult = finalresult.populationresult;

for i = 1:size(populationresult,2);
    tt = populationresult(:,i);
    tt = tt/mean(tt(:));
    response(:,i) = tt;
end

fr = mean(response,2);
strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImageContrast\TwoImageContrast.xml', false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

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

for i = 10:20:90
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i  & CondMatrix(:,5) == 2);
    ff((i+10)/20,1) = fr(index);
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,5) == 1);
    ff((i+10)/20,2) = fr(index);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 1 & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    ff((i+10)/20,3) = fr(index);
end

for i = 10:20:90
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,4) == i  & CondMatrix(:,5) == 2);
    oo((i+10)/20,1) = fr(index);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    oo((i+10)/20,2) = fr(index);
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,5) == 1);
    oo((i+10)/20,3) = fr(index);
end

figure;
for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

cc = {'ro-','go-','bo-','co-','ko-'}
%subplot(2,3,1);
% for i = 1:5
%     hold on;
%     plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
%     plot(100,oo(i,1),cc{i},'linewidth',3);
% end
ff1 = mean(ff(:,3)); oo1 = mean(oo(:,3));


y = resp(:);
[x1 x2] = meshgrid(0.1:0.2:0.9,0.1:0.2:0.9);
x = [x1(:) x2(:)];

rr = [oo1 ff1];
guess = [0.5 4];
newopts=optimset('Tolx', 1e-4, 'Tolfun', 1e-6, 'MaxIter', 1e5, ...
    'TolFun', 1e-6,'MaxFunEvals', 1e6, 'Display','notify');
options=optimset(optimset('fminsearch'),newopts);
cost_fun = inline('norm((y-(normmodel(x,a(1),a(2),rr))))','a','x','y','rr');
[a f1] = fminsearch(@(a) cost_fun(a,x,y,rr),guess,options);
a
fitResp = normmodel(x,a(1),a(2),rr);
fitResp = reshape(fitResp,5,5);

for i = 1:5
    subplot(2,5,i);
    plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
    hold on;
    
    plot(10:20:90,fitResp(i,:),[cc{i} '-']);
    subplot(2,5,5+i);
    plot(10:20:90,resp(:,i),cc{i},'linewidth',2);;
    hold on;
    
    plot(10:20:90,fitResp(:,i),[cc{i} '-']);
    
    
    
    
end



