function [handles] = get_spineROImask(handles)

roi_mask = zeros(size(handles.im_norm));
handles.size = size(handles.im_norm);
if ~isempty(handles.roi)
    if size(handles.roi,3) ~= size(handles.spine_trace,2)
        waitfor(msgbox('Number of trace and number spine ROI inconsistent',...
            'Warning', 'warn'))
    else
        roi_mask = handles.roi;
        r_color = linspace(0.1, 0.99, size(handles.spine_trace,2))';
        handles.spinecolor = r_color;        
    end
elseif ~isempty(handles.shaft_trace)
    r_color = linspace(0.1, 0.99, size(handles.shaft_trace,2))';
    handles.shaftcolor = r_color;  
end
handles.roi_mask = roi_mask;