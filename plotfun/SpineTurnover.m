function varargout = SpineTurnover(varargin)
% SPINETURNOVER MATLAB code for SpineTurnover.fig
%      SPINETURNOVER, by itself, creates a new SPINETURNOVER or raises the existing
%      singleton*.
%
%      H = SPINETURNOVER returns the handle to a new SPINETURNOVER or the handle to
%      the existing singleton*.
%
%      SPINETURNOVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPINETURNOVER.M with the given input arguments.
%
%      SPINETURNOVER('Property','Value',...) creates a new SPINETURNOVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpineTurnover_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpineTurnover_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpineTurnover

% Last Modified by GUIDE v2.5 13-Sep-2023 17:03:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpineTurnover_OpeningFcn, ...
                   'gui_OutputFcn',  @SpineTurnover_OutputFcn, ...
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


% --- Executes just before SpineTurnover is made visible.
function SpineTurnover_OpeningFcn(hObject, eventdata, handles, varargin)
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
handles.mainfigure = hObject;
handles.batchdata = 0;
handles.datafilename = '';
handles.datanames = '';
handles.datafilepath = '';
[~, Mver] = version;    
handles.Mver = Mver;
handles = inputmap_init(handles);
% Choose default command line output for SpineTurnover
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SpineTurnover_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on button press in LoadData.
function LoadData_Callback(hObject, eventdata, handles)
    set(handles.datalist_tbl, 'Data', {})
    [datafilename, datafilepath, indx] = uigetfile({'*.mat';'*.*'},...
        'Visualize one/multiple files', 'MultiSelect', 'on');
if indx > 0 
    f_wait = waitbar(0.5,'Data loading');

    % load data
    if iscell(datafilename)
        handles.datafilename = datafilename;
        handles.batchdata = 1;
    else
        handles.batchdata = 0;
        handles.datafilename = {datafilename};
    end

    handles.datanames = "";
    for k = 1:length(handles.datafilename)
        filenamePieces = split(handles.datafilename{k}, '.');
        A = filenamePieces{1};
        A = A(~isspace(A));
        newStr = erase(A, '-');
        if length(newStr)>60
            newStr = newStr(1:60);
        end
        handles.datanames(k) = string(newStr);
    end

    handles.datafilepath = datafilepath;
    handles = inputmap_init(handles);
    assignin('base', 'handles', handles)
%     handles = loadDataforPlots(handles); 
    set(handles.datalist_tbl, 'Data', reshape(handles.datafilename,[],1))
%     assignin('base', 'handles', handles)
    
    handles = input_refresh(handles, 1);
    SelectfeatureForVisual(handles)
    figure(1), title(handles.datafilename{1})

    close(f_wait)
    delete(f_wait)
end
guidata(hObject, handles);

% --- Executes on button press in spinetuneover.
function spinetuneover_Callback(hObject, eventdata, handles)
if length(handles.datafilename)>=2
    [spine_evolve, num_turnover, Dendrite_CrossSess,...
        filelist, targetdata, TranM, handles]...
        = spineEvolveAna(handles);
    assignin('base', 'handles', handles);
    crossSessAlign_thresh = handles.thresh;
    crossSessAlign_target = handles.datafilename(handles.targetID);
    save(fullfile(handles.datafilepath, ...
        sprintf('SpineEvolveAnalysis_%s.mat', targetdata)),...
        'spine_evolve', 'num_turnover', 'filelist', 'TranM',...
        'crossSessAlign_thresh', 'crossSessAlign_target')
    if ~isempty(Dendrite_CrossSess)
        save(fullfile(handles.datafilepath,...
            sprintf('SpineEvolveAnalysis_%s.mat', targetdata)),...
            'Dendrite_CrossSess', '-append')

        calllochist(Dendrite_CrossSess, spine_evolve, handles);
    end
else
    msgbox('Load multiple dataset for spine evolution analysis')
end

function datalist_tbl_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Data', {})
assignin('base', 'handles', handles);
guidata(hObject, handles);

function datalist_tbl_CellSelectionCallback(hObject, eventdata, handles)
dataID = eventdata.Indices(1)
handles = input_refresh(handles, dataID);
mainfig_pos = get(handles.mainfigure, 'Position');
[trace_stamp, trace_num, ttlabel] = pooltrace(handles);
% [varsel] = Selfeature(handles, ttlabel, mainfig_pos);        
% handles = get_spineROImask(handles);
SelectfeatureForVisual(handles)
figure(1), title(handles.datafilename{dataID})

guidata(hObject, handles);


