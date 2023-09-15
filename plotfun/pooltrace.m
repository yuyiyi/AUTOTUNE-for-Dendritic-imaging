function [trace_stamp, trace_num, ttlabel, tracetype] = pooltrace(handles)

trace_stamp = []; trace_num = 0; tracetype = [];
ttlabel = [];
if handles.plotRawdff == 1 
    if ~isempty(handles.cfeature_dff)
        trace_stamp = cat(2, trace_stamp, handles.cfeature_dff);        
        for i = 1:size(handles.cfeature_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 1;
            ttlabel{trace_num} = [handles.feature_title{i}, ' dff'];
        end
    end
    if ~isempty(handles.dend_dff)
        trace_stamp = cat(2, trace_stamp, handles.dend_dff);
        for i = 1:size(handles.dend_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 3;
            ttlabel{trace_num} = sprintf('dendritic %d dff', handles.dend_title(i));
        end
    end
    if ~isempty(handles.spine_dff)
        trace_stamp = cat(2, trace_stamp, handles.spine_dff);        
        for i = 1:size(handles.spine_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 1;
            ttlabel{trace_num} = sprintf('Spine %d dff', handles.spine_title(i));
        end
    end
    if ~isempty(handles.shaft_dff)
        trace_stamp = cat(2, trace_stamp, handles.shaft_dff); 
        for i = 1:length(handles.dend_shaft)
            if ~isempty(handles.dend_shaft(i).shaft_trace)
                trace_num = trace_num+1;
                tracetype(trace_num) = 2;
                ttlabel{trace_num} = sprintf('Shaft %d dff', i);
            end
        end
    end
end
if handles.plotBAPdff == 1 
    if ~isempty(handles.spine_trace_BAPremoval)
        trace_stamp = cat(2, trace_stamp, handles.spine_trace_BAPremoval); 
        for i = 1:size(handles.spine_trace_BAPremoval,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 1;
            ttlabel{trace_num} = sprintf('Spine %d BAP remove', handles.spine_title(i));
        end
    end
    if ~isempty(handles.shaft_trace_BAPremoval)
        trace_stamp = cat(2, trace_stamp, handles.shaft_trace_BAPremoval); 
        for i = 1:length(handles.dend_shaft)
            if ~isempty(handles.dend_shaft(i).shaft_trace)
                trace_num = trace_num+1;
                tracetype(trace_num) = 2;
                ttlabel{trace_num} = sprintf('Shaft %d BAP remove', i);
            end
        end
    end
end
if handles.plotFiltdff == 1
    if ~isempty(handles.cfeature_filt)
        trace_stamp = cat(2, trace_stamp, handles.cfeature_filt); 
        for i = 1:size(handles.cfeature_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 1;
            ttlabel{trace_num} = [handles.feature_title{i}, ' filt'];
        end
    end
    if ~isempty(handles.dend_filt)
        trace_stamp = cat(2, trace_stamp, handles.dend_filt);
        for i = 1:size(handles.dend_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 3;
            ttlabel{trace_num} = sprintf('dendritic %d filt', handles.dend_title(i));
        end
    end
    if ~isempty(handles.spine_filt)
        trace_stamp = cat(2, trace_stamp, handles.spine_filt); 
        for i = 1:size(handles.spine_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 1;
            ttlabel{trace_num} = sprintf('Spine %d filt', handles.spine_title(i));
        end
    end
    if ~isempty(handles.shaft_filt)
        trace_stamp = cat(2, trace_stamp, handles.shaft_filt); 
        for i = 1:size(handles.shaft_dff,2)
            trace_num = trace_num+1;
            tracetype(trace_num) = 2;
            ttlabel{trace_num} = sprintf('Shaft %d filt', handles.shaft_title(i));
        end
    end
end