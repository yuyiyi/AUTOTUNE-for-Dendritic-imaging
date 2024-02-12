function varargout = InputMapping(varargin)
% Edit the above text to modify the response to help InputMapping
% Last Modified by GUIDE v2.5 13-Sep-2023 17:00:21
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InputMapping_OpeningFcn, ...
                   'gui_OutputFcn',  @InputMapping_OutputFcn, ...
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

% --- Executes just before InputMapping is made visible.
function InputMapping_OpeningFcn(hObject, eventdata, handles, varargin)
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
handles.datafilepath = '';
set(handles.if_GUI, 'Value', 1)
set(handles.if_cmd, 'Value', 0)
% set(handles.ifcircular, 'Value', 0)
handles.circularfit = 0;
% handles.ifmultiplypi = 0;
handles.openGUI = 1;
cla(handles.DisplayResult, 'reset')
set(handles.useBAPremove, 'Value', 0)
set(handles.useRawtrace, 'Value', 1)
set(handles.useFilttrace, 'Value', 0)
[~, Mver] = version;    
handles.Mver = Mver;
handles = inputmap_init(handles);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = InputMapping_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%-------------------------set up and initialization -----------------------
% --- Executes on button press in if_GUI.
function if_GUI_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.openGUI = 1;
    set(handles.if_cmd, 'Value', 0)
else
    handles.openGUI = 0;
end
guidata(hObject, handles);

function if_cmd_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.openGUI = 0;
    set(handles.if_GUI, 'Value', 0)
else
    handles.openGUI = 1;
end
guidata(hObject, handles);

% editable frame stamps
function uit_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Data', {})
guidata(hObject, handles);

function uit_CellEditCallback(hObject, eventdata, handles)
%     newstamp = get(handles.uit, 'Data');
%     stampinfo = newstamp(:,2)';
%     for k = 1:length(handles.datafilename)
%         save(fullfile(handles.datafilepath, handles.datafilename{k}), 'stampinfo', '-append')
%     end
%     handles.stampinfo = stampinfo;
% guidata(hObject, handles);

function useRawtrace_Callback(hObject, eventdata, handles)
handles.plotRawdff = get(hObject, 'Value');
if get(hObject, 'Value') == 1
    set(handles.useFilttrace, 'Value', 0)
    set(handles.useBAPremove, 'Value', 0)
    handles.plotFiltdff = 0;
    handles.plotBAPdff = 0 ;
end
guidata(hObject, handles);

% --- Executes on button press in useFilttrace.
function useFilttrace_Callback(hObject, eventdata, handles)
if isempty(handles.shaft_filt) && isempty(handles.spine_filt) &&...
        isempty(handles.dend_filt) && isempty(handles.cfeature_filt) 
    msgbox('No filtered trace')
    set(handles.useFilttrace, 'Value', 0)
end
handles.plotFiltdff = get(hObject, 'Value'); 
if get(hObject, 'Value') == 1
    set(handles.useRawtrace, 'Value', 0)
    set(handles.useBAPremove, 'Value', 0)
    handles.plotRawdff = 0;
    handles.plotBAPdff = 0;
end
guidata(hObject, handles);

function useBAPremove_Callback(hObject, eventdata, handles)
if isempty(handles.spine_BAPremoval_coef) && isempty(handles.shaft_BAPremoval_coef)
    msgbox('No BAP removed trace')
    set(handles.useBAPremove, 'Value', 0)
end
handles.plotBAPdff = get(hObject, 'Value');
if get(hObject, 'Value') == 1
    set(handles.useRawtrace, 'Value', 0)
    set(handles.useFilttrace, 'Value', 0)
    handles.plotRawdff = 0;
    handles.plotFiltdff = 0;
end
guidata(hObject, handles);

% --- Executes when entered data in editable cell(s) in datalist_tbl.
% --- Executes during object creation, after setting all properties.
function datalist_tbl_CreateFcn(hObject, eventdata, handles)
set(hObject, 'Data', {})
guidata(hObject, handles);

function datalist_tbl_CellSelectionCallback(hObject, eventdata, handles)
dataID = eventdata.Indices(1);
handles = loadtrace(handles, dataID);
[trace_stamp, trace_num, ttlabel] = pooltrace(handles);
% [varsel] = Selfeature(handles, ttlabel, mainfig_pos);
SelectfeatureForVisual(handles)
% handles = inputmap_refreshplot(handles, dataID);
guidata(hObject, handles);

% -----------------------------Load Data -------------------------------
% --- Executes on button press in loadframestamps.
function loadframestamps_Callback(hObject, eventdata, handles)
if ~isempty(handles.datafilename)
    [framestampname, framestamppath, indx] = uigetfile({'*.mat';'*.*'},...
        'Load frame stamp from another directory',  'MultiSelect', 'on');
    if indx > 0
        if iscell(framestampname)
            handles = loadframestamp(framestampname, framestamppath, handles);
        else
            handles = loadframestamp({framestampname}, framestamppath, handles);
        end
        set(handles.datalist_tbl, 'Data', ...
            table2cell(table(reshape(handles.datafilename,[],1),...
            reshape(handles.framestampname,[],1))))
        framestamp = handles.framestamp{1};
        stampinfo = handles.stampinfo{1};
        handles = showframestamptbl(framestamp, stampinfo, handles);
    end
end
guidata(hObject, handles);

