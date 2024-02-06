function varargout = SpineTrace_batch(varargin)
% Last Modified by GUIDE v2.5 20-Apr-2022 14:52:58
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpineTrace_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @SpineTrace_batch_OutputFcn, ...
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

% --- Executes just before SpineTrace_batch is made visible.
function SpineTrace_batch_OpeningFcn(hObject, eventdata, handles, varargin)
% addpath('featurefun')
% addpath('generalfun')
% addpath('regfun')
% addpath('plotfun')
scrsz = get(groot,'ScreenSize');
handles.scrsz = scrsz;
set( hObject, 'Units', 'pixels' );
position = get( hObject, 'Position' );
position(1) = 50;
position(2) = scrsz(4)-50;
set( hObject, 'Position', position );
[~, Mver] = version;    
handles.Mver = Mver;
handles.datatype = 3;
handles.Datalist = '';
handles.savepath = '';
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
handles = featuredetect_batch_init(handles, 1);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SpineTrace_batch_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%%%%%%%%%%%%%%%%%%%%%%% initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SaveNamelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittext_maskpath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_GPUNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittext_savepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_fileNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filelistbox_Callback(hObject, eventdata, handles)
tmp = get(hObject, 'Value');

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

%%%%%%%%%%%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browsesavepath_Callback(hObject, eventdata, handles)
savepath = uigetdir;
if savepath~=0
    handles.savepath = savepath;
    set(handles.edittext_savepath, 'String', handles.savepath);
end
guidata(hObject, handles);

function savenametable_CellEditCallback(hObject, eventdata, handles)
newname = get(hObject, 'Data');
for k = 1:length(newname)
    [~, filename, fext] = fileparts(newname{k});
    if ~strcmp(fext, '.mat')
        newname{k} = [filename, '.mat'];
    end
end
handles.savenamelist = newname(:,1)';
set(handles.savenametable, 'Data', handles.savenamelist')
guidata(hObject, handles);

function LoadROImask_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    [maskfilename, maskfilepath, indx] = uigetfile({'*.mat';'*.*'}, 'Select existing feature map');
    if indx > 0 
       [im_mask, roi_seed_master, dendriteROI_mask, shaft_flag, dendID] =...
            loadROImaskfile(maskfilepath, maskfilename);
       handles.maskdir = fullfile(maskfilepath, maskfilename);
       set(handles.edittext_maskpath, 'String', handles.maskdir);
       if (~isempty(roi_seed_master) || ~isempty(dendriteROI_mask)) && ~isempty(im_mask)
            handles.withmask = 1;
            handles.im_mask = im_mask;
            handles.roi_seed_master = roi_seed_master;
            handles.dendriteROI_mask = dendriteROI_mask;
            handles.shaft_flag = shaft_flag;
            handles.dendID_mask = dendID;
        else 
            msgbox('Invalide target ROI masks') 
        end
    end
end
if handles.withmask == 0
    set(handles.edittext_maskpath,'Enable','off')
    set(handles.edittext_maskpath, 'String', '');
end
guidata(hObject, handles);

function deletefiles_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing inprogress')
else
    handles.Datalist = '';
    handles = featuredetect_batch_init(handles, 1);
end
guidata(hObject, handles);

function browse_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing in progress', 'Warning','warn');
else
    handles = featuredetect_batch_init(handles, 1);
    [handles, ListOfImageNames] = listselectedfiles(handles);
    if ~isempty(handles.Datalist) && ~isempty(handles.filepath)
        filetmp = split(handles.filepath, '\');
        if strcmp(filetmp{end-1}, 'processed') || strcmp(filetmp{end}, 'processed')
            handles.savepath = handles.filepath(1:end-10);
        else
            handles.savepath = handles.filepath;
        end
        set(handles.edittext_savepath, 'String', handles.savepath);        
        set(handles.filelistbox,'Enable','on')
        set(handles.filelistbox, 'string', ListOfImageNames);
        set(handles.savenametable, 'Enable', 'on')
        set(handles.ind_fileNum, 'String',  length(handles.Datalist))
        for k = 1:length(handles.Datalist)
            [imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
            if strcmp(fext, '.mat')
                savename = [regexprep(imagefilename(1:end-13),' ', '_'), '_roi.mat'];                
            else
                savename = [regexprep(imagefilename,' ', '_'), '_roi.mat'];
            end
            handles.savenamelist{k} = savename;
        end
        set(handles.savenametable, 'Data', handles.savenamelist')
    end
end
assignin('base', 'handles', handles)
guidata(hObject, handles);

function Push_runbatch_Callback(hObject, eventdata, handles)
if ~isempty(handles.Datalist) && handles.savingflag == 0 
    handles.savingflag = 1;
    N = length(handles.Datalist);
    for k = 1:N
         %%%% load movie k for processing
        BatchCallFeatureDetection(handles, k)
    end
    msgbox(sprintf('%d data were processed and saved in %s', N, handles.savepath), ...
        'Batch processing finished')
    close(figure(7))
    handles.savingflag = 0;
elseif isempty(handles.datalist)
    msgbox('Please load in data for batch processing')
elseif handles.savingflag == 0
    msgbox('Batch processing inprogress')
end
handles.savingflag = 0;

function FinishProg_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing inprogress')
else
    closereq();
end
