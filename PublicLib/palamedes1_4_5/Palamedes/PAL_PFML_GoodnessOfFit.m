%
%PAL_PFML_GoodnessOfFit     Determine Goodness-of-Fit of psychometric
%   function (PF) using method in Wichmann & Hill, 2001, Perception &
%   Psychophysics, 63, 1293-1313.
%
%Syntax:    [Dev pDev DevSim converged] = ...
%           PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
%           paramsValues, paramsFree, B, PF,{optional arguments});
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
%   'paramsValues': 1x4 vector containing parametervalues [threshold slope 
%       guess-rate lapse-rate]. PAL_PFML_Fit might be used to obtain
%       best-fitting parameter values.
%
%   'paramsFree': 1x4 vector coding which of the four parameters in 
%       paramsValue are free parameters and which are fixed parameters 
%       (1: free, 0: fixed).
%
%   'B': number of bootstrap simulations to perform.
%
%   'PF': psychometric function used in fit. Passed as an inline function.
%       Options include:    
%           @PAL_Logistic
%           @PAL_Weibull
%           @PAL_CumulativeNormal
%           @PAL_Gumbel
%           @PAL_HyperbolicSecant
%
%Output: 
%   'Dev': Deviance (transformed likelihood ratio comparing fit of
%       psychometric function to fit of saturated model)
%
%   'pDev': proportion of the B Deviance values from simulations that were
%       greater than Deviance value of data. The greater the value of pDev,
%       the better the fit.
%
%   'DevSim': vector containing all B simulated Deviance values.
%
%   'converged': For each simulation contains a 1 in case the fit was
%       succesfull (i.e., converged) or a 0 in case it did not.
%
%   PAL_PFML_GoodnessOfFit will generate a warning if not all 
%       simulations were fit succesfully.
%
%   PAL_PFML_GoodnessOfFit will accept a few optional arguments:
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
%       for guess rate in 'searchGrid' needs to be made but will be 
%       ignored.
%
%       Retrying failed fits when 'searchGrid' is not used (see
%       above):
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
%       entirely arbitrary and in most cases inappropriate [1 1 .1 .1].
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
%   PAL_PFML_GoodnessOfFit uses Nelder-Mead Simplex method to find the 
%   maximum in the likelihood function. The default search options may be 
%   changed by using the optional argument 'SearchOptions' followed by an 
%   options structure created using options = PAL_minimize('options'). See 
%   example of usage in PAL_PFML_Fit. For more information type:
%   PAL_minimize('options','help');
%
%Example:
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
%   %Determine Goodness-Of-Fit
%
%   B = 400;
%
%   [Dev pDev DevSim converged] = ...
%       PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
%       paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid, ...
%       'lapseLimits',[0 .03]);
%
% Introduced: Palemedes version 1.0.0 (NP)
% Modified: Palamedes version 1.0.2 (NP). No longer produces 'DivideByZero'
%   warning when B is set to 0 (to avoid the running of simulations).
% Modified: Palamedes version 1.0.2 (NP). Fixed error in comments section
%   regarding the names of PF routines.
% Modified: Palamedes version 1.1.0 (NP): upon completion returns all 
%   warning states to prior settings.
% Modified: Palamedes version 1.2.0 (NP): 'converged' is now array of 
%   logicals.
% Modified: Palamedes version 1.2.0 (NP): Modified to accept 'searchGrid'
%   argument as a structure defining 4D parameter grid to search for
%   initial guesses for parameter values. See also
%   PAL_PFML_BruteForceFit.m.
% Modified: Palamedes version 1.3.0 (NP): Added warning when 'LapseLimits'
%   argument is used but lapse is not a free parameter.
% Modified: Palamedes version 1.3.0 (NP). Added options 'lapseFit' and
%   'gammaEQlambda'.
% Modified: Palamedes version 1.3.1 (NP): Added (hidden) option 'default' 
%   for 'lapseFit' and modified 'lapseFit' and 'lapseLimits' warnings to
%   avoid false throws of warnings.
% Modified: Palamedes version 1.4.0 (NP). Added 'guessLimits' option.
% Modified: Palamedes version 1.4.0 (NP). Short-circuited logical
%   operators.

function [Dev pDev DevSim converged] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, paramsValues, paramsFree, B, PF, varargin);

searchGrid = paramsValues;

options = [];
maxTries = 1;
RangeTries = [1 1 .1 .1];
lapseLimits = [];
guessLimits = [];
lapseFit = 'default';
gammaEQlambda = logical(false);

converged = false(B,1);
DevSim = zeros(B,1);

