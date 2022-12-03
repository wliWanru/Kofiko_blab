% -------------------------------------------------------------------------
% SpikeTriggeredAnalysisTutorial.m
%
% This tutorial demonstrates how spike-triggered analysis can
% be used to recover functional models in white-noise experiments.
%
% For more details, see for example: 
%   Simoncelli et al. (2004) Characterization of neural responses with 
%   stochastic stimuli.  In: The New Cognitive Sciences, 3rd edition 
%   (ed. Gazzaniga). MIT Press.
%
% (C) Hiroki Asari (2009-2013), Meister Lab, Harvard University / Caltech
%     Adapted from Nicole Rust (2004).
% -------------------------------------------------------------------------

clear all;close all;

%% Gaussian white noise stimulus:
% Bar flickers with the intensities drawn from a Gaussian distribution.
nT = 11; % window length for stimulus history
nX = 15; % stimulus width
nStim = 1e5; % total stimulus length
stim = randn(nStim,nX);
stim = stim./max(max(abs(stim))); % normalization

% Plot the stimulus (with the stimulus history over the last nT frames).
figure
for n=nT:nT+10, % animation for 10 frames
    subplot(2,2,1);imagesc(stim(n,:),[-1 1]); colormap(gray);
    title('Stimulus on this frame');xlabel('space (bar number)');
    set(gca,'YTickLabel',[]);
    
    subplot(1,2,2);imagesc(flipud(stim(n-nT+1:n,:)),[-1 1]);
    title(['Stimuli presented on the last ',num2str(nT),' frames']);
    set(gca,'YTickLabel','0|-1|-2|-3|-4|-5|-6|-7|-8|-9|-10');
    xlabel('space (bar number)');ylabel('time (frames)');
    
    pause(0.25);
end;

% Our model neuron will depend on the stimulus history over the nT frames 
% preceeding a spike. To model the cell, we begin by constructing a matrix 
% whose rows contain the nT-frame bar history at successive points in time:
allStim = zeros(size(stim,1)-nT+1, nX*nT);
for n = 1:size(allStim,1)
  allStim(n, :) = reshape(stim(n:n+nT-1,:),[1,nX*nT]);
end


%% LN MODEL 1:
% Linear spatio-temporal filter followed by nonlinearity.  The linear
% filter is given by a Gabor function in space, and cosine function with 
% logarithmic scale in time.

maxX = 1;   %Half-width of Gabor (pixels)
sx = 0.5;   %standard deviation of Gaussian
sfx = 1.1;  %spatial freqency of carrier
xFilt = linspace(-maxX,maxX,nX);
xFilt = cos(2*pi*sfx*xFilt).*exp(-xFilt.^2/sx.^2);

