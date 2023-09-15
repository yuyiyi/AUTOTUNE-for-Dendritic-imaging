function displayGUIplots(handles, ifspine, ifdendrite)
if nargin == 1
    if ~isempty(handles.roi)
        ifspine = 1;
    else
        ifspine = 0;
    end
    if ~isempty(handles.dendrite)         
        ifdendrite = 2;
    else
        ifdendrite = 0;
    end
end
if ifspine == 0 && ifdendrite == 0
    roimap = zeros(size(handles.im_norm));
    showROI(d1, d2, roimap, handles.im_norm)
end
if ifspine == 1
    % plot spine roi and trace
    roi_mask = [];
    r_color_pool = linspace(0.1, 0.99, 10)';
    ii = mod(1:size(handles.roi,3), 10);
    ii(ii==0) = 10;
    r_color = r_color_pool(ii);
    cla(handles.DisplayResult, 'reset');
    cla(handles.CalciumTrace, 'reset');
    if ~isempty(handles.roi)
        if size(handles.roi,3) ~= size(handles.trace,2)
            msgbox('Number of trace and number spine ROI inconsistent', 'Warning', 'warn')
        end
        roi_mask = handles.roi;
%         r_color = linspace(0.1, 0.99, size(handles.trace,2))';
        cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));

        mmax = quantile(handles.trace, 0.9);
        mmin = quantile(handles.trace, 0.1);
        g = mmax-mmin;
        ff = bsxfun(@plus, handles.trace, cumsum([0,g(1:end-1)]));
        axes(handles.CalciumTrace), hold on
        for i =1:size(handles.trace,2)
            plot(1:size(handles.trace,1),ff(:,i), 'color', cc(i,:))
            drawnow
        end
        title('Spine signal')
        drawnow
%         assignin('base', 'trace', handles.trace);
    else
        roi_mask = zeros(size(handles.im_norm));
    end
    axes(handles.DisplayResult)
    showROI_3D(size(handles.im_norm,1), size(handles.im_norm,2), roi_mask, handles.im_norm, r_color')
    drawnow
end

if ifspine == 2
    % add spine roi and trace
    roi_mask = [];
    r_color_pool = linspace(0.1, 0.99, 10)';
    ii = mod(1:size(handles.roi,3), 10);
    ii(ii==0) = 10;
    r_color = r_color_pool(ii);
    cla(handles.DisplayResult, 'reset');
%     cla(handles.CalciumTrace, 'reset');
    if ~isempty(handles.roi)
        if size(handles.roi,3) ~= size(handles.trace,2)
            msgbox('Number of trace and number spine ROI inconsistent', 'Warning', 'warn')
        end
        roi_mask = handles.roi;
        cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));

        mmax = quantile(handles.trace, 0.9);
        mmin = quantile(handles.trace, 0.1);
        g = mmax-mmin;
        ff = handles.Temptrace + sum(g(1:end-1));
        axes(handles.CalciumTrace), hold on
        plot(1:size(handles.Temptrace,1),ff, 'color', cc(end,:))
        drawnow
        title('Spine signal')
        drawnow
%         assignin('base', 'trace', handles.trace);
    else
        roi_mask = zeros(size(handles.im_norm));
    end
    axes(handles.DisplayResult)
    showROI_3D(size(handles.im_norm,1), size(handles.im_norm,2), roi_mask, handles.im_norm, r_color')
    drawnow
end

if ~isempty(handles.dendrite) && ifdendrite > 0
    % plot dendrite roi
    axes(handles.DisplayResult)
    dend_line_all = [];
    for i = 1:length(handles.dendrite)
        dend_line = handles.dendrite(i).dend_line;
        if ~isempty(dend_line)
            dend_line_all = cat(1, dend_line_all, [dend_line, ones(size(dend_line,1),1)*i]);
            dend_trace(:,i) = handles.dendrite(i).trace;
            hold on, plot(dend_line(:,1),dend_line(:,2))
        end
    end
end
if ~isempty(handles.dendrite) && ifdendrite == 2
    % plot dendrite trace 
    cla(handles.CalciumTrace_dendrite, 'reset');
    handles.dend_trace = dend_trace;
    handles.dend_line_all = dend_line_all;
    mmax = quantile(handles.dend_trace, 0.95);
    mmin = quantile(handles.dend_trace, 0.05);
    g = mmax-mmin;
    ff = bsxfun(@plus, dend_trace, cumsum([0,g(1:end-1)]));
    axes(handles.CalciumTrace_dendrite)
    hold on, plot(1:size(dend_trace,1), ff)
end

axes(handles.DisplayResult)
% showscalebar(handles.im_norm, handles.linewidth)