function [fitresult, figtitle, fmodel, xx, value_g] =...
    FitstampResp_customfun(trace_stamp, framestamp, stampsel,...
    fmodel_input, fmodel_Independent,fmodel_Coefficients,fmodel_startpoint,...
    xvalue, handles, ttlabel)

N = size(trace_stamp,2);
t0 = [1; find(diff(framestamp)~=0)+1];
t1 = [find(diff(framestamp)~=0);length(framestamp)];
g = framestamp(t0);
value_g = []; value_statarray = [];

for j = 1:length(t0)
    value_g(j,:) = nanmean(trace_stamp(t0(j):t1(j), :),1); % stimulus block X neuron
end

glist = sort(unique(g),1);
gkeep = zeros(length(g),1);
if length(stampsel)<length(glist)
    gkeep = ismember(g, glist(stampsel));
    g = g(gkeep==1);
    value_g = value_g(gkeep==1,:);
    glist = glist(stampsel);
end
xx = reshape(xvalue(g),[],1);

value_mean = []; value_std = []; 
for j = 1:length(glist)
    tmp = value_g(g==glist(j),:);
    if size(tmp,1)>1
        value_mean(j, :) = nanmean(tmp,1);
        value_std(j, :) = nanstd(tmp,[],1);
        value_sem(j, :) = nanmean(tmp,1)/sqrt(size(tmp,1));
    else
        value_mean(j, :) = tmp;
        value_std(j, :) = nan;
        value_sem(j, :) = nan;
    end
end

figtitle = 'Stamped response fit Custom function';
fmodel = fittype(fmodel_input, 'independent', fmodel_Independent);
coefficientNames = coeffnames(fmodel);

MaxIter = 3;
TotErr = 0.1;    
coefficientValues = [];

scrsz = handles.scrsz;            
maxsubplot = 20;
c = ceil(N/maxsubplot);
for i = 1:c
    pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
    h1 = figure(60+i); clf('reset')
    set(h1, 'Name', figtitle,'Position', pos, 'NumberTitle', 'off'); 
end

for n = 1:size(value_g, 2)
        %%%% plot
    if N<=maxsubplot
        h1 = figure(61);
        subc = round(sqrt(N));
        subr = ceil(N/subc);
        subplot(subr, subc, n)
    else
        fi = ceil(n/maxsubplot);
        subi = n - maxsubplot*(fi-1);
        h1 = figure(60+fi);
        subplot(4, 5, subi)
    end
    y = value_g(:,n); 
    rmse0 = inf;
    iter = 1;
    if sum(~isnan(value_std(:,n)))>0 && max(value_mean(:,n)) - min(value_mean(:,n)) < nanmean(value_std(:,n))
        coefficientValues(n,:) = nan(1, length(coefficientNames));
        fitrmse(n) = nan;
        plot(xx, y, '.')
        ylabel('dF/F'); title([ttlabel{n}, ' fit fail'])
        box off
        continue
    else
        clear fitobj
        while iter<=MaxIter
            [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', fmodel_startpoint);
            rmse1 = gof1.rmse;
            if rmse0-rmse1>TotErr
                fitobj = fitobject1; 
                fitgof = gof1;
                rmse0 = rmse1;
            end
            iter = iter + 1;
        end
        coefficientValues(n,:) = coeffvalues(fitobj);
        fitrmse(n) = rmse0;
        plot(xx, y, '.')
        hold on, plot(fitobj)
        ylabel('dF/F'); title(ttlabel{n})
        box off
    end
end

fitresult.coefficient = coefficientValues;
fitresult.coefficientNames = coefficientNames';
fitresult.rmse = fitrmse;

