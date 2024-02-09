function BatchCallFeatureDetection(handles, k)

handles = featuredetect_batch_init(handles, 0);
[imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
handles.filepath = imagefolder;
handles.filename = [imagefilename, fext];
handles.fext = fext;

%% load registration parameters if exist
RegPara = []; 
if strcmp(fext, '.mat')
    variableinfo = who('-file', handles.Datalist{k});
    if ismember('RegPara', variableinfo)
        load(handles.Datalist{k}, 'RegPara')        
        handles.RegPara = RegPara;
        handles.Regfile = handles.filename;
    end
else
    filenamesub = split(imagefilename,'_');
    if length(filenamesub)>1
        Regfilename = '';
        for i = 1:length(filenamesub)-1
            Regfilename = strcat(Regfilename, filenamesub{i}, '_');
        end
        Regfile = dir(fullfile(handles.filepath, [Regfilename, '*.mat']));
        if ~isempty(Regfile)
            for i = 1:length(Regfile)
            variableinfo = who('-file', fullfile(Regfile(i).folder, Regfile(i).name));
            if ismember('RegPara', variableinfo)
                handles.Regfile = Regfile(i).name;
                load(fullfile(Regfile(i).folder, Regfile(i).name), 'RegPara')        
                handles.RegPara = RegPara;
            end
            end
        end
    end
end

%% load movie
f_wait = waitbar(0, sprintf('Loading Data %d', k), ...
    'Name', 'Loading Data');
loadmovieflag = 0;
if strcmp(fext, '.mat') 
    [loadmovieflag, Mem_max, w, handles] = loadbin_init(handles);
    I1 = [];
%     handles = Call_loadbin(loadmovieflag, Mem_max, w, f_wait, handles);
else
    [loadmovieflag, I1, Mem_max, w, handles] = loadmovie_init(handles);
end
if loadmovieflag == 1
    handles = Call_loadmovie(loadmovieflag, I1, Mem_max, w, f_wait, handles);
end
handles.savename = handles.savenamelist{k};

%% feature detection
ifspine = 0; ifdendrite = 0; ifshaft = 0; im_mask_reg = [];
if handles.withmask == 1 && ~isempty(handles.im_mask)
    g_wait = waitbar(0.5, sprintf('Feature mapping data %d', k), ...
        'Name', 'Processing Data');
    %%%% cross-day registration
    withrotation = handles.defaultPara.ops.withrotation; % 1
    [R_points, t_points, im_mask_reg, handles]...
        = setupCross_SessionReg(handles, handles.im_mask, withrotation, handles.maskdir);
    if ~isempty(handles.dendriteROI_mask)
        handles = dendrite_regmater(handles, t_points, R_points, handles.dendriteROI_mask);
        ifdendrite = 1; 
    end 
    if ~isempty(handles.roi_seed_master) 
        handles = spineROI_regmater(handles, t_points, R_points, handles.roi_seed_master, handles.dendID_mask);
        ifspine = 1;
    end
    if ~isempty(handles.dendriteROI_mask) && ~isempty(handles.roi_seed_master) && handles.shaft_flag > 0
        handles = call_autoshaftDendr(handles, 0, 0, 0);              
    end
else
    g_wait = waitbar(0.5,sprintf('Auto feature detection data %d', k), ...
        'Name', 'Processing Data');
    %%%% auto feature detection using point detection
    sigma = handles.defaultPara.autofeature(1); % 2
    quant = handles.defaultPara.autofeature(2); % 3.5
    [y, x] = Auto_points(handles, [], sigma, quant, 0, 1, 0);
    handles.pt = [x, y];
    if ~isempty(handles.pt)
        [Temptrace, tempRoi, trace_cor, handles] = SegmentationBatch_autoThresh(handles, 0);
    end
    spineROI = saveSpine(handles.roi_seed, handles.roi, handles.trace,...
        handles.im_norm, handles.savepath, handles.savename);
    handles.spineROI = spineROI;
    ifspine = 1;
end
showbatchfeature(handles, im_mask_reg, ifspine, ifdendrite, ifshaft)
close(g_wait)
delete(g_wait)

%% process the whole movie
f_wait = waitbar(0, sprintf('Saving Data %d', k), 'Name', 'Saving Data');
ifhold = 0;
if handles.datatype~=3    
    Save_SingleData(handles, f_wait, ifhold)
else
    Save_SingleData_bin(handles, f_wait, ifhold)
end
