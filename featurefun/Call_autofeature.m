function handles = Call_autofeature(handles)
clc
handles.pt = [];
handles.id = 0;
handles.spineROI = [];
handles.roi_seed = [];
handles.roi = [];
handles.tempRoi = [];
handles.Temptrace = [];
handles.trace = [];
handles.dend_shaft = [];

f_wait = waitbar(0.2,'Auto Feature Detection progressing');
sigma = handles.defaultPara.autofeature(1); % 2
quant = handles.defaultPara.autofeature(2); % 3.5
[y, x] = Auto_points(handles, [], sigma, quant, 0, 1);
handles.pt = [x, y];
waitbar(0.5, f_wait, 'Auto Feature Detection progressing');
[Temptrace, tempRoi, trace_cor, handles] = SegmentationBatch_autoThresh(handles, 0);
waitbar(0.8, f_wait, 'Auto Feature Detection progressing');
spineROI = saveSpine(handles.roi_seed, handles.roi, handles.trace,...
    handles.im_norm, handles.savepath, handles.savename);
handles.spineROI = spineROI;
close(f_wait)
delete(f_wait)