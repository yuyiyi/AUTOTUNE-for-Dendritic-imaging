function [tc2, finalBaseline_out] = F_Preprocess_v2(tc, fps, ifdisp, w1, w2)
%{
F_Preprocess Calculates baseline-corrected calcium fluorescence traces
using suite2p method and taking suite2p data container as input.

input
tc: raw trace
fps = imaging fps

output
tc - baseline-corrected fluorescence
REMOVES RAW FLUORESCENCE AND NEUROPIL TRACES TO SAVE SPACE

%}
if nargin<3
    ifdisp = 0;
    w1 = 0.3;
    w2 = 20;
end
gaussfiltSize = round(w1*fps);%round(30*fps); %in seconds.
maxminfiltSize = round(w2*fps); %in seconds.
w = gausswin(gaussfiltSize); 
w = w/sum(w); %set up window for gauss filter
tc2 = zeros(size(tc));
for i=1:size(tc,1) %neurons
    Fbaseline = filter(w,1,tc(i,:)); %gauss filter
    finalBaseline1= movmin(Fbaseline, [maxminfiltSize/2,maxminfiltSize/2],2); %then min filter 
    finalBaseline= movmax(finalBaseline1, [maxminfiltSize/2,maxminfiltSize/2], 2); %then max filter 
    tc2(i,:) = tc(i,:)-finalBaseline; %final baseline-corrected trace
    % compute baseline of corrected trace
    Fbaseline = filter(w,1,tc2(i,:)); %gauss filter
    finalBaseline2= movmin(Fbaseline, [maxminfiltSize/2,maxminfiltSize/2],2); %then min filter 
    finalBaseline_out(i,:)= ...
        movmax(finalBaseline2, [maxminfiltSize/2,maxminfiltSize/2], 2); %then max filter 
    
    if ifdisp == 1
        figure(5), clf('reset')
        subplot(211)
        hold on, plot(tc(i,:))
        hold on, plot(Fbaseline)
        hold on, plot(finalBaseline1)
        hold on, plot(finalBaseline)     
        subplot(212), plot(tc2(i,:))
        hold on, plot(finalBaseline_out(i,:)) 
    end
end
tc2 = tc2';


