function handles = call_autoBAP(handles)
minF = 0;
if ~isempty(handles.spine_dff)
    spID = handles.spine_title;
    if isempty(handles.spine_trace_BAPremoval) ...
            || isempty(handles.spine_BAPremoval_coef) ...
            || isempty(handles.spine_BAP_current)
        trace_BAPremoval = []; BAPremoval_coef = []; BAP_all = [];
        for k = 1:size(handles.spine_dff,2)
            trace_current = handles.spine_dff(:,k);
            yvalue = trace_current - minF;
            id = handles.spineROI(spID(k)).dendriteID;
%             assignin('base', 'roi_seed', handles.roi_seed);
%             assignin('base', 'dend_line_all', handles.dend_line_all);
            BAP_current = handles.dend_dff(:,id);
            xvalue = BAP_current - minF;
            BAP_all(:,k) = BAP_current;
            handles.spine_BAP_current(:,k) = BAP_all(:,k);
            [yvalue_new, coef] = BAPremove_auto(yvalue, xvalue);
            trace_noBAP = yvalue_new + minF;
            BAPremoval_coef(k) = coef;
            handles.spine_BAPremoval_coef(k) = coef;
            trace_BAPremoval(:,k) = trace_noBAP;
            handles.spine_trace_BAPremoval(:,k) = trace_noBAP;      
            handles.spine_BAPdendID(k) = id;
        end
    end
end

if ~isempty(handles.dend_shaft)
    if isempty(handles.shaft_trace_BAPremoval) ...
            || isempty(handles.shaft_BAPremoval_coef) ...
            || isempty(handles.shaft_BAP_current)
        trace_BAPremoval = []; BAPremoval_coef = []; BAP_all = [];
        k = 0;
        for i = 1:size(handles.dend_shaft,2)
            if ~isempty(handles.dend_shaft(i).shaft_trace)
                k = k+1;
                id = handles.dend_shaft(i).dendriteID;
                trace_current = handles.shaft_dff(:,k);
                yvalue = trace_current - minF;
                BAP_current = handles.dend_dff(:,id);
                xvalue = BAP_current - minF;
                BAP_all(:,k) = BAP_current;
                handles.shaft_BAP_current(:,k) = BAP_all(:,k);
                [yvalue_new, coef] = BAPremove_auto(yvalue, xvalue);
                trace_noBAP = yvalue_new + minF;
                BAPremoval_coef(k) = coef;
                handles.shaft_BAPremoval_coef(k) = coef;
                trace_BAPremoval(:,k) = trace_noBAP;
                handles.shaft_trace_BAPremoval(:,k) = trace_noBAP;      
                handles.shaft_BAPdendID(k) = id;
            end
        end
    end
end