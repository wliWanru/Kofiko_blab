%
%PAL_PFML_BootstrapNonParametric    Perform non-parametric bootstrap to
%   determine standard errors on parameters of fitted psychometric
%   function.
%
%syntax: [SD paramsSim LLSim converged] = ...
%   PAL_PFML_BootstrapNonParametric(StimLevels, NumPos, OutOfNum, ...
%   obsolete, paramsFree, B, PF, {optional arguments})
%
%Input:
%   'StimLevels': vector containing stimulus levels used.
%
%   'NumPos': vector containing for each of the entries of 'StimLevels' the 
%       number of trials a positive response (e.g., 'yes' or 'correct') was
%       given.
%
%   'OutOfNum': vector containing for each of the entries of 'StimLevels' 
%       the total number of trials.
%
%   'obsolete': Obsolete. Pass an empty vector here and use 'searchGrid' 
%       option (described below). What still works (but will be removed in 
%       future version) is a 1x4 vector containing initial guesses for free 
%       parameters and fixed values for fixed parameters [threshold slope 
%       guess-rate lapse-rate]. However, it is strongly recommended to use 
%       the (for now) optional argument 'searchGrid' (see below).
%
%   'paramsFree': 1x4 vector coding which of the four parameters in 
%       paramsValue are free parameters and which are fixed parameters 
%       (1: free, 0: fixed).
%
%   'B': number of bootstrap simulations to perform.
%
%   'PF': psychometric function to be fitted. Passed as an inline function.
%       Options include:    
%           @PAL_Logistic
%           @PAL_Weibull
%           @PAL_CumulativeNormal
%           @PAL_Gumbel
%           @PAL_HyperbolicSecant
%
%Output:
%   'SD': 1x4 vector containing standard deviations of the PF's parameters
%       across the B fits to simulated data. These are estimates of the
%       standard errors of the parameter estimates.
%
%   'paramsSim': Bx4 matrix containing the fitted parameters for all B fits
%       to simulated data.
%
%   'LLSim': vector containing Log Likelihoods associated with all B fits
%       to simulated data.
%
%   'converged': For each simulation contains a 1 in case the fit was
%       succesfull (i.e., converged) or a 0 in case it did not.
%
%   PAL_PFML_BootstrapNonParametric will generate a warning if not all 
%       simulations were fit succesfully.
%
%   PAL_PFML_BootstrapNonParametric will accept a few optional arguments:
%
%       Use 'searchGrid' argument to define a 4D parameter 
%       grid through which to perform a brute-force search for initial 
%       guesses (using PAL_PFML_BruteForceFit) to be used during fitting 
%       procedure. Structure should have fields .alpha, .beta, .gamma, and 
%       .lambda. Each should list parameter values to be included in brute 
%       force search. Fields for fixed parameters should be scalars equal 
%       to the fixed parameter value. Note that all fields may be scalars
%       in which case no brute-force search will precede the iterative
%       parameter search. For more information, see example below. Note 
%       that choices made here have a large effect on processing time and 
%       memory usage. In some future version of Palamedes this argument 
%       will be required.
%
%       If highest entry in 'StimLevels' is so high that it can be 
%       assumed that errors observed there can be due only to lapses, use 
%       'lapseFit' argument to specify alternative fitting scheme. Options: 
%       'nAPLE' (default), 'iAPLE', and 'jAPLE'. Type help 
%       PAl_PFML_FitMultiple for more information.
%
%       The guess rate and lapse rate parameter can be constrained to be 
%       equal, as would be appropriate, for example, in a bistable percept 
%       task. To accomplish this, use optional argument 'gammaEQlambda', 
%       followed by a 1. Both the guess rate and lapse rate parameters will 
%       be fit according to options set for the lapse rate parameter. Entry
%       for guess rate in searchGrid needs to be made but will be ignored.
%
%       Retrying failed fits when 'searchGrid' is passed as vector (see
%       above). This option will be removed in some future version of 
%       Palamedes. Instead use 'searchGrid' option to perform a brute
%       force search for initial parameter values:
%
%       In case not all fits converge succesfully, use optional argument 
%       'maxTries' to set the maximum number of times each fit will be 
%       attempted. The first try uses initial search values equal to 
%       paramsValues provided in function call, subsequent tries use these 
%       search values plus some random 'jitter'. The range of the random 
%       jitter can be set for each of the four parameters separately using 
%       the optional argument 'rangeTries'. 'rangeTries' should be set to
%       a 1 x 4 vector containing the range of jitter to be applied to 
%       initial guesses of parameters [alpha beta gamma lambda]. Default 
%       value for 'maxTries' is 1, default value for 'rangeTries' is the 
%       entirely arbitrary and in most cases inappropriate [1 1 1 1].
%       Jitter will be selected randomly from rectangular distribution
%       centered on guesses in 'paramsValues' with range in 'rangeTries'.
%
%       (Note that some simulated data sets may never be fit succesfully 
%           regardless of value of 'maxTries' and 'rangeTries') 
%
%       User may constrain the lapse rate to fall within limited range 
%       using the optional argument 'lapseLimits', followed by a two-
%       element vector containing lower and upper limit respectively. See 
%       full example below.
%
%       User may constrain the guess rate to fall within limited range 
%       using the optional argument 'guessLimits', followed by a two-
%       element vector containing lower and upper limit respectively.
%
%   PAL_PFML_BootstrapNonParametric uses Nelder-Mead Simplex method to find 
%   the maximum in the likelihood function. The default search options may 
%   be changed by using the optional argument 'SearchOptions' followed by 
%   an options structure created using options = PAL_minimize('options'). 
%   See example of usage below. For more information type:
%   PAL_minimize('options','help');
%
%Example:
%
%   options = PAL_minimize('options');  %decrease tolerance (i.e., increase
%   options.TolX = 1e-09;              %precision). 
%   options.TolFun = 1e-09;            
%   options.MaxIter = 10000;           
%   options.MaxFunEvals = 10000;
%
%   PF = @PAL_Logistic;
%   StimLevels = [-3:1:3];
%   NumPos = [55 55 66 75 91 94 97];    %observer data
%   OutOfNum = 100.*ones(size(StimLevels));
%   searchGrid.alpha = [-1:.1:1];    %structure defining grid to
%   searchGrid.beta = 10.^[-1:.1:2]; %search for initial values
%   searchGrid.gamma = .5;
%   searchGrid.lambda = [0:.005:.03];
%   paramsFree = [1 1 0 1];
%
%   %Fit data:
%
%   paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, ...
%       searchGrid, paramsFree, PF,'lapseLimits',[0 .03]);
%
%   %Estimate standard errors:
%
%   B = 400;
%
%   [SD paramsSim LLSim converged] = ...
%       PAL_PFML_BootstrapNonParametric(StimLevels, NumPos, OutOfNum, ...
%       [], paramsFree, B, PF,'lapseLimits',[0 .03],'searchGrid', ...
%       searchGrid);
%
%Introduced: Palamedes version 1.0.0 (NP)
%Modified: Palamedes version 1.0.1 (NP). A suggestion to consider a
%   parametric bootstrap is added to the warning issued when OutOfNum 
%   contains ones.
%Modified: Palamedes version 1.0.2 (NP). Fixed error in comments section
%   regarding the names of PF routines.
% Modified: Palamedes version 1.1.0 (NP): upon completion returns all 
%   warning states to prior settings.
% Modified: Palamedes version 1.2.0 (NP): 'converged' is now array of 
%   logicals.
% Modified: Palamedes version 1.2.0 (NP). Modified to accept 'searchGrid'
%   argument as a structure defining 4D parameter grid to search for
%   initial guesses for parameter values. See also
%   PAL_PFML_BruteForceFit.m.
% Modified: Palamedes version 1.3.0 (NP). Added warning when 'LapseLimits'
%   argument is used but lapse is not a free parameter.
% Modified: Palamedes version 1.3.0 (NP). Added options 'lapseFit' and
%   'gammaEQlambda'.
% Modified: Palamedes version 1.3.1 (NP). Added (hidden) option 'default' 
%   for 'lapseFit' and modified 'lapseFit' and 'lapseLimits' warnings to
%   avoid false throws of warnings.
% Modified: Palamedes version 1.4.0 (NP). Added 'guessLimits' option.