% --- Executes on button press in loaddata.
function LoadData_Callback(hObject, eventdata, handles)
    set(handles.datalist_tbl, 'Data', {})
    [datafilename, datafilepath, indx] = uigetfile({'*.mat';'*.*'},...
        'Visualize one/multiple files', 'MultiSelect', 'on');
if indx > 0 
    if iscell(datafilename)
        handles.datafilename = datafilename;
        handles.batchdata = 1;
    else
        handles.batchdata = 0;
        handles.datafilename = {datafilename};
    end
    handles.datafilepath = datafilepath;
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

    set(handles.useBAPremove, 'Value', 0)
    set(handles.useRawtrace, 'Value', 1)
    set(handles.useFilttrace, 'Value', 0)
    set(handles.uit, 'Data', {})
    handles = inputmap_init(handles);    
    handles = loadDataforPlots(handles); 
    set(handles.datalist_tbl, 'Data', ...
        table2cell(table(reshape(handles.datafilename,[],1),...
        reshape(handles.framestampname,[],1))))    
    handles = inputmap_refreshplot(handles, 1);
end
guidata(hObject, handles);

function BAP_subtract_Callback(hObject, eventdata, handles)
clc
if length(handles.datafilename)>=1 && (handles.plotRawdff==1 || handles.plotFiltdff==1)
    for k = 1:length(handles.datafilename)
        handles = loadtrace(handles, k);
        if ~isempty(handles.dend_trace) && (~isempty(handles.spine_trace)...
                || ~isempty(handles.dend_shaft))
            if handles.plotRawdff == 1
                handles = callBAPsubtract_master(handles, k);
            elseif handles.plotFiltdff == 1
                handles = callBAPsubtract_filt(handles, k);
            end        
        end
    end
else
    if handles.openGUI==0
        fprintf('Miss spine signal or dendritic signal \n')    
    else
        msgbox('Miss spine signal or dendritic signal')
    end
end
guidata(hObject, handles);

function GaussFilter_Callback(hObject, eventdata, handles)
if length(handles.datafilename)>=1 
    [v, smoothwin] = prep_filt(handles);
    if v==2        
        [fps, w1, w2] = call_gaussfilt(handles);
        handles.MetaInfor.tracefiltertype = 'Gaussfilter on raw trace';        
        handles.MetaInfor.tracefilterparameter = [fps, w1, w2];
        if ~isempty(fps)
            for k = 1:length(handles.datafilename)
                handles = callgaussfilt_master(handles, k, fps, w1, w2);
            end
        else
            msgbox('no fps value')
        end
    elseif v==1
        handles.MetaInfor.tracefiltertype = 'Moving average on raw trace';        
        handles.MetaInfor.tracefilterparameter = smoothwin;
        for k = 1:length(handles.datafilename)
            handles = callsmoothfilt_master(handles, k, smoothwin);
        end
    end
end
guidata(hObject, handles);

% --- Executes on button press in plotsometrace.
function plotsometrace_Callback(hObject, eventdata, handles)
    assignin('base', 'handles', handles)

    call_plotsometrace(handles)

% --- Executes on button press in spinetuneover.
function spinetuneover_Callback(hObject, eventdata, handles)
if length(handles.datafilename)>=2
    [spine_evolve, num_turnover, Dendrite_CrossSess,...
        filelist, targetdata, TranM, handles]...
        = spineEvolveAna(handles);
    crossSessAlign_thresh = handles.thresh;
    crossSessAlign_target = handles.datafilename(handles.targetID);
    save(fullfile(handles.datafilepath, ...
        sprintf('SpineEvolveAnalysis_%s.mat', targetdata)),...
        'spine_evolve', 'num_turnover', 'filelist', 'TranM',...
        'crossSessAlign_thresh', 'crossSessAlign_target')
    if ~isempty(Dendrite_CrossSess)
        save(fullfile(handles.datafilepath, ...
            sprintf('SpineEvolveAnalysis_%s.mat', targetdata)),...
            'Dendrite_CrossSess', '-append')
    
        calllochist(Dendrite_CrossSess, spine_evolve, handles);
    end
else
    msgbox('Load multiple dataset for spine evolution analysis')
end

%%%% response analysis 
function StampResp_Callback(hObject, eventdata, handles)
if ~isempty(handles.framestamp) && ~isempty(handles.stampinfo)
    if size(handles.framestamp{1}, 2) == 1 && istable(handles.stampinfo{1})
        call_stampresp_v2(handles)
    else
        traceplot22(handles)
        msgbox('No frame stamp information found')
    end
else
    traceplot22(handles)
    msgbox('No frame stamp information found')
end

% --- Executes on button press in behavResp.
function behavResp_Callback(hObject, eventdata, handles)
if ~isempty(handles.framestamp) && ~isempty(handles.stampinfo)
    if istable(handles.stampinfo{1})
        call_behresp(handles)
    else
        traceplot22(handles)
        msgbox('No frame stamp information found')        
    end
else
    traceplot22(handles)
    msgbox('No frame stamp information found')
end

% --- Executes on button press in plotfeature.
function plotfeature_Callback(hObject, eventdata, handles)
mainfig_pos = get(handles.mainfigure, 'Position');
[trace_stamp, trace_num, ttlabel] = pooltrace(handles);
% [varsel] = Selfeature(handles, ttlabel, mainfig_pos);
SelectfeatureForVisual(handles)