st = 2; % temporal spacing parameters
tFilt = sin(2*pi*(logspace(0,st,nT)-1)'/(10^st-1));

xtFilt = tFilt*xFilt; % spatio-temporal filter
xtFilt = xtFilt/norm(xtFilt); % normalization

% The response is modeled by first projecting the stimulus onto the linear
% spatio-temporal filter, and then by thresholding (approx. poisson).  
% Thus the nonlinearity here is expressed as half-wave rectification.
genpot = [rand(nT-1,1)-.5; allStim*xtFilt(:)];
genpot = genpot/max(genpot); % spike-generating function

spikes = (rand(size(genpot,1),1) < genpot); % thresholding

% Plot the spike-generating function and spikes for the first 1000 time points.
figure;hold on;
plot(genpot(1:1000));
plot(find(spikes(1:1000)),genpot(spikes(1:1000)),'r.');
title([num2str(sum(spikes)), ' spikes in total']);
legend({'spike-generating function','spikes'});


%% SPIKE-TRIGGERED AVERAGE
% We begin by isolating the stimuli that produced spikes, then take the
% average of the spike-triggered stimulus ensembles.  Note that we can't use 
% the first few spikes because they don't have a complete stimulus history.
spikeStim = allStim(spikes(nT:end),:);

sta = mean(spikeStim,1); % spike-triggered average stimulus
sta = reshape(sta,nT,nX)/norm(sta); % normalization

figure;
subplot(2,2,1);imagesc(xtFilt);title('original filter');axis off
subplot(2,2,2);imagesc(sta);title('STA: estimated filter');axis off
colormap(gray);


%% RECOVERING THE NONLINEARITY
%
% The nonlinearity can be described by a conditional propability
% distribution: P(spikes|stimulus).  The posterior can be computed as the 
% ratio of the likelihood to the prior (Bayes rule):
%   P(spikes|stimulus) ~ P(stimulus|spikes)/P(stimulus).
% That is, we reconstruct the firing rate as a function of the output of 
% the linear filter by taking the ratio of the spiking stimuli and all 
% stimuli projected onto the filter.


binedg = -1:1/20:1;
bins = binedg(1:end-1)+diff(binedg(1:2))/2;

[rawhist] = histc(allStim*sta(:), binedg); % histogram of all stimuli projected onto STA
[spkhist] = histc(spikeStim*sta(:), binedg); % that of spike-triggered stimuli projected onto STA

NL = (spkhist(1:end-1)./rawhist(1:end-1))'; % nonlinearity

subplot(2,2,3);hold on;
plot(bins,rawhist(1:end-1)/size(allStim,1),'r'); 
text(-.75,.15,'P(stimulus)','Color',[1 0 0]);
plot(bins,spkhist(1:end-1)/size(spikeStim,1),'g');
text(-.75,.175,'P(stimulus|spikes)','Color',[0 1 0]);
ylabel('Probability');

subplot(2,2,4);
plot(bins, NL,'-o');ylabel('spikes/frame'); % P(spikes|stimulus)
title('estimated nonlinearity');

% We now have a full LN model: the linear filter (STA) followed by the 
% nonlinearity (half-wave rectification)!!




%% LN model 2:
% STA works fine with the above simple model.  However, there are many
% occations where STA does not work.  For example, let's assume that the
% nonolinearity is quadratic.
genpot2 = [rand(nT-1,1)-.5; allStim*xtFilt(:)].^2;
genpot2 = genpot2/max(genpot2); % spike-generating function

spikes2 = (rand(size(genpot2,1),1) < genpot2);

% Plot the spike-generating function, and spikes for the first 1000 time points.
figure;hold on;
plot(genpot2(1:1000));
plot(find(spikes2(1:1000)),genpot2(spikes2(1:1000)),'r.');
title([num2str(sum(spikes2)), ' spikes in total']);


%% Let's see how spike triggered average looks:
spikeStim2 = allStim(spikes2(nT:end),:);

sta2 = reshape(mean(spikeStim2,1),nT,nX);

mx = max(abs(xtFilt(:)));
figure;colormap(gray);
subplot(2,3,1);imagesc(xtFilt,[-mx mx]);axis off;title('original filter');
subplot(2,3,4);imagesc(sta2,[-mx mx]);axis off;title('STA');

% As you can see, STA is essentially zero.


%% PCA ON SPIKE-TRIGGERED STIMULUS ENSEMBLES
% The dimensionality of our space (D) is defined as the number of bars (nX) 
% multiplied by the number of time bins (nT). The stimulus space can be 
% envisioned as a D dimensional space and each nX*nT stimulus block can be 
% envisioned as a vector in that space.  An "axis" in this space
% corresponds to a particular instantiation of the stimulus on once side of
% the origin, the inverse of that stimulus on the other side of the
% origin, and all points in between. A principal components analysis (PCA) 
% on spike-triggered stimulus (STS) ensembles returns D orthogonal vectors 
% (the eigenvectors) and the variance along each vectors (the eigenvalues).   

[pc,spkProj2,eval] = princomp(spikeStim2,'econ');

% The stimuli that produced spikes form a cloud of points in this high
% dimensional space. PCA fits a D dimensional hyperellipse to this cloud.
% Given no correlation between the stimulus and the spikes and an infinite 
% amount of data, the vectors will be assigned randomly and the variance 
% along each axis will be the variance of the stimulus (PCA will fit a
% hypersphere to the spike-triggered stimuli).  Given no correlation
% between the stimulus and the spikes and a finite amount of data, some axes
% will have a variance slightly higher than the data and some lower, just by 
% chance.  We are interested in vectors along which the variance is significantly
% different than these chance correlations.  Normally, we would use bootstrap
% hypothesis testing to confirm which filters have a variance significantly
% different than the chance distribution.  But for our purposes here, a
% thumb-rule will suffice: when the filters are plotted in rank order,
% those that "pop-off" of the distribution are significant.  

% Plot the eigenvalues: 
mxx = max(max(eval)).*1.3;
subplot(2,3,2);  plot(eval,'.'); axis([0 nX*nT 0 mxx])
xlabel('rank number');ylabel('eigenvalue (variance)');title('PCA on STS');

% As you can see, the first eigenvalue is significant, suggesting that we 
% have one significant filter:
subplot(2,3,5);imagesc(reshape(pc(:,1),nT,nX),[-mx mx]);
axis off;title('Estimated filter');

% The original and estimated filters can have different signs because our 
% nonlinearity function is quadratic:

rawhist2 = histc(allStim*pc(:,1), binedg);
spkhist2 = histc(spkProj2(:,1), binedg);
NL2 = (spkhist2(1:end-1)./rawhist2(1:end-1))';

subplot(2,3,3);hold on;
plot(bins,rawhist2(1:end-1)/size(allStim,1),'r'); % P(stimulus)
plot(bins,spkhist2(1:end-1)/size(spkProj2,1),'g'); % P(stimulus|spikes)
ylabel('Probability');

subplot(2,3,6);
plot(bins, NL2,'-o');ylabel('spikes/frame'); % P(spikes|stimulus)
title('estimated nonlinearity');




%% LN model 3:
%
% Other common methods for estimating linear filters include 
% spike-triggered covariance (STC) and maximally-informative dimension
% (MID).  The STC exploits the second-order statistics (and so essentially 
% the same as the above PCA-based analysis), and the MID is based on the 
% information theory.  Note that we need more data as we examine 
% higher-order statistics.
% 
% The key idea here is that we assume that the spike-triggered stimulus 
% (STS) distribution is different from the entire stimulus distribution,
% and so by identifying and characterizing this difference, we hope to
% understand the response properties of neurons.  Thus any clustering
% algorith should work in principle.  However, no model is perfect.  
% Therefore, we have to be very careful about interpreting the 
% model and the filters.
%
% With this caveat in mind, let's see how STC works on the following 
% 2-LN model:

% excitatory fast narrow component         and         inhibitory slow wide component 
maxX1 = 2; sx1 = 0.25; st1 = 2;                        maxX2 = 1; sx2 = 0.5; st2 = 0.25;
xFilt1 = exp(-linspace(-maxX1,maxX1,nX).^2/sx1.^2);    xFilt2 = exp(-linspace(-maxX2,maxX2,nX).^2/sx2.^2);
tFilt1 = sin(2*pi*(logspace(0,st1,nT)-1)'/(10^st1-1)); tFilt2 = sin(2*pi*(logspace(0,st2,nT)-1)'/(10^st2-1));
xtFilt1 = tFilt1*xFilt1;                               xtFilt2 = tFilt2*xFilt2;
xtFilt1 = xtFilt1/norm(xtFilt1);                       xtFilt2 = xtFilt2/norm(xtFilt2);

% The response is modeled by first projecting the stimulus onto each of the 
% two filters, squaring the second output, and taking the difference.

genpot3 = [rand(nT-1,1)-.5; (allStim*xtFilt1(:)) - 2*(allStim*xtFilt2(:)).^2];
genpot3 = genpot3/max(genpot3); % spike-generating function
spikes3 = (rand(size(genpot3,1),1) < genpot3); % thresholding

% Plot the spike-generating function and spikes for the first 1000 time points.
figure;hold on;
plot(genpot3(1:1000));
plot(find(spikes3(1:1000)),genpot3(spikes3(1:1000)),'r.');
title([num2str(sum(spikes3)), ' spikes in total']);


%% SPIKE-TRIGGERED COVARIANCE 
% Let's see how STA works first.
spikeStim3 = allStim(spikes3(nT:end),:);
sta3 = reshape(mean(spikeStim3,1),nT,nX);
sta3 = sta3/norm(sta3); % normalization

mx = max(abs([xtFilt1(:);xtFilt2(:);sta3(:)]));
figure;colormap(gray);
subplot(2,4,1);imagesc(xtFilt1,[-mx mx]);axis off;title('original filter 1');
subplot(2,4,2);imagesc(xtFilt2,[-mx mx]);axis off;title('original filter 2');
subplot(2,4,5);imagesc(sta3,[-mx mx]);axis off;title('STA');

[rawhist3] = histc(allStim*sta3(:), binedg); % P(stim)
[spkhist3] = histc(spikeStim3*sta3(:), binedg); % P(stim|spikes)
NL3 = (spkhist3(1:end-1)./rawhist3(1:end-1))'; % P(spikes|stim) ~ P(stim|spikes)/P(stim)

subplot(2,4,6);
plot(bins, NL3,'-o');ylabel('spikes/frame'); % P(spikes|stimulus)
title('estimated nonlinearity');

% STA finds the first excitatory filter but failed to find the second one. 
%
% Now we compute covariance matrix of stimulus.  But we should first 
% project normalized STA out of the STS because this ensures that the
% filters recovered by STC are all orthogonal to STA.

stimN = spikeStim3 - spikeStim3*sta3(:)*sta3(:)';  %project out the STA
covv = (stimN'*stimN)/(sum(spikes3)-1); % covariance of stimuli preceding spikes

% The covariance matrix describes the dependency of spiking on the 
% covariation between every pair of dimensions (e.g. how spiking depends on 
% the covariation between bar 2 at time 2 and bar 2 at time 3). 
% PCA applied to this matrix returns D orthogonal vectors (the eigenvectors) 
% and the variance of the STS along each vectors (the eigenvalues).   

[evect3, eval3] = eig(covv);  
[eval3,i] = sort(diag(eval3),'descend');
evect3 = evect3(:,i);clear i


% Plot the eigenvalues
mxx = max(max(eval3(1:end-1))).*1.3;
subplot(2,4,3); plot(eval3(1:end-1),'.'); axis([0 nT*nX 0 mxx])
xlabel('rank number'); title('eigenvalue');

% Plot the STC filters.  Remember, only those filters whose eigenvalues
% are significantly higher or lower than chance ("pop-off" the
% distribtuion) are considered significant.  If you look closely, you will
% see that one filter with low variance meets this criteria:
subplot(2,4,7);
imagesc(reshape(evect3(:,end-1),nT,nX),[-mx mx]);
title('STC Filter');axis off

% Compare the STC filter to the original. Note again that the filters may 
% be inversed in sign relative to the original filters.  In our simulated 
% neuron, this filter outputs were squared, thus it is irrelevant whether 
% the filter or its inverse are returned by PCA.  Note also that PCA forces 
% the filters to be orthogonal and consequently the filters need not be 
% exactly those that we started with.  But the filters recovered by STC 
% span the same linear subspace as the filters for the simulated neuron.  
% In other words, the set of filters will produce a model that given the 
% same input (stimulus), will produce the same output.


% Now we want to recover the nonlinear function that describes the 
% combination of filter outputs.  Given that we recovered 2 filters, 
% this nonlinear function should be described by a joint 2-dimensional 
% probability distribution.  In reality, however, we don't have enough 
% data to reconstruct this function completely. So we often look at slices 
% through it, instead.  Here, we reconstruct firing rate as a function of 
% the output of single filters by taken the ratio of the spiking stimuli 
% and all stimuli projected onto the filters.

[rawhist4] = histc(allStim*evect3(:,end-1), binedg);
[spkhist4] = histc(spikeStim3*evect3(:,end-1), binedg);
NL4 = (spkhist4(1:end-1)./rawhist4(1:end-1))';

subplot(2,4,4);hold on;
plot(bins,rawhist4(1:end-1)/size(allStim,1),'r'); % P(stimulus)
plot(bins,spkhist4(1:end-1)/size(spikeStim3,1),'g'); % P(stimulus|spikes)
ylabel('Probability');

subplot(2,4,8);
plot(bins, NL4,'-o');ylabel('spikes/frame'); % P(spikes|stimulus)
title('estimated nonlinearity');

% Note that the firing rate decreases as a function of the squared output
% of the STC filter.  Thus, the STC filter has an inhibitory influence 
% on the simulated neuron's response, whereas the STA filter is excitatory.
