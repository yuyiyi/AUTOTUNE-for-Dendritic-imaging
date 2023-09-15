function traceplot22(handles)

if ~isempty(handles.dend_shaft) && ~isempty(handles.spineROI)
    M = 2;
elseif ~isempty(handles.dend_shaft) && isempty(handles.spineROI)
    M = 1;
elseif isempty(handles.dend_shaft) && ~isempty(handles.spineROI)
    M = 1;
else
    M = 0;    
end
if M > 0
    scrsz = handles.scrsz;
    pos_BAPremove = round([50 scrsz(4)*0.4 min(scrsz(3)/2,600) min(scrsz(4)/2,500)]);
    if isempty(findobj('type','figure','number',22))
        pos = pos_BAPremove;    
    else
        h1_handles = get(figure(22));
        pos = h1_handles.Position;
    end
    subi = 1;
    h1 = figure(22); clf('reset')
    if ~isempty(handles.spine_dff)
        mmax = quantile(handles.spine_dff, 0.98);
        mmin = quantile(handles.spine_dff, 0.05);        
        g = mmax-mmin;
        assignin('base', 'dff', handles.spine_dff);
        ff = bsxfun(@plus, handles.spine_dff, cumsum([0,g(1:end-1)]));
        subplot(M,2,subi), plot(1:size(handles.spine_dff,1), ff), title('Spine raw trace')
        ylabel('dF/F'), box off
        subi = subi+1;
    end
    if ~isempty(handles.spine_trace_BAPremoval)
        ff = bsxfun(@plus, handles.spine_trace_BAPremoval, cumsum([0,g(1:end-1)])); 
        subplot(M,2,subi), plot(1:size(handles.spine_dff,1), ff), title('Spine BAP subtracted')
        ylabel('dF/F'), box off
        subi = subi+1;
    end

    if ~isempty(handles.shaft_dff)
        mmax = quantile(handles.shaft_dff, 0.98);
        mmin = quantile(handles.shaft_dff, 0.05);        
        g = mmax-mmin;
        ff = bsxfun(@plus, handles.shaft_dff, cumsum([0,g(1:end-1)]));            
        subplot(M,2,subi), plot(1:size(handles.shaft_dff,1), ff), title('shaft raw trace')
        ylabel('dF/F'), box off
        subi = subi+1;
    end
    if ~isempty(handles.shaft_trace_BAPremoval)
        ff = bsxfun(@plus, handles.shaft_trace_BAPremoval, cumsum([0,g(1:end-1)]));            
        subplot(M,2,subi), plot(1:size(handles.shaft_dff,1), ff), title('shaft BAP subtracted')
        ylabel('dF/F'), box off
        subi = subi+1;
    end
end