function [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(StimLevels, NumPos, OutOfNum, obsolete, paramsFree, B, PF, varargin)

if ~isempty(obsolete)
    message = ['Option to pass initial guesses to function in the form of a '];    
    message = [message 'vector will be removed in some future version of '];
    message = [message 'Palamedes. Instead use the (for now) optional '];
    message = [message '''paramsInit'' argument to pass a structure in '];
    message = [message 'order to define a 4D parameter space through '];
    message = [message 'which to search for initial search values using a '];
    message = [message 'brute force search. Usage of the ''paramsInit'' '];
    message = [message 'argument will become required in some future '];
    message = [message 'version of Palamedes. Type help '];
    message = [message 'PAL_PFML_BootstrapNonParametric for more '];
    message = [message 'information. '];

    warning('PALAMEDES:paramsInitBNP',message)
    warning('off','PALAMEDES:paramsInitBNP');
end

warningstates = warning('query','all');
warning off MATLAB:log:logOfZero

options = [];
maxTries = 1;
rangeTries = [1 1 .1 .1];
lapseLimits = [];
guessLimits = [];
lapseFit = 'default';
gammaEQlambda = logical(false);

paramsSim = zeros(B,4);
LLSim = zeros(B,1);
converged = false(B,1);

if ~isempty(varargin)
    NumOpts = length(varargin);
    for n = 1:2:NumOpts
        valid = 0;
        if strncmpi(varargin{n}, 'SearchOptions',7)
            options = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'maxTries',4)
            maxTries = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'rangeTries',6)
            rangeTries = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'lapseLimits',6)
            if paramsFree(4) == 1
                lapseLimits = varargin{n+1};
            else
                message = ['Lapse rate is not a free parameter: ''LapseLimits'' argument ignored'];
                warning(message);
            end
            valid = 1;
        end
        if strncmpi(varargin{n}, 'guessLimits',6)
            if paramsFree(3) == 1
                guessLimits = varargin{n+1};
            else
                message = ['Guess rate is not a free parameter: ''guessLimits'' argument ignored'];
                warning(message);
            end
            valid = 1;
        end
        if strncmpi(varargin{n}, 'searchGrid',8)
            searchGrid = varargin{n+1};
            valid = 1;
        end        
        if strncmpi(varargin{n}, 'lapseFit',6)
            if paramsFree(4) == 0
                message = ['Lapse rate is not a free parameter: ''lapseFit'' argument ignored'];
                warning(message);
            else
                lapseFit = varargin{n+1};
            end
            valid = 1;
        end
        if strncmpi(varargin{n}, 'gammaEQlambda',6)
            gammaEQlambda = logical(varargin{n+1});
            valid = 1;
        end
        if valid == 0
            message = [varargin{n} ' is not a valid option. Ignored.'];
            warning(message);
        end
    end            
end

if ~isempty(guessLimits) && gammaEQlambda
    message = ['Guess rate is constrained to equal lapse rate: ''guessLimits'' argument ignored'];
    warning('PALAMEDES:PFML_Fit_guessLimits',message)
    guessLimits = [];
end

[StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);

if min(OutOfNum) == 1
    message = ['Some stimulus intensities appeared on a single trial only:'];
    message = [message sprintf('\nConsider a parametric bootstrap instead.')];
    warning(message);
    StimLevels
    OutOfNum
end

if exist('searchGrid')
    
    if gammaEQlambda
        searchGrid.gamma = 0;
    end      
    
    [paramsGrid.alpha paramsGrid.beta paramsGrid.gamma paramsGrid.lambda] = ndgrid(searchGrid.alpha,searchGrid.beta,searchGrid.gamma,searchGrid.lambda);

    singletonDim = uint16(size(paramsGrid.alpha) == 1);    
    
    [paramsGrid.alpha] = squeeze(paramsGrid.alpha);
    [paramsGrid.beta] = squeeze(paramsGrid.beta);
    [paramsGrid.gamma] = squeeze(paramsGrid.gamma);
    [paramsGrid.lambda] = squeeze(paramsGrid.lambda);

    if gammaEQlambda
        paramsGrid.gamma = paramsGrid.lambda;
    end
    
    for level = 1:length(StimLevels)
        logpcorrect(level,:,:,:,:) = log(PF(paramsGrid,StimLevels(1,level)));   
        logpincorrect(level,:,:,:,:) = log(1-PF(paramsGrid,StimLevels(1,level)));
    end
else
    paramsGuess = obsolete;
    if gammaEQlambda
        paramsGuess(3) = paramsGuess(4);
        paramsFree(3) = 0;
    end
end

for b = 1:B
    %Simulate experiment
    NumPosSim = PAL_PF_SimulateObserverNonParametric(StimLevels, NumPos, OutOfNum);
    
    if exist('searchGrid')

        LLspace = zeros(size(paramsGrid.alpha,1),size(paramsGrid.alpha,2),size(paramsGrid.alpha,3),size(paramsGrid.alpha,4));

        if iscolumn(LLspace)
            LLspace = LLspace';
        end

        switch lower(lapseFit(1:3))
            case {'nap', 'def'}
                for level = 1:length(StimLevels)
                   LLspace = LLspace + NumPosSim(level).*squeeze(logpcorrect(level,:,:,:,:))+(OutOfNum(level)-NumPosSim(level)).*squeeze(logpincorrect(level,:,:,:,:));
                end
            case {'jap','iap'}
                len = length(NumPosSim);                            
                LLspace = log((1-paramsGrid.lambda).^NumPosSim(len))+log(paramsGrid.lambda.^(OutOfNum(len)-NumPosSim(len))); %0*log(0) evaluates to NaN, log(0.^0) does not
                if gammaEQlambda
                    LLspace = LLspace + log(paramsGrid.lambda.^NumPosSim(1)) + log((1-paramsGrid.lambda).^(OutOfNum(1)-NumPosSim(1)));
                end
                for level = 1+gammaEQlambda:len-1
                    LLspace = LLspace + NumPosSim(level).*squeeze(logpcorrect(level,:,:,:,:))+(OutOfNum(level)-NumPosSim(level)).*squeeze(logpincorrect(level,:,:,:,:));
                end    
        end
        
        if isvector(LLspace)
            [maxim Itemp] = max(LLspace)
        else
            if strncmpi(lapseFit,'iap',3)
                [trash lapseIndex] = min(abs(searchGrid.lambda-(1-NumPosSim(len)/OutOfNum(len))));
                LLspace = shiftdim(LLspace,length(size(LLspace))-1);
                [maxim Itemp] = PAL_findMax(LLspace(lapseIndex,:,:,:));
                Itemp = circshift(Itemp',length(size(LLspace))-1)';
            else
                [maxim Itemp] = PAL_findMax(LLspace);
            end
        end
        
        I = ones(1,4);
        
        I(singletonDim == 0) = Itemp;
        
        paramsGuess = [searchGrid.alpha(I(1)) searchGrid.beta(I(2)) searchGrid.gamma(I(3)) searchGrid.lambda(I(4))];
        if strncmpi(lapseFit,'iap',3)
            paramsGuess(4) = 1-NumPosSim(len)/OutOfNum(len);
        end
    end
    
    [paramsSim(b,:) LLSim(b,:) converged(b)] = PAL_PFML_Fit(StimLevels, NumPosSim, OutOfNum, paramsGuess, paramsFree, PF, 'SearchOptions', options,'lapseLimits',lapseLimits,'guessLimits',guessLimits,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);
    
    if ~exist('searchGrid') 
        tries = 1;
        while converged(b) == 0 && tries < maxTries
                NewSearchInitials = searchGrid+(rand(1,4)-.5).*rangeTries.*paramsFree;
                [paramsSim(b,:) LLSim(b,:) converged(b)] = PAL_PFML_Fit(StimLevels, NumPosSim, OutOfNum, NewSearchInitials, paramsFree, PF, 'SearchOptions', options,'lapseLimits',lapseLimits,'lapseFit','guessLimits',guessLimits,lapseFit,'gammaEQlambda',gammaEQlambda);                
                tries = tries + 1;            
        end
    end    
    if ~converged(b)
        message = ['Fit to simulation ' int2str(b) ' of ' int2str(B) ' did not converge.'];
        warning(message);
    end

end

exitflag = sum(converged) == B;
if exitflag ~= 1
    message = ['Only ' int2str(sum(converged)) ' of ' int2str(B) ' simulations converged'];
    warning(message);
end

[Mean SD] = PAL_MeanSDSSandSE(paramsSim);

warning(warningstates);