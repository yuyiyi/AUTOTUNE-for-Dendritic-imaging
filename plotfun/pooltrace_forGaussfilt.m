function [trace_stamp, trace_num, ttlabel, tracetype] = pooltrace_forGaussfilt(handles)

trace_stamp = []; trace_num = 0; tracetype = [];
ttlabel = [];
if ~isempty(handles.cfeature_dff)
    trace_stamp = cat(2, trace_stamp, handles.cfeature_dff);        
    for i = 1:size(handles.cfeature_dff,2)
        trace_num = trace_num+1;
        tracetype(trace_num) = 1;
        ttlabel{trace_num} = [handles.feature_title{i}, ' dff'];
    end
end
if ~isempty(handles.spine_dff)
    trace_stamp = cat(2, trace_stamp, handles.spine_dff);        
    for i = 1:size(handles.spine_dff,2)
        trace_num = trace_num+1;
        tracetype(trace_num) = 1;
        ttlabel{trace_num} = sprintf('Spine %d raw', handles.spine_title(i));
    end
end
if ~isempty(handles.shaft_dff)
    trace_stamp = cat(2, trace_stamp, handles.shaft_dff); 
    for i = 1:length(handles.dend_shaft)
        if ~isempty(handles.dend_shaft(i).shaft_trace)
            trace_num = trace_num+1;
            tracetype(trace_num) = 2;
            ttlabel{trace_num} = sprintf('Shaft %d raw', i);
        end
    end
end
if ~isempty(handles.dend_dff)
    trace_stamp = cat(2, trace_stamp, handles.dend_dff);
    for i = 1:size(handles.dend_dff,2)
        trace_num = trace_num+1;
        tracetype(trace_num) = 3;
        ttlabel{trace_num} = sprintf('dendritic %d raw', handles.dend_title(i));
    end
end
