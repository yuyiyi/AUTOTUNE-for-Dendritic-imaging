function handles = featuredetect_init(handles)
close(figure(4))  % manual dendritic tracing
close(figure(15)) % manual spine feature
close(figure(7))  % cross-session registration
% clc

handles.savingflag = 0;
handles.defaultvalue = 0.6;
handles.thresh = handles.defaultvalue;
handles.defaultPara.GaussKernel = [4, 4, 2];
handles.linewidth = 6;

handles.Regfile = '';
handles.RegPara = [];
handles.savename = '';
handles.filepath = '';
handles.filename = '';
handles.fext = '';
handles.movieinputgrad = 1;
handles.imagelength = [];
handles.imageinfo = [];

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