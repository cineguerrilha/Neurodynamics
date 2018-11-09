%%
% function RLSFilterIt()
% written by -      Ryan Fuller
% organization -    
% version -         1.0
% date -            26 October, 2011
%
% example - Type 'RLSFilterIt' (without quotes) into the workspace, and the
% filtering results for a sinusoid corrupted by white noise will be
% displayed. The SNR of the tone to the white noise can be adjusted.
%
% description - RLSFilterIt.m performs recursive least squares filtering of
% a primary signal, x, using the reference signal, n. The primary signal, 
% x, is composed of an interference and information bearing signal
% component, while the reference signal, n, is composed of the interference
% signal. Signals x and n must be vectors of the same length. Argument fs 
% is the sampling frequency. Additionally, output parameters e and w are
% the filtered signal and filter coefficients, respectively.
%
% The filter follows the notation used in Haykin's Adaptive Filter Theory 
% (2002).
%
%%
function [e,w] = RLSFilterIt(n,x,fs)

tic

%--------------------------------------------------------------------------
% Generate Data
%--------------------------------------------------------------------------

% Generate data if no inputs provided
if nargin < 1
    % Data Parameters
    numPts  = 1000;             % number of points to generate
    freq    = 100;              % frequency of fundamental tone
    filtord = 4;                % filter order
    filt    = rand(filtord, 1); % filter coefficients
    nVar    = 1;                % white noise variance
    SNR     = -20;              % signal to noise ratio of tone
    
    % Generate the data!
    [n,x,s,fs] = genData(numPts, freq, filt, nVar, SNR);
    
end 

%--------------------------------------------------------------------------
% Filtering
%--------------------------------------------------------------------------

% Filter Parameters
p       = 4;                % filter order
lambda  = 1.0;              % forgetting factor
laminv  = 1/lambda;
delta   = 1.0;              % initialization parameter

% Filter Initialization
w       = zeros(p,1);       % filter coefficients
P       = delta*eye(p);     % inverse correlation matrix
e       = x*0;              % error signal

for m = p:length(x)

    % Acquire chunk of data
    y = n(m:-1:m-p+1);

    % Error signal equation
    e(m) = x(m)-w'*y;
    
    % Parameters for efficiency
    Pi = P*y;
    
    % Filter gain vector update
    k = (Pi)/(lambda+y'*Pi);

    % Inverse correlation matrix update
    P = (P - k*y'*P)*laminv;

    % Filter coefficients adaption
    w = w + k*e(m);

    % Counter to show filter is working
    %if mod(m,1000) == 0
    %    disp([num2str(m/1000) ' of ' num2str(floor(length(x)/1000))])
    %end
    
end

toc

%--------------------------------------------------------------------------
% Plot
%--------------------------------------------------------------------------

% Plot filter results
t = linspace(0,length(x)/fs,length(x));
figure;
plot(t,x,t,e);
title('Result of RLS Filter')
xlabel('Time (s)');
legend('Reference', 'Filtered', 'Location', 'NorthEast');
title('Comparison of Filtered Signal to Reference Input');

% Plot comparison of results to original signal (only for generated data)
if nargin < 1
    figure;
    plot(t,s,t,e);
    title('Result of RLS Filter')
    xlabel('Time (s)');
    legend('Signal', 'Filtered', 'Location', 'NorthEast');
    title('Comparison of Filtered Signal to Original Signal');
end


% Calculate SNR improvement
SNRi    = 10*log10(var(x)/var(e));

disp([num2str(SNRi) 'dB SNR Improvement'])

return

function [n,x,s,fs] = genData(numPts, freq, filt, nVar, SNR)

    % Generate time values
    t = linspace(0,1,numPts)';
    fs = numPts;
    
    % Generate tone
    s = sin(2*pi*freq*t);
    
    % Generate noise
    n = sqrt(nVar)*randn(numPts,1);
    
    % Filter noise
    addnoise = filter(filt, 1, n);
    
    % Plot filter
    freqz(filt,1,1000)
    
    % Adjust SNR of tone
    s = s/sqrt(var(s)/(10^(SNR/10)*var(n)));
    disp(['Calculated SNR = ' num2str(10*log10(var(s)/var(n)))])
    
    % Add noise to signal
    x = s + addnoise;
    
return