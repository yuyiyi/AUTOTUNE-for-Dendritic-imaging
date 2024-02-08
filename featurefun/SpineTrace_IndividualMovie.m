function varargout = SpineTrace_IndividualMovie(varargin)

% Last Modified by GUIDE v2.5 06-Feb-2024 16:10:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpineTrace_IndividualMovie_OpeningFcn, ...
                   'gui_OutputFcn',  @SpineTrace_IndividualMovie_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before SpineTrace_IndividualMovie is made visible.
function SpineTrace_IndividualMovie_OpeningFcn(hObject, eventdata, handles, varargin)
% addpath('featurefun')
% addpath('generalfun')
% addpath('regfun')
% addpath('plotfun')
scrsz = get(groot,'ScreenSize');
handles.scrsz = scrsz;
set( hObject, 'Units', 'pixels' );
position = get( hObject, 'Position' );
position(1) = 20;
position(2) = scrsz(4)-20;
set( hObject, 'Position', position );
handles.savepath = '';
handles.filepath = '';
handles.filename = '';
handles.fext = '';

%%%%%%%% initialize handles, set default value %%%%%%%%%%%%%%%%%%%
handles = featuredetect_init(handles);
handles.datatype = 3;
set(handles.moviedata_check, 'Value', 0)
set(handles.imageseq_check, 'Value', 0)
set(handles.binfile_check, 'Value', 1)

handles.useGPU = 0;
if gpuDeviceCount>0
    set(handles.ind_GPUNum, 'String', sprintf('%d GPU found', gpuDeviceCount))
    gpudev = gpuDevice(1);
    reset(gpudev)
    set(handles.useGPU_check,'Enable','on')
    set(handles.useGPU_check, 'Value',  handles.useGPU)
    fprintf('GPU Available memory')
    disp(gpudev.AvailableMemory)
    handles.gpudev.AvailableMemory = gpudev.AvailableMemory;
else
    set(handles.ind_GPUNum, 'String', 'No GPU found')
    set(handles.useGPU_check,'Enable','off')
end
[~, Mver] = version;    
handles.Mver = Mver;
cla(handles.CalciumTrace, 'reset')
cla(handles.DisplayResult, 'reset')
cla(handles.CalciumTrace_dendrite, 'reset');
handles.output = hObject;
guidata(hObject, handles);

function varargout = SpineTrace_IndividualMovie_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%-----------------------initialization--------------------------------
function edittext_datapath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittext_savepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_savename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_GPUNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function moviedata_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 1;
    set(handles.imageseq_check, 'Value', 0)
    set(handles.binfile_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);
function imageseq_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 2;
    set(handles.moviedata_check, 'Value', 0)
    set(handles.binfile_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);
function binfile_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 3;
    set(handles.moviedata_check, 'Value', 0)
    set(handles.imageseq_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);

function useGPU_check_Callback(hObject, eventdata, handles)
handles.useGPU = get(hObject, 'Value');
guidata(hObject, handles);
function edit_savename_Callback(hObject, eventdata, handles)
handles.savename = get(handles.edit_savename, 'String');
[~, filename, fext] = fileparts(handles.savename); 
if ~strcmp(fext, '.mat')
    handles.savename = [filename, '.mat'];
    set(handles.edit_savename, 'String', handles.savename)
    handles.savenametmp = [handles.savename(1:end-4), '_temp.mat'];
end
guidata(hObject, handles);

% --------------------------Call back functions--------------------------
%%%%%%%%%%%%%%%%%%%%%%%% directory set up %%%%%%%%%%%%%%%%%%%%%%%%%%
function browsesavepath_Callback(hObject, eventdata, handles)
savepath = uigetdir;
if savepath~=0
    handles.savepath = savepath;
    set(handles.edittext_savepath, 'String', handles.savepath);
end
guidata(hObject, handles);

function browse_Callback(hObject, eventdata, handles)
if handles.savingflag == 0 && ~isempty(handles.savename) && ...
        (~isempty(handles.roi) || ~isempty(handles.dendrite))
    q = questdlg('You have data not saved. Save now?', 'Warning','Save', 'No, continue browsing', 'Save');
    waitfor(q)
    if strcmp(q, 'Save')        
        if handles.datatype == 3
            Save_SingleData_bin(handles)
        else
            Save_SingleData(handles)
        end
        handles.savingflag = 1;
    end
end
set(handles.edittext_datapath, 'String', '')
set(handles.edit_savename, 'String', 'Save Name')
cla(handles.CalciumTrace, 'reset')
cla(handles.DisplayResult, 'reset')
cla(handles.CalciumTrace_dendrite, 'reset');
handles = featuredetect_init(handles);
handles = selectsinglefiles(handles);
if ~isempty(handles.filename)
    filetmp = split(handles.filepath, '\');
    if strcmp(filetmp{end-1}, 'processed') || strcmp(filetmp{end}, 'processed')
        handles.savepath = handles.filepath(1:end-10);
    else
        handles.savepath = handles.filepath;
    end
    set(handles.edittext_savepath, 'String', handles.savepath);   
        
    f_wait = waitbar(0,'Loading Data');
    %%%% setup data path, saving path, whether it's a movie or a sequence
    if handles.datatype ~=3
        [loadmovieflag, I1, Mem_max, w, handles] = loadmovie_init(handles);
    else
        [loadmovieflag, Mem_max, w, handles] = loadbin_init(handles);
        I1 = [];
    end
    handles = Call_loadmovie(loadmovieflag, I1, Mem_max, w, f_wait, handles);
    
    set(handles.edittext_datapath, 'String', fullfile(handles.filepath, handles.filename));
    set(handles.edittext_savepath, 'String', handles.savepath);
    set(handles.edit_savename, 'String', handles.savename)
    handles.savenametmp = [handles.savename(1:end-4), '_temp.mat'];
    axes(handles.DisplayResult)
    roimap = zeros(size(handles.im_norm));
    showROI(handles.size(1), handles.size(2), roimap, handles.im_norm)
    assignin('base', 'handles', handles)
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%% feature detection %%%%%%%%%%%%%%%%%%%%%%%%%%
function autodetection_Callback(hObject, eventdata, handles)
%%%% auto feature detection will reset existing feature data
if ~isempty(handles.im_norm)
    if isempty(handles.dendrite)
        choice = questdlg('Add dendrites?', 'AutoDetection', ...
            'Yes', 'No, detection without dendrite', 'Cancel', 'Yes');
        switch choice
            case 'Yes'
                [handles, ~] = addDendrites(handles);
                autofeature_flag = 1;
            case 'No, detection without dendrite'            
                autofeature_flag = 1;
            case 'Cancel'
                autofeature_flag = 0;
            case ''
                autofeature_flag = 0;
        end
    else
        autofeature_flag = 1;
    end 
    if autofeature_flag == 1
        handles.savingflag = 0;
        handles = Call_autofeature(handles);
        cla(handles.DisplayResult, 'reset');
        cla(handles.CalciumTrace, 'reset');
        cla(handles.CalciumTrace_dendrite, 'reset');
        displayGUIplots(handles, 1, 2)
    end
end
guidata(hObject, handles);

function AddDendrites_Callback(hObject, eventdata, handles)
if ~isempty(handles.im_norm) && ~isempty(handles.mov2d_filt) 
    [handles, refreshflag] = addDendrites(handles);
    handles.savingflag = 0;
    if refreshflag == 1 && ~isempty(handles.roi)
        f_wait = waitbar(0.5,'Rereshing Feature Detection');
        handles = refreshspine(handles); 
        if ~isempty(handles.dend_shaft)
            handles.dend_shaft = [];
            handles.shaft_flag = 0;
        end
        cla(handles.DisplayResult, 'reset');
        cla(handles.CalciumTrace, 'reset');
        displayGUIplots(handles, 1, 1)
        close(f_wait)
        delete(f_wait)        
    end
end
guidata(hObject, handles);

function AddROI_Callback(hObject, eventdata, handles)
if ~isempty(handles.im_norm)    
    handles = call_manualspine(handles);
    spineROI = saveSpine(handles.roi_seed, handles.roi, handles.trace,...
        handles.im_norm, handles.savepath, handles.savename);
    handles.spineROI = spineROI;
    displayGUIplots(handles, 1, 2)
    close(figure(4))
    close(figure(15))
    handles.savingflag = 0;
end
guidata(hObject, handles);

% --- Executes on button press in DeletROI.
function DeletROI_Callback(hObject, eventdata, handles)
% assignin('base', 'handles', handles)
if ~isempty(handles.im_norm)
    rois = [];
    if ~isempty(handles.roi)
        rois = handles.roi;
    end
    if ~isempty(handles.dendrite)
%         length(handles.dendrite)
        for k = 1:length(handles.dendrite)
            dendroi = zeros(size(handles.im_norm));
            ii = handles.dendrite(k).dend_pixel;
            if ~isempty(ii)
                dendroi(ii) = 1;
            end
            rois = cat(3, rois, dendroi);
        end
    end
    if ~isempty(rois)
        deletId = call_deletefeature(handles, rois);
        if ~isempty(deletId)
            handles = refresh_delete(handles, deletId);
            displayGUIplots(handles, 1, 2)
        end
    end
end
close(figure(15))
guidata(hObject, handles);

% --- Executes on button press in addshaft.
function addshaft_Callback(hObject, eventdata, handles)
handles.dend_shaft = [];
displayGUIplots(handles, 1, 2)
clear dend_shaft
if ~isempty(handles.spineROI) && ~isempty(handles.dendrite)
    handles.savingflag = 0;
    handles.shaft_flag = 1;
    handles = call_autoshaftDendr(handles, 1 ,1);
    msgbox('Dendritic shaft feature detection finished')
else
    msgbox('Add dendrites and spines before adding shaft feature')
end
guidata(hObject, handles);

% --- Executes on button press in addshaftwhole.
function addshaftwhole_Callback(hObject, eventdata, handles)
handles.dend_shaft = [];
displayGUIplots(handles, 1, 2)
clear dend_shaft
if ~isempty(handles.im_norm) && ~isempty(handles.dendrite)
    handles.savingflag = 0;
    handles.shaft_flag = 2;
    handles = call_autoshaftDendr(handles, 1, 1);
    msgbox('Dendritic shaft feature detection finished')
else
    msgbox('Add dendrites and spines before adding shaft feature')
end
guidata(hObject, handles);


% --- Executes on button press in LoadMaskROI.
function LoadMaskROI_Callback(hObject, eventdata, handles)
if ~isempty(handles.im_norm)
    [maskfilename, maskfilepath, indx] = uigetfile({'*.mat';'*.*'}, 'Select existing feature map');
    if indx > 0 
        maskdir = fullfile(maskfilepath, maskfilename);
        fprintf('Load feature mask from: %s\n', maskdir);
        [im_mask, roi_seed_master, dendriteROI_mask, shaft_flag, dendID, defaultPara] ...
            = loadROImaskfile(maskfilepath, maskfilename);
        handles.defaultPara = defaultPara;
        assignin('base', 'handles', handles)
        if (~isempty(roi_seed_master) || ~isempty(dendriteROI_mask)) && ~isempty(im_mask)
            handles.shaft_flag = shaft_flag;
            handles.pt = [];
            handles.id = 0;
            handles.spineROI = [];
            handles.roi_seed = [];
            handles.roi = [];
            handles.tempRoi = [];
            handles.Temptrace = [];
            handles.trace = [];
            handles.dend_shaft = [];
            f_wait = waitbar(0.2,'Feature Registration');
            withrotation = handles.defaultPara.ops.withrotation;
            [R_points, t_points, im_mask_reg, handles]...
                = setupCross_SessionReg(handles, im_mask, withrotation, maskdir);
            waitbar(0.5, f_wait,'Feature Registration');
            if ~isempty(dendriteROI_mask)
                handles = dendrite_regmater(handles, t_points, R_points, dendriteROI_mask);
            end 
            if ~isempty(roi_seed_master) 
                handles = spineROI_regmater(handles, t_points, R_points, roi_seed_master, dendID);
            end
            displayGUIplots(handles, 1, 2)
            if ~isempty(dendriteROI_mask) && ~isempty(roi_seed_master) && shaft_flag > 0
                handles = call_autoshaftDendr(handles, 1, 0);              
            end
            close(f_wait), delete(f_wait)
        else
            msgbox('No existing features from the directory')
        end
    end
else
    msgbox('Please load a movie')
end
guidata(hObject, handles);


% --- Executes on button press in SaveResults.
function SaveResults_Callback(hObject, eventdata, handles)
if handles.datatype == 3
    Save_SingleData_bin(handles)
else
    Save_SingleData(handles)
end
handles.savingflag = 1;
msgbox('Saving completed')
guidata(hObject, handles);

% --- Executes on button press in FinishProg.
function FinishProg_Callback(hObject, eventdata, handles)
if handles.savingflag == 0 && ~isempty(handles.savename) && ...
        (~isempty(handles.roi) || ~isempty(handles.dendrite))
    msgbox('Data not saved, press Save Results button before closing the program')
else
    close(figure(4))  % manual dendritic tracing
    close(figure(15)) % manual spine feature
    close(figure(7))  % cross-session registration
    closereq();
end

% --- Executes on button press in DendriticProc_Batch.
function DendriticProc_Batch_Callback(hObject, eventdata, handles)
if handles.savingflag == 0 && ~isempty(handles.savename) && ...
        (~isempty(handles.roi) || ~isempty(handles.dendrite))
    msgbox('Data not saved, press Save Results button before batch processing')
else
    SpineTrace_batch
    close(figure(4))  % manual dendritic tracing
    close(figure(15)) % manual spine feature
    close(figure(7))  % cross-session registration
    closereq();
end
