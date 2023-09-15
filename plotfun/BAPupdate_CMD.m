function [BAPremoval_coef, trace_BAPremoval] = ...
    BAPupdate_CMD(dff_all, BAPremoval_coef, trace_BAPremoval, BAP_current, scrsz, titlename, spID)
prompt1 = 'Accept BAP subtracted trace Y/N [y/n]: ';
prompt2 = 'Input new coef: ';
pos_BAPremove = round([50 scrsz(4)*0.4 min(scrsz(3)/2,550) min(scrsz(4)/2, 400)]);
minF = 0;
for k = 1:size(dff_all, 2)
    trace_current = dff_all(:,k);
    yvalue = trace_current - minF;
    trace_noBAP = trace_BAPremoval(:,k);
    xvalue = BAP_current(:,k) - minF;
    coef = BAPremoval_coef(k);

    if isempty(findobj('type','figure','number',22))
        pos = pos_BAPremove;    
    else
        h1_handles = get(figure(22));
        pos = h1_handles.Position;
    end
    h1 = figure(22); clf('reset')
    set(h1,'Name', sprintf('%s %d', titlename, spID(k)),'Position', pos);
    subplot(221), plot(1:length(trace_current), trace_current), title('raw trace')
    subplot(223), plot(1:length(trace_current), trace_noBAP), title('BAP subtracted')
    xx = linspace(min(xvalue), max(xvalue), 500);
%   xx = linspace(min(BAP_current), max(BAP_current), 200);
    subplot(2,2,[2,4]), plot(xvalue, yvalue, '.'), 
    hold on, plot(xx, xx*coef, 'k'), xlabel('Dendritic signal'), ylabel('Spine signal')
    
    comIn = input(prompt1, 's');            
    while ~strcmp(comIn, 'y')
        fprintf(sprintf('BAP subtraction coefficients %.2f \n', coef));
        newcoef = input(prompt2);
        [yvalue_new, coef] = BAPremove_auto(yvalue, xvalue, newcoef);
        trace_noBAP = yvalue_new + minF;
        if isempty(findobj('type','figure','number',22))
            pos = pos_BAPremove;    
        else
            h1_handles = get(figure(22));
            pos = h1_handles.Position;
        end
        h1 = figure(22); clf('reset')
        set(h1,'Name', sprintf('%s %d', titlename, spID(k)),'Position', pos);
        subplot(221), plot(1:length(trace_current), trace_current), title('raw trace')
        subplot(223), plot(1:length(trace_current), trace_noBAP), title('BAP subtracted')
        subplot(2,2,[2,4]), plot(xvalue, yvalue, '.'), 
        hold on, plot(xx, xx*coef, 'k'), xlabel('Dendritic signal'), ylabel('Spine signal')
        comIn = input(prompt1, 's');
    end
    BAPremoval_coef(k) = coef;
    trace_BAPremoval(:,k) = trace_noBAP;            
end
end