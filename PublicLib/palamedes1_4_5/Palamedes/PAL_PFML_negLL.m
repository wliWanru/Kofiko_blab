%
%PAL_PFML_negLL     (negative) Log Likelihood associated with fit of
%   Psychometric Function
%
%Syntax: negLL = PAL_PFML_negLL(paramsFreeVals, paramsFixedVals, ...
%   paramsFree, StimLevels, NumPos, OutOfNum, PF, {optional arguments})
%
%Internal Function
%
% Introduced: Palamedes version 1.0.0 (NP)
% Modified: Palamedes version 1.3.0 (NP). Added options 'lapseFit' and
%   'gammaEQlambda'.
% Modified: Palamedes version 1.3.1 (NP). Added (hidden) option 'default' 
%   for 'lapseFit'.
% Modified: Palamedes version 1.4.0 (NP). Added 'guessLimits' option.
% Modified: Palamedes version 1.4.0 (NP). Short-circuited logical
%   operators.
% Modified: Palamedes version 1.4.1 (NP). Ignore NaN's (which arise when
%   0*log(0) is evaluated).
% Modified: Palamedes version 1.4.1.1 (NP). Changed manner in which NaN's
%   arising from evaluating 0*log(0) are handled (some more).


function negLL = PAL_PFML_negLL(paramsFreeVals, paramsFixedVals, paramsFree, StimLevels, NumPos, OutOfNum, PF, varargin)

lapseLimits = [];
guessLimits = [];
lapseFit = 'default';
gammaEQlambda = logical(false);

if ~isempty(varargin)
    NumOpts = length(varargin);
    for n = 1:2:NumOpts
        valid = 0;
        if strncmpi(varargin{n}, 'lapseLimits',6)
            lapseLimits = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'guessLimits',6)
            guessLimits = varargin{n+1};
            valid = 1;
        end
        if strncmpi(varargin{n}, 'lapseFit',6)
            lapseFit = varargin{n+1};
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

params(paramsFree == 1) = paramsFreeVals;
params(paramsFree == 0) = paramsFixedVals;    

if gammaEQlambda
    params(3) = params(4);
end

pcorrect = PF(params, StimLevels);

if (~isempty(lapseLimits) && (params(4) < lapseLimits(1) || params(4) > lapseLimits(2))) || (~isempty(guessLimits) && (params(3) < guessLimits(1) || params(3) > guessLimits(2)))
    negLL = Inf;
else    
    switch lower(lapseFit(1:3))
        case {'nap', 'def'}            
            negLL = sum(PAL_nansum(NumPos.*log(pcorrect)+(OutOfNum-NumPos).*log(1 - pcorrect)));
        case {'jap', 'iap'}        %F assumed to equal unity at highest stimulus level.            
            len = length(StimLevels);                   
            negLL = PAL_nansum(NumPos(len).*log(1-params(4)) + (OutOfNum(len)-NumPos(len)).*log(params(4)));
            if gammaEQlambda
                negLL = negLL + PAL_nansum((OutOfNum(1)-NumPos(1))*log(1-params(4)) + NumPos(1).*log(params(4)));
            end
            negLL = negLL + sum(PAL_nansum(NumPos(1+gammaEQlambda:len-1).*log(pcorrect(1+gammaEQlambda:len-1))+(OutOfNum(1+gammaEQlambda:len-1)-NumPos(1+gammaEQlambda:len-1)).*log(1 - pcorrect(1+gammaEQlambda:len-1))));
    end    
    negLL = -negLL;
end