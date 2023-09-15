function [handles] = callgaussfilt_master(handles, dataID, fps, w1, w2)
if nargin<2
    dataID = 1;
end
handles = loadtrace(handles, dataID);

if ~isempty(handles.spineROI)
    spID = handles.spine_title;
    spineROI = handles.spineROI;
    trace_stamp = handles.spine_dff;
    [tc2, finalBaseline_out] = F_Preprocess_v2(trace_stamp', fps, 0, w1, w2);
    handles.spine_filt = tc2;
    for i = 1:length(spID)
        spineROI(spID(i)).dff_filt = tc2(:,i);
    end
    handles.spineROI = spineROI;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'spineROI', '-append')
    handles.Gaussfilttrace = 1;
end
if ~isempty(handles.dend_shaft)
    shID = handles.shaft_title;
    dend_shaft = handles.dend_shaft;       
    trace_stamp = handles.shaft_dff;    
    [tc2, finalBaseline_out] = F_Preprocess_v2(trace_stamp', fps, 0, w1, w2);
    handles.shaft_filt = tc2;
    for i = 1:length(shID)
        dend_shaft(shID(i)).dff_filt = tc2(:,i);
    end
    handles.dend_shaft = dend_shaft;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'dend_shaft', '-append')
    handles.Gaussfilttrace = 1;
end
if ~isempty(handles.dendrite)
    deID = handles.dend_title;
    dendriteROI = handles.dendrite;       
    trace_stamp = handles.dend_dff;    
    [tc2, finalBaseline_out] = F_Preprocess_v2(trace_stamp', fps, 0, w1, w2);
    handles.dend_filt = tc2;
    for i = 1:length(deID)
        dendriteROI(deID(i)).dff_filt = tc2(:,i);
    end
    handles.dendrite = dendriteROI;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'dendriteROI', '-append')
    handles.Gaussfilttrace = 1;
end
if ~isempty(handles.cfeature_dff)
    trace_stamp = handles.cfeature_dff;
    [dff_gaussfilt, finalBaseline_out] = F_Preprocess_v2(trace_stamp', fps, 0, w1, w2);
    handles.cfeature_filt = dff_gaussfilt;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'dff_gaussfilt', '-append')
    handles.Gaussfilttrace = 1;
end
notesfilt = 'denoise baseline by Gaussian filter';
save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'notesfilt', '-append')