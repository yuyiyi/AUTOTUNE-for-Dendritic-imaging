function [value_mean, value_std, value_sem, glist] = ...
    stampResp(trace_stamp, framestamp, stampinfo,...
    ttlabel, stampsel, xvalue, handles, figiniID, datatitle)

N = size(trace_stamp, 2);
t0 = [1; find(diff(framestamp)~=0)+1];
t1 = [find(diff(framestamp)~=0);length(framestamp)];
g = framestamp(t0);
value_g = []; value_statarray = [];
tc_segment = [];
featurelabel = [];
win = min(t1-t0);
for j = 1:length(t0)
    value_g(j,:) = nanmean(trace_stamp(t0(j):t1(j), :),1);  % stimulus block X neuron
    tctmp = trace_stamp(t0(j):t0(j)+win-1, :);
    if ~isempty(tctmp) 
        tc_segment = cat(3, tc_segment, tctmp);
        featurelabel = cat(1, featurelabel, g(j));
    end    
end

glist = sort(unique(g), 1); 
value_std = zeros(length(glist), size(value_g, 2));
value_sem = zeros(length(glist), size(value_g, 2));
value_mean = zeros(length(glist), size(value_g, 2));
for j = 1:length(glist)
    tmp = value_g(g==glist(j),:);
    if size(tmp,1)>1
        value_mean(j, :) = nanmean(tmp,1);
        value_std(j, :) = nanstd(tmp,[],1);
        value_sem(j, :) = nanmean(tmp,1)/sqrt(size(tmp,1));
    else
        value_mean(j, :) = tmp;
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
    xxlabel = stampinfo(stampsel);
else
    xdata_tmp = xvalue;
    ydata_tmp = value_mean(stampsel,:);
    er_tmp = value_sem(stampsel,:);
    [xdata,ii] = sort(xdata_tmp);
    ydata = ydata_tmp(ii,:);
    er = er_tmp(ii,:);
    xxlabel = xdata;
end
multiplot(xdata, ydata, er, xxlabel, ttlabel, figiniID)

figiniID = figiniID+c;
c = ceil(N/20);
scrsz = handles.scrsz;            
for i = 1:c
    pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
    h1 = figure(figiniID+i); clf('reset')
    set(h1, 'Name', [datatitle, ' response'],'Position', pos, 'NumberTitle', 'off'); 
end
cc = colormap(hsv(length(glist)));
nft = 1;
for i = 1:length(glist)
    ii = find(featurelabel(:,1)==glist(i));
    if ~isempty(ii)
        tc_aligntrial{i} = tc_segment(:,:,ii);
        xx = 1:win;
        yy = nanmean(tc_aligntrial{i}, 3);
        er = nanstd(tc_aligntrial{i},[],3)/sqrt(length(ii));
        multiplot_multitrace(xx, yy, er, cc((i-1)*nft+1,:), ttlabel, figiniID)    
        featlabel_trial{i} = featurelabel(ii,:);
    end
end

