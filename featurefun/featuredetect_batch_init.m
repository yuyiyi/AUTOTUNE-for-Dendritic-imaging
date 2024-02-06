function handles = featuredetect_batch_init(handles, batchini)
close(figure(7))  % cross-session registration
if batchini
    handles.savingflag = 0;
    handles.defaultvalue = 0.6;
    handles.thresh = handles.defaultvalue;
    handles.linewidth = 6;
    handles.savenamelist = '';
    handles.filepath = '';

    set(handles.savenametable, 'Data', handles.savenamelist')
    set(handles.savenametable, 'Enable', 'off')
    
    set(handles.edittext_savepath, 'String',  handles.savepath)
    handles.currentImagelist = '';
    if handles.datatype == 1
        set(handles.moviedata_check, 'Value', 1)
        set(handles.imageseq_check, 'Value', 0)
        set(handles.binfile_check, 'Value', 0)
    elseif handles.datatype == 2
        set(handles.moviedata_check, 'Value', 0)
        set(handles.imageseq_check, 'Value', 1)
        set(handles.binfile_check, 'Value', 0)
    elseif handles.datatype == 3
        set(handles.moviedata_check, 'Value', 0)
        set(handles.imageseq_check, 'Value', 0)
        set(handles.binfile_check, 'Value', 1)
    end
    set(handles.filelistbox,'Enable','off')
    set(handles.filelistbox, 'string', handles.Datalist);
    set(handles.ind_fileNum, 'String',  length(handles.Datalist))

    handles.withmask = 0;
    handles.maskdir = '';
    handles.im_mask = [];
    handles.roi_seed_master = [];
    handles.dendriteROI_mask = [];
    handles.shaft_flag = 0;
    handles.dendID_mask = [];
    set(handles.LoadROImask_check, 'Value', 0);
    set(handles.edittext_maskpath,'Enable','off')
    set(handles.edittext_maskpath, 'String', '');
end

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
handles.dend_shaft = [];

handles.BitsPerSample = [];
handles.bytesPerImage = [];
handles.RawPrecision = '';
handles.WorkingPrecision = '';
handles.movieframeID = [];


