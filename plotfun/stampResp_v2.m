function [value_mean, value_std, value_sem, glist_current] = ...
    stampResp_v2(trace_stamp, framestamp, stampinfo,...
    ttlabel, stampsel, varsel, glist_all, xvalue,...
    handles, figiniID, datatitle)

N = size(trace_stamp, 2);
stampinfo_t = table2array(stampinfo(:,1));
stampinfolist = table2array(stampinfo(:,varsel));
if isnumeric(glist_all)
    f0 = [1; find(diff(stampinfolist)~=0)+1];
    f1 = [find(diff(stampinfolist)~=0);length(stampinfolist)];
    g = stampinfolist(f0);
    glist = glist_all;
else
    tmplist = nan(length(stampinfolist),1);
    for i = 1:length(glist_all)
        tmplist(stampinfolist==glist_all(i)) = i;
    end
    f0 = [1; find(diff(tmplist)~=0)+1];
    f1 = [find(diff(tmplist)~=0);length(tmplist)];
    g = tmplist(f0);
    glist = [1:length(glist_all)]';
end
ts0 = stampinfo_t(f0);
ts1 = stampinfo_t(f1);
t0 = []; t1 = [];
dd0 = pdist2(ts0, framestamp);
[v0,t0] = min(dd0,[],2);
dd1 = pdist2(ts1, framestamp);
[v1,t1] = min(dd1,[],2);
    
value_g = []; value_statarray = [];
tc_segment = [];
featurelabel = [];
trialID = find(ismember(g, glist(stampsel)));
dt = t1- t0;
win = min(dt(trialID));
for j1 = 1:length(trialID)
    j = trialID(j1);
    value_g(j1,:) = nanmean(trace_stamp(t0(j):t1(j), :),1);  % stimulus block X neuron
    tctmp = trace_stamp(t0(j):t0(j)+win-1, :); % stimulus duration (win) X neuron
    if ~isempty(tctmp) 
        % stimulus duration (win) X neuron X stimulus segment (length(g))
        tc_segment = cat(3, tc_segment, tctmp);
        featurelabel = cat(1, featurelabel, g(j));
    end    
end

% average response within a stimulus block (average over time)
value_std = zeros(length(glist), size(value_g, 2));
value_sem = zeros(length(glist), size(value_g, 2));
value_mean = zeros(length(glist), size(value_g, 2));
for j = 1:length(glist)
    if sum(featurelabel==glist(j))>0
        tmp = value_g(featurelabel==glist(j),:);
        if size(tmp,1)>1
            value_mean(j, :) = nanmean(tmp,1);
            value_std(j, :) = nanstd(tmp,[],1);
            value_sem(j, :) = nanmean(tmp,1)/sqrt(size(tmp,1));
        else
            value_mean(j, :) = tmp;
        end
    else
        value_mean(j, :) = nan;
    end
end

% figtitle = 'Stamped response';
c = ceil(N/20);
scrsz = handles.scrsz;            
for i = 1:c
    pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
    h1 = figure(figiniID+i); clf('reset')
    set(h1, 'Name', [datatitle, ' response'],'Position', pos, 'NumberTitle', 'off'); 
end
% plot response mean and sem 
if isempty(xvalue) || sum(isnan(xvalue))>0
    xdata = glist(stampsel);
    ydata = value_mean(stampsel,:);
    er = value_sem(stampsel,:);
    xxlabel = glist_all(stampsel);
else
    xdata_tmp = xvalue;
    ydata_tmp = value_mean(stampsel,:);
    er_tmp = value_sem(stampsel,:);
    [xdata,ii] = sort(xdata_tmp);
    ydata = ydata_tmp(ii,:);
    er = er_tmp(ii,:);
    xxlabel = [];
%     xxlabel = xdata;
end
multiplot(xdata, ydata, er, xxlabel, ttlabel, figiniID)

% plot trial-averaged stimulus response
figiniID = figiniID+c;
c = ceil(N/20);
scrsz = handles.scrsz;            
for i = 1:c
    pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
    h1 = figure(figiniID+i); clf('reset')
    set(h1, 'Name', [datatitle, 'trial-average response'],'Position', pos, 'NumberTitle', 'off'); 
end
cc = colormap(hsv(length(glist)));
nft = 1;
for i = 1:length(stampsel)
    ii = find(featurelabel(:,1)==glist(stampsel(i)));
    if ~isempty(ii)
        tc_aligntrial{i} = tc_segment(:,:,ii);
        xx = [1:win]+win*(i-1);
        yy = nanmean(tc_aligntrial{i}, 3); % trial averaged response
        er = nanstd(tc_aligntrial{i},[],3)/sqrt(length(ii));
        multiplot_multitrace(xx, yy, er, cc((i-1)*nft+1,:), ttlabel, figiniID)    
        featlabel_trial{i} = featurelabel(ii,:);
    end
end
glist_current = glist_all(stampsel);