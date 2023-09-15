function results = ...
    BehResp_Ana(handles, tc_all, tc_T, featureflag, varsel, varlist,...
    ftdur, condflag,triallabel, beh_t, trialsel_ID, ttlabel, figiniID, datatitle)
% tc_all, tc_T: calcium traces, calcium trace timing
% featureflag: can be delta function (eg. reward signal), continuous change (eg. speed), 
% or feature blocks (eg. wall feature in linear maze)
% varsel: featureflag [=/</>, value]
% ftdur: [start, end] time from featureflag, 
% trialfeature: additional feature defines whether a block would b analyzed
% or not
% trialflag: trialID for featureflag
% beh_t: timing for behavior parameters [featureflag, trialflag, trialfeature]
% triallist: trial included for analysis 

tmp = featureflag;
switch varsel(1) 
    case 2 % ==
        featureflag(tmp~=varlist(varsel(2))) = 0;
        featureflag(tmp==varlist(varsel(2))) = 1;
    case 3 % <
        featureflag(tmp>=varlist(varsel(2))) = 0;
        featureflag(tmp<varlist(varsel(2))) = 1;                    
    case 4 % >
        featureflag(tmp<=varlist(varsel(2))) = 0;
        featureflag(tmp>varlist(varsel(2))) = 1;                    
end
N = size(tc_all,2);
win = ceil([ftdur(2)-ftdur(1)]/mean(diff(tc_T)));
dseg = find(diff([0;featureflag])==1); % feature == vel events initial
if ~isempty(condflag)
    seglist = unique(condflag);
else
    seglist = 1;
end
clear featlabel_trial tc_aligntrial T_interptrial
tc_segment = [];
tt_segment = [];
featurelabel = [];
if ~isempty(trialsel_ID)
    rep0 = min(trialsel_ID) - 1;
end
for k = 1:length(dseg)
    i0 = dseg(k);
    [~, i1] = min(abs(beh_t-(beh_t(i0)+ftdur(1))));
    i2 = find(beh_t>=beh_t(i1)+ftdur(2),1);
    i3 = find(beh_t<=beh_t(i1)-ftdur(2),1,'last');
    if isempty(i2) || isempty(i3)
        continue
    end
    if ~isempty(triallabel)
        rep = triallabel(i1); % trial ID
        if ~ismember(rep, trialsel_ID) || rep==rep0
            continue
        end 
        rep0 = rep;
    else
        rep = 1;
    end
    % align segment so that the 2p trace has the same number of time points
    if beh_t(i3)>=tc_T(1) && beh_t(i2)<=tc_T(end)
    [~, t1] = min(abs(tc_T-beh_t(i1)));    
    t2p = tc_T(t1-win:t1+win);
    t2p = t2p - beh_t(i0);
    tctmp = tc_all(t1-win:t1+win, :);
    if ~isempty(tctmp)        
        tc_segment = cat(3, tc_segment, tctmp);
        tt_segment = cat(2, tt_segment, t2p);
        if ~isempty(condflag)
            featurelabel = cat(1, featurelabel, [condflag(i1), rep]);
        else
            featurelabel = cat(1, featurelabel, [1, rep]);
        end
    end
    end
end
if ~isempty(condflag)
    fttype = unique(condflag);
    nft = length(fttype);
else
    nft = 1;
end
if ~isempty(featurelabel) && ~isempty(tc_segment)
    c = ceil(N/20);
    scrsz = handles.scrsz;            
    for i = 1:c
        pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
        h1 = figure(figiniID+i); clf('reset')
        set(h1, 'Name', [datatitle, ' response'],'Position', pos, 'NumberTitle', 'off'); 
    end
    cc = colormap(hsv(length(seglist)));
    for i = 1:length(seglist)
        ii = find(featurelabel(:,1)==seglist(i));
        if ~isempty(ii)
            tc_aligntrial{i} = tc_segment(:,:,ii);
            xx = mean(tt_segment(:,2),2);
            yy = nanmean(tc_aligntrial{i}, 3);
            er = nanstd(tc_aligntrial{i},[],3)/sqrt(length(ii));
            multiplot_multitrace(xx, yy, er, cc(i,:), ttlabel, figiniID)    
            T_interptrial{i} = xx;
            featlabel_trial{i} = featurelabel(ii,:);
        end
    end

    results.featurelabel = featlabel_trial;
    results.tc_feature = tc_aligntrial;
    results.tc_T = T_interptrial;
    results.notes = 'featurelabel = No. of segments x [trialtype, trialID]; tc_feature(calcium traces) = time x neuron x segments; tc_T: time from parameter k = v';
else
    results = [];
end