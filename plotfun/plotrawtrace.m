function plotrawtrace(handles)
scrsz = handles.scrsz;
M = 0;
if ~isempty(handles.spine_trace)
    M = M+2;
end
if ~isempty(handles.shaft_trace)
    M = M+2;
end
if ~isempty(handles.dend_trace)
    M = M+1;
end
if M>3
    M2 = 2;
    M1 = ceil(M/M2);
else
    M2 = 1;
    M1 = M;
end
pos_trace = round([20 30 800 500]);

if isempty(findobj('type','figure','number',12))
    pos = pos_trace;    
else
    h1_handles = get(figure(12));
    pos = h1_handles.Position;
end
h1 = figure(12); clf('reset')
set(h1,'Name', 'Calcium traces','Position', pos);

sub1 = 1; sub2 = sub1+M2; sub3 = 1;
if ~isempty(handles.spine_trace)
    r_color = handles.spinecolor;
    cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));

    figure(12); 
    subplot(M1,M2,[sub1,sub2])
    mmax = quantile(handles.spine_trace, 0.9);
    mmin = quantile(handles.spine_trace, 0.1);
    g = mmax-mmin;
    ff = bsxfun(@plus, handles.spine_trace, cumsum([0,g(1:end-1)]));
    for i =1:min(size(handles.spine_trace,2),10)
        plot(1:size(handles.spine_trace,1), ff(:,i))
        hold on
    end
    title('Spine signal'), axis tight, box off
    sub1 = sub1+1;
    sub2 = sub2+1;
    sub3 = sub3+2;
end
if ~isempty(handles.shaft_trace)
    r_color = handles.shaftcolor;
    cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));
    figure(12);     
    subplot(M1,M2,[sub1,sub2])
    mmax = quantile(handles.shaft_trace, 0.9);
    mmin = quantile(handles.shaft_trace, 0.1);
    g = mmax-mmin;
    ff = bsxfun(@plus, handles.shaft_trace, cumsum([0,g(1:end-1)]));
    for i =1:min(10,size(handles.shaft_trace,2))
        if i>length(r_color)
            j = mod(i, length(r_color));
            if j==0
                j = length(r_color);
            end
        else
            j = i;
        end
        plot(1:size(handles.shaft_trace,1), ff(:,i))
        hold on
    end
    title('shaft signal'), axis tight, box off
    sub1 = sub1+1;
    sub2 = sub2+1;
    sub3 = sub3+2;
end
if ~isempty(handles.dend_trace)
    mmax = quantile(handles.dend_trace, 0.95);
    mmin = quantile(handles.dend_trace, 0.05);
    g = mmax-mmin;
    ff = bsxfun(@plus, handles.dend_trace, cumsum([0,g(1:end-1)]));
    figure(12); subplot(M1,M2,sub3)
    hold on, plot(1:size(handles.dend_trace,1), ff)
    title('Dendritic signal'), box off
end
drawnow
