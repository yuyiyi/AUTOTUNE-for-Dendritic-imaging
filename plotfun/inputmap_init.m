function handles = inputmap_init(handles)
handles.savename = '';
handles.filename = '';
handles.savepath = ''; 
handles.framestampname = '';
handles.framestamppath = '';
handles.stampinfoname = '';
handles.stampinfopath = '';
handles.framestampvariable = 'framestamp';
handles.stampinfovariable = 'stampinfo';
handles.framestamp = [];
handles.stampinfo = [];
handles.StampRespFit = [];
handles.StampResp = [];
handles.plotRawdff = 1;
handles.plotBAPdff = 0;
handles.plotFiltdff = 0;
handles.circularfit = 0; %%%% if fit wrapped gaussian

close(figure(22))
close(figure(12))

handles.im_norm = [];
handles.linewidth = [];
% spine
handles.spineROI = []; % structure
handles.roi = [];
handles.roi_seed = [];
handles.spine_trace = [];
handles.spine_dff = [];
handles.spine_filt = [];
handles.spine_BAP_current = [];
handles.spine_trace_BAPremoval = [];
handles.spine_BAPremoval_coef = [];
handles.roi_mask = [];
handles.spinecolor = [];
% dendrite
handles.dendrite = []; % structure
handles.dend_trace = [];
handles.dend_dff = [];
handles.dend_filt = [];
handles.dend_line_all = [];
% shaft
handles.dend_shaft = [];  % structure
handles.shaft_trace = [];
handles.shaft_dff = [];
handles.shaft_filt = [];
handles.shaft_BAP_current = [];
handles.shaft_trace_BAPremoval = [];
handles.shaft_BAPremoval_coef = [];
% custom features
handles.variablename = [];
handles.cfeature_dff = [];
handles.cfeature_filt = [];
handles.cfeature_trace = [];
handles.feature_title = [];

para_default = defaultparameter;
handles.defaultPara = para_default;


clc

