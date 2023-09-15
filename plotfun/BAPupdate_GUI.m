function [BAPremoval_coef, trace_BAPremoval] = ...
    BAPupdate_GUI(dff_all, BAPremoval_coef, trace_BAPremoval, BAP_current, scrsz, titlename, spID)

pos_BAPremove = round([50 scrsz(4)*0.4 min(scrsz(3)/2,550) min(scrsz(4)/2, 400)]);
minF = 0;

for k = 1:size(dff_all, 2)
    trace_current = dff_all(:,k);
    yvalue = trace_current - minF;
    trace_noBAP = trace_BAPremoval(:,k);
    xvalue = BAP_current(:,k) - minF;
    coef = BAPremoval_coef(k);
    [k, coef]
    if isempty(findobj('type','figure','number',22))
        pos = pos_BAPremove;    
    else
        h1_handles = get(figure(22));
        pos = h1_handles.Position;
    end
    hplot = figure(22); clf('reset')
    figtitle = sprintf('%s %d', titlename, spID(k));
    set(hplot,'Name', figtitle ,'Position', pos);
    makeplot(xvalue, yvalue, trace_current, trace_noBAP, coef, figtitle)
    
    c = uicontrol(hplot,'style','slider','Min',0, 'Max', coef*5,...
        'Units', 'normalized',...
        'position',[0.05 0.15 0.4 0.05]);
    c.Value = coef;
    addlistener(c,'ContinuousValueChange',@(hObject, event) ...
        updatecoef(hObject, event, xvalue, yvalue, trace_current, minF,figtitle));
    
    p = uicontrol(hplot,'style','pushbutton',...
        'String', 'Accept',...
        'Units', 'normalized',...
        'position',[0.8 0.1 0.1 0.1],...
        'Callback','uiresume(gcbf)');    
    
    uiwait(hplot)
    newcoef = get(c, 'Value'); 
    [yvalue_new, coef] = BAPremove_auto(yvalue, xvalue, newcoef);
    trace_noBAP = yvalue_new + minF;
    BAPremoval_coef(k) = coef;
    trace_BAPremoval(:,k) = trace_noBAP; 
end

function coef = updatecoef(hObject, event, xvalue, yvalue, trace_current, minF,figtitle)
newcoef = get(hObject, 'Value');
[yvalue_new, coef] = BAPremove_auto(yvalue, xvalue, newcoef);
trace_noBAP = yvalue_new + minF;
makeplot(xvalue, yvalue, trace_current, trace_noBAP, coef,figtitle)

function makeplot(xvalue, yvalue, trace_current, trace_noBAP, coef, figtitle)
hplot = figure(22);
ax1 = subplot(321);
plot(1:length(trace_current), trace_current), title('raw trace')
ylabel('dF/F'), box off
ax2 = subplot(323);
plot(1:length(trace_current), trace_noBAP), title('BAP subtracted')
ylabel('dF/F'), box off
xx = linspace(min(xvalue), max(xvalue), 500);
%   xx = linspace(min(BAP_current), max(BAP_current), 200);
ax3 = subplot(3,2,[2,4]);
cla(ax3, 'reset');
plot(xvalue, yvalue, '.'), 
hold on, plot(xx, xx*coef, 'k'), xlabel('Dendritic signal'), ylabel('Spine/shaft signal')
box off, title(figtitle)