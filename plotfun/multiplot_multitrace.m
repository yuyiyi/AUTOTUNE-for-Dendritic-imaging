function multiplot_multitrace(xx, yy, er, cc, ttlabel, figiniID)

N = size(yy,2);
if N<=20
    h1 = figure(figiniID+1);
    subc = round(sqrt(N));
    subr = ceil(N/subc);
    for i = 1:N
        subplot(subr, subc, i),        
        generatesubplot(er, xx, yy,i)
    end
else
    c = ceil(N/20);
    for k = 1:c
        h1 = figure(figiniID + k);
        for i = 1:20
            id = (k-1)*20+i;
            if id<=N
                subplot(4, 5, i),
                generatesubplot(er,xx,yy,id)
            end
        end
        drawnow
    end
end

function generatesubplot(er, xx, yy, i)
    if isempty(er)
        hold on, 
        plot(xx, yy(:,i),'color',cc); box off
        axislimit = [min(xx)-1 max(xx)+1 min(yy(:)) max(yy(:))];
    else
        hold on,
        shadedErrorBar(xx, yy(:,i), er(:,i), {'-','color',cc}); box off
        axislimit = [min(xx)-1 max(xx)+1 min(yy(:,i)-er(:,i)) max(yy(:,i)+er(:,i))];
    end
    ylabel('dF/F'); title(ttlabel{i})
end
end