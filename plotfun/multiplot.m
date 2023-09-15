function multiplot(xx, yy, er, xxlabel, ttlabel, figiniID)
if isempty(xxlabel)
    xlabelon = 0;
else
    xlabelon = 1;
end

N = size(yy,2);
if N<=20
    h1 = figure(figiniID+1);
    subc = round(sqrt(N));
    subr = ceil(N/subc);
    for i = 1:N
        subplot(subr, subc, i)
        if isempty(er)
            plot(xx, yy(:,i),'.','markersize',15); box off
            axis([min(xx)-1 max(xx)+1 min(yy(:)) max(yy(:))])
        else
            errorbar(xx, yy(:,i), er(:,i),'.','markersize',15); box off
            axis([min(xx)-1 max(xx)+1 min(yy(:,i)-er(:,i)) max(yy(:,i)+er(:,i))])
        end
%         if xlabelon
%             ax = gca;
%             ax.XTick = xx; 
%             ax.XTickLabel = xxlabel;
%         end
        if xlabelon
            ax = gca;
            ax.XTick = xx; 
            ax.XTickLabel = xxlabel;
%           xticks(xx); 
%           xticklabels(xxlabel)
        end
        ylabel('dF/F'); title(ttlabel{i})
    end
else
    c = ceil(N/20);
    for k = 1:c
        h1 = figure(figiniID + k);
        for i = 1:20
            id = (k-1)*20+i;
            if id<=N
                subplot(4, 5, i)
                if isempty(er)
                    plot(xx, yy(:,id),'.','markersize',15); box off
                    axis([min(xx)-1 max(xx)+1 min(yy(:)) max(yy(:))])
                else
                    errorbar(xx, yy(:,id), er(:,id),'.','markersize',15); box off
                    axis([min(xx)-1 max(xx)+1 min(yy(:,id)-er(:,id)) max(yy(:,id)+er(:,id))])
                end

                if xlabelon
                    ax = gca;
                    ax.XTick = xx; 
                    ax.XTickLabel = xxlabel;
%                     xticks(xx); 
%                     xticklabels(xxlabel)
                end
                ylabel('dF/F'); title(ttlabel{id})
            end
        end
    end
end