if ~isempty(varargin)
    NumOpts = length(varargin);
    for n = 1:2:NumOpts
        valid = 0;
        if strcmpi(varargin{n}, 'SearchOptions')
            options = varargin{n+1};
            valid = 1;
        end
        if strcmpi(varargin{n}, 'maxTries')
            maxTries = varargin{n+1};
            valid = 1;
        end
        if strcmpi(varargin{n}, 'RangeTries')
            RangeTries = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'lapseLimits',6)
            if paramsFree(4) == 1
                lapseLimits = varargin{n+1};
            else
                message = ['Lapse rate is not a free parameter: ''lapseLimits'' argument ignored'];
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
            if gammaEQlambda                
                if paramsValues(3) ~= paramsValues(4)
                    paramsValues(3) = paramsValues(4);
                    message = ['Generating gamma value changed to ' num2str(paramsValues(3),'%5.3f') ' to match lapse value'];                    
                    warning(message);
                end                
            valid = 1;
            end
        end        
        if valid == 0
            message = ['Warning: ' varargin{n} ' is not a valid option. Ignored.'];
            disp(message);
        end
    end            
end

if ~isempty(guessLimits) && gammaEQlambda
    message = ['Guess rate is constrained to equal lapse rate: ''guessLimits'' argument ignored'];
    warning('PALAMEDES:PFML_Fit_guessLimits',message)
    guessLimits = [];
end

if ~isstruct(searchGrid)
    message = ['Option to use generating parameter values as initial '];    
    message = [message 'guesses in fitting procedure will be removed in '];
    message = [message 'some future version of Palamedes. Instead use '];
    message = [message 'optional argument ''searchGrid'' to pass a '];
    message = [message 'structure defining a 4D parameter space through '];
    message = [message 'which to search for initial search values using a '];
    message = [message 'brute force search. Type help '];
    message = [message 'PAL_PFML_GoodnessOfFit for more information.'];
    warning('PALAMEDES:paramsInitGoF',message)
    warning('off','PALAMEDES:paramsInitGoF');
end

warningstates = warning('query','all');
warning off MATLAB:log:logOfZero
warning off MATLAB:DivideByZero


[StimLevels NumPos OutOfNum] = PAL_PFML_GroupTrialsbyX(StimLevels, NumPos, OutOfNum);

negLLCon = PAL_PFML_negLL([], paramsValues, [0 0 0 0], StimLevels, NumPos, OutOfNum, PF,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);
negLLAug = PAL_PFML_negLLNonParametric(NumPos, OutOfNum);

Dev = 2*(negLLCon-negLLAug);

if isstruct(searchGrid)
    
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
    paramsGuess = paramsValues;
    if gammaEQlambda
        paramsGuess(3) = paramsGuess(4);
        paramsFree(3) = 0;
    end        
end

for b = 1:B
    NumPosSim = PAL_PF_SimulateObserverParametric(paramsValues, StimLevels, OutOfNum, PF,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);
    
    if isstruct(searchGrid)
        LLspace = zeros(size(paramsGrid.alpha,1),size(paramsGrid.alpha,2),size(paramsGrid.alpha,3),size(paramsGrid.alpha,4));

        if iscolumn(LLspace)
            LLspace = LLspace';
        end

        switch lower(lapseFit(1:3))
            case {'nap','def'}
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
    
    [paramsValuesSim trash converged(b)] = PAL_PFML_Fit(StimLevels, NumPosSim, OutOfNum, paramsGuess, paramsFree, PF, 'SearchOptions', options,'lapseLimits',lapseLimits,'guessLimits',guessLimits,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);

    if ~isstruct(searchGrid)     
        tries = 1;
        while converged(b) == 0 && tries < maxTries
            NewSearchInitials = paramsValues+(rand(1,4)-.5).*RangeTries.*paramsFree;
            [paramsValuesSim trash converged(b)] = PAL_PFML_Fit(StimLevels, NumPosSim, OutOfNum, NewSearchInitials, paramsFree, PF, 'SearchOptions', options,'lapseLimits',lapseLimits,'guessLimits',guessLimits,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);
            tries = tries + 1;
        end    
    end
    
    negLLConSim = PAL_PFML_negLL([], paramsValuesSim, [0 0 0 0], StimLevels, NumPosSim, OutOfNum, PF,'lapseFit',lapseFit,'gammaEQlambda',gammaEQlambda);
    negLLAugSim = PAL_PFML_negLLNonParametric(NumPosSim, OutOfNum);
    DevSim(b) = 2*(negLLConSim-negLLAugSim);
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

pDev = length(DevSim(DevSim>Dev))/B;

warning(warningstates);