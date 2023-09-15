function [fitresult, figtitle, fmodel, xx, value_g] =...
    FitstampResp_v2(trace_stamp, framestamp, stampsel, stampinfo,...
    glist_all,varsel,...
    fmodel_input, fmodel_Independent,fmodel_startpoint,...
    funcsel, xvalue, handles, ttlabel, figiniID, datatitle)

N = size(trace_stamp,2);
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
for j = 1:length(t0)
    value_g(j,:) = nanmean(trace_stamp(t0(j):t1(j), :),1); % [stimulus block X neuron]
end

glist = sort(unique(g),1);
gkeep = zeros(length(g),1);
if length(stampsel)<length(glist)
    gkeep = ismember(g, glist(stampsel));
    g = g(gkeep==1);
    value_g = value_g(gkeep==1,:);
    glist = glist(stampsel);
end

xx = zeros(length(g),1);
value_std = zeros(length(glist), size(value_g, 2));
value_sem = zeros(length(glist), size(value_g, 2));
value_mean = zeros(length(glist), size(value_g, 2));
for j = 1:length(glist)
    xx(g==glist(j)) = xvalue(j);
    if sum(g==glist(j))>0
        tmp = value_g(g==glist(j),:);
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

switch funcsel
    case 2 % 1 Gaussian fitting
        if handles.circularfit 
            fmodel = fittype('wrapped_1gaussian(x, a, mu, sigma)');
            figtitle = 'wrapped1Gaussian';
        else
            fmodel = fittype('gauss1');
            figtitle = '1Gaussian';
        end
    case 3 % 2 Gaussian fitting
        if handles.circularfit 
            fmodel = fittype('wrapped_2gaussian(x, a1, a2, mu, sigma1, sigma2)');
            figtitle = 'wrapped2Gaussian';
        else
            fmodel = fittype('a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-(b1+pi))/c2)^2)','independent', 'x');
            figtitle = '2Gaussian';
        end
    case 4 % Linear without intercept
        figtitle = 'linearWintercept';
        fmodel = fittype(@(p1, x) p1*x);
    case 5 % Linear with intercept
        figtitle = 'linear';
        fmodel = fittype('poly1');
    case 6
        figtitle = 'poly2';
        fmodel = fittype('poly2');        
    case 7 % Sigmoidal
        figtitle = 'Sigmoidal';
        fmodel = fittype('1./(1+exp((x-a)./b))+c', 'independent', 'x');
        xx = xx-nanmin(xx);
        xx = xx/nanmax(xx);
    case 8
        figtitle = 'Custom';
        fmodel = fittype(fmodel_input, 'independent', fmodel_Independent);
end
coefficientNames = coeffnames(fmodel);

MaxIter = 3;
TotErr = 0.1;    
coefficientValues = [];

scrsz = handles.scrsz;            
maxsubplot = 20;
c = ceil(N/maxsubplot);
for i = 1:c
    pos = round([i*10 scrsz(4)*0.4-i*10 min(700,scrsz(3)/2) min(450,scrsz(4)/2)]);
    h1 = figure(figiniID+i); clf('reset')
    set(h1, 'Name', [datatitle, ' fit ' figtitle], 'Position', pos, 'NumberTitle', 'off'); 
end

for n = 1:size(value_g, 2) 
        %%%% plot
    if N<=maxsubplot
        h1 = figure(figiniID+1);
        subc = round(sqrt(N));
        subr = ceil(N/subc);
        subplot(subr, subc, n)
    else
        fi = ceil(n/maxsubplot);
        subi = n - maxsubplot*(fi-1);
        h1 = figure(figiniID+fi);
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
        clear fitobject
        [~, a] = max(y);
        c = nanmean(y)/(nanmean(xx)+eps);
        cc = nanmean(y)/(nanmean(xx.^2)+eps);
       while iter<=MaxIter
            if funcsel== 2 % 1 Gaussian fitting                
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', [1,xx(a), 4/pi]);
            elseif funcsel== 3 % 2 Gaussian fitting
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', [1,1,xx(a), 4/pi, 4/pi]);
            elseif funcsel ==4 % linear
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', c);
            elseif funcsel ==5 % linear
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', [c, 0]);
            elseif funcsel ==6 % poly2
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', [cc, c, 0]);
            elseif funcsel ==7 % Sigmoidal
                if corr(xx, y)>0
                    b = -1;
                else
                    b = 1;
                end
                [fitobject1, gof1] = fit(xx, y/max(y), fmodel, 'Startpoint', [1, b, 0]);
            elseif funcsel == 8
                [fitobject1, gof1] = fit(xx, y, fmodel, 'Startpoint', fmodel_startpoint);
            end
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
        x = linspace(0, 2 * pi, 100);
        if handles.circularfit && funcsel == 2
            hold on, plot(x, wrapped_1gaussian(x, coefficientValues), 'r-')
        elseif handles.circularfit && funcsel == 3
            hold on, plot(x, wrapped_2gaussian(x, coefficientValues), 'r-')            
        else
            hold on, plot(fitobj)
        end
        ylabel('dF/F'); title(ttlabel{n})
        box off
    end
end

fitresult.coefficient = coefficientValues;
fitresult.coefficientNames = coefficientNames';
fitresult.rmse = fitrmse;

