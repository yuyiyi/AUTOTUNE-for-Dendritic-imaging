function multiplot_segment(xx, yy, er, segX, seglist, ttlabel, figiniID)
featureseg = unique(seglist);
cc = colormap(hsv(length(featureseg)));

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
    end
end

function generatesubplot(er, xx, yy, i)
    if isempty(er)
        plot(xx, yy(:,i)); box off
        axislimit = [min(xx)-1 max(xx)+1 min(yy(:)) max(yy(:))];
    else
        shadedErrorBar(xx, yy(:,i), er(:,i)); box off
        axislimit = [min(xx)-1 max(xx)+1 min(yy(:,i)-er(:,i)) max(yy(:,i)+er(:,i))];
    end
    axis(axislimit)
    for i = 1:length(segX)-1
        box_X = segX([i,i+1,i+1,i]);
        box_Y = axislimit([3,3,4,4]);
        ii = find(featureseg==seglist(i));
        patch(box_X, box_Y, cc(ii,:),'FaceAlpha',0.2)
    end
    ylabel('dF/F'); %title(ttlabel{i})
end

end