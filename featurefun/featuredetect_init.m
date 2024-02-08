function handles = featuredetect_init(handles)
%%%%%%%% initialize handles, set default value %%%%%%%%%%%%%%%%%%%

close(figure(4))  % manual dendritic tracing
close(figure(15)) % manual spine feature
close(figure(7))  % cross-session registration
% clc
para_default = defaultparameter;
handles.savingflag = 0;
% handles.defaultvalue = 0.6;
% handles.thresh = handles.defaultvalue;
handles.linewidth = para_default.linewidth; 
handles.defaultPara = para_default;

handles.filepath = '';

handles.savename = '';
handles.filename = '';
handles.fext = '';
handles.movieinputgrad = 1;
handles.imagelength = [];
handles.imageinfo = [];

handles.Regfile = '';
handles.RegPara = [];
handles.roimask = [];
handles.im_norm = [];
handles.size = [];
handles.roimask = [];
handles.mov2d_filt = [];
handles.mov = [];
handles.pt = [];
handles.tempRoi = [];
handles.Temptrace = [];
handles.id = 0;
handles.roi_seed = [];
handles.roi = [];
handles.trace = [];
handles.spineROI = [];
handles.dendrite = [];
handles.shaft_flag = 0;
handles.dend_shaft = [];

handles.BitsPerSample = [];
handles.bytesPerImage = [];
handles.RawPrecision = '';
handles.WorkingPrecision = '';
handles.movieframeID = [];