function varargout = RegistrationWin(varargin)
% developed by Yiyi Yu, 2021 July
% Last Modified by GUIDE v2.5 27-Feb-2022 17:09:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegistrationWin_OpeningFcn, ...
                   'gui_OutputFcn',  @RegistrationWin_OutputFcn, ...
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

% --- Executes just before RegistrationWin is made visible.
function RegistrationWin_OpeningFcn(hObject, eventdata, handles, varargin)
% addpath('featurefun')
% addpath('generalfun')
% addpath('regfun')
scrsz = get(groot,'ScreenSize');
handles.scrsz = scrsz;
set( hObject, 'Units', 'pixels' );
position = get( hObject, 'Position' );
position(1) = 20;
position(2) = scrsz(4)-20;
set( hObject, 'Position', position );
handles.datatype = 1;
handles.Datalist = '';
if gpuDeviceCount>0
    handles.useGPU = 1;
    set(handles.ind_GPUNum, 'String', sprintf('%d GPU found', gpuDeviceCount))
    gpudev = gpuDevice(1);
    reset(gpudev)
    set(handles.useGPU_check,'Enable','on')
    set(handles.useGPU_check, 'Value',  handles.useGPU)
    fprintf('GPU Available memory')
    disp(gpudev.AvailableMemory)
    handles.gpudev.AvailableMemory = gpudev.AvailableMemory;
else
    handles.useGPU = 0; 
    set(handles.ind_GPUNum, 'String', 'No GPU found')
    set(handles.useGPU_check,'Enable','off')
end
handles.crossSessionReg = 0;
handles.lowSNR = 0;
handles.showresult = 0;
handles.savetoBin = 1; 
set(handles.MaxBinText, 'Enable', 'on')
[userview, systemview] = memory;
Mem_max = round(systemview.PhysicalMemory.Available/(10^9)*0.3);
set(handles.MaxBinText, 'String', num2str(Mem_max))
handles.binMaxsize_physical = Mem_max;
handles.binMaxsize = Mem_max;
handles.savetoTif = 0;
handles.savesubsampletif = 0;
handles.subsampleRate = 0;
set(handles.ind_subsample, 'Enable', 'off');
handles = registration_init(handles);
% Choose default command line output for RegistrationWin
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = RegistrationWin_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%-----------------------initialization--------------------------------
function ind_fileNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_subsample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function filelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function currentsavingpath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_GPUNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function MaxBinText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function filelistbox_Callback(hObject, eventdata, handles)
tmp = get(hObject, 'Value');

% --- Executes during object creation, after setting all properties.
function moviedata_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 1;
    set(handles.imageseq_check, 'Value', 0)
end
handles.filepath = pwd;
handles.currentImagelist = '';
guidata(hObject, handles);
function imageseq_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 2;
    set(handles.moviedata_check, 'Value', 0)
end
handles.filepath = pwd;
handles.currentImagelist = '';
guidata(hObject, handles);

function CrossSessionReg_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1 
    handles.crossSessionReg = 1;
    msgbox('Selected data will be registered to the same target image','icon','warn')
else
    handles.crossSessionReg = 0;    
end
guidata(hObject, handles);

function useGPU_check_Callback(hObject, eventdata, handles)
handles.useGPU = get(hObject, 'Value');
guidata(hObject, handles);

function lowSNR_check_Callback(hObject, eventdata, handles)
handles.lowSNR = get(hObject, 'Value');
guidata(hObject, handles);

function showresult_check_Callback(hObject, eventdata, handles)
handles.showresult = get(hObject, 'Value');
guidata(hObject, handles);

function savetoTif_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.savetoTif = 1;
    handles.savetoBin = 0; 
    set(handles.savetoBin_check, 'Value', 0) 
    set(handles.MaxBinText, 'Enable', 'on')
else
    handles.savetoTif = 0;    
end
guidata(hObject, handles);
function savetoBin_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.savetoBin = 1;
    handles.savetoTif = 0;    
    set(handles.savetoTif_check, 'Value', 0)    
    set(handles.MaxBinText, 'Enable', 'on')
    set(handles.MaxBinText, 'String', num2str(handles.binMaxsize_physical))
    handles.binMaxsize = handles.binMaxsize_physical;
else
    handles.savetoBin = 0;
    set(handles.MaxBinText, 'Enable', 'off')
end
guidata(hObject, handles);

function MaxBinText_Callback(hObject, eventdata, handles)
if str2double(get(hObject, 'String')) > handles.binMaxsize_physical
    set(handles.MaxBinText, 'String', num2str(handles.binMaxsize_physical))
end
if str2double(get(hObject, 'String')) <= 0
    set(handles.MaxBinText, 'String', num2str(handles.binMaxsize_physical))
end
handles.binMaxsize = str2double(get(hObject, 'String'));
guidata(hObject, handles);

function saveSubsample_check_Callback(hObject, eventdata, handles)
handles.savesubsampletif = get(hObject, 'Value');
if get(hObject, 'Value') == 0
    set(handles.ind_subsample, 'Enable', 'off');
else
    set(handles.ind_subsample, 'Enable', 'on'); 
    set(handles.ind_subsample, 'String', '1'); 
    handles.subsampleRate = 0.01;
end
guidata(hObject, handles);

function ind_subsample_Callback(hObject, eventdata, handles)
handles.subsampleRate = str2double(get(hObject, 'String'))/100;
guidata(hObject, handles);

% --------------------------Call back functions--------------------------
%%%% directory set up %%%%%%
function browsefilepath_Callback(hObject, eventdata, handles)
assignin('base', 'handles', handles)
if handles.savingflag == 1 
    msgbox('Batch registration in progress', 'Warning','warn');
else
    handles = registration_init(handles);
    [handles, ListOfImageNames] = listselectedfiles(handles);
    assignin('base', 'datalist', handles.Datalist')
%     handles.Datalist'
    if ~isempty(handles.Datalist)
        handles.savepath = [handles.filepath, '\processed'];
        set(handles.currentsavingpath, 'String',  handles.savepath)
        set(handles.filelistbox,'Enable','on')
        set(handles.filelistbox, 'string', ListOfImageNames);
        set(handles.savenametable, 'Enable', 'on')
        set(handles.ind_fileNum, 'String',  length(handles.Datalist))
        for k = 1:length(handles.Datalist)
            [imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
            savename = [regexprep(imagefilename,' ', '_'), '_Reg'];
            handles.savenamelist{k} = savename;
        end
        set(handles.savenametable, 'Data', handles.savenamelist')
    end
end
guidata(hObject, handles);

function savenametable_CellEditCallback(hObject, eventdata, handles)
newname = get(hObject, 'Data');
handles.savenamelist = newname(:,1)';
set(handles.savenametable, 'Data', handles.savenamelist')
guidata(hObject, handles);

function browsesavingpath_Callback(hObject, eventdata, handles)
savepath = uigetdir;
handles.savepath = savepath;
set(handles.currentsavingpath, 'String',  handles.savepath)
guidata(hObject, handles);

function deletefiles_Callback(hObject, eventdata, handles)
handles.Datalist = '';
handles = registration_init(handles);
guidata(hObject, handles);

function reg_MasterButton_Callback(hObject, eventdata, handles)
if handles.savesubsampletif == 1 && handles.subsampleRate==0
    handles.subsampleRate = 0.01;
    set(handles.ind_subsample, 'String', num2str(handles.subsampleRate*100))
    drawnow
end
if ~isempty(handles.Datalist)
    handles.savingflag = 1;
    if not(exist(handles.savepath, 'dir'))
        mkdir(handles.savepath)           
    end
    [handles, RegPara] = callregistration(handles);
     
    handles.savingflag = 0;
end
msgbox('Batch registration finished');
guidata(hObject, handles);

function FinishProg_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch registration inprogress')
else
    closereq();
end
