function varargout = AUTOTUNE(varargin)
% AUTOTUNE MATLAB code for AUTOTUNE.fig
%      AUTOTUNE, by itself, creates a new AUTOTUNE or raises the existing
%      singleton*.
%
%      H = AUTOTUNE returns the handle to a new AUTOTUNE or the handle to
%      the existing singleton*.
%
%      AUTOTUNE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOTUNE.M with the given input arguments.
%
%      AUTOTUNE('Property','Value',...) creates a new AUTOTUNE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AUTOTUNE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AUTOTUNE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AUTOTUNE

% Last Modified by GUIDE v2.5 12-Sep-2023 16:31:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AUTOTUNE_OpeningFcn, ...
                   'gui_OutputFcn',  @AUTOTUNE_OutputFcn, ...
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


% --- Executes just before AUTOTUNE is made visible.
function AUTOTUNE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AUTOTUNE (see VARARGIN)
mainpath = mfilename('fullpath');
[ filepath , name , ext ] = fileparts( mainpath );
addpath(fullfile(filepath,'featurefun'))
addpath(fullfile(filepath,'generalfun'))
addpath(fullfile(filepath,'featurefun'))
addpath(fullfile(filepath,'util'))
addpath(fullfile(filepath,'plotfun'))
% Choose default command line output for AUTOTUNE
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AUTOTUNE wait for user response (see UIRESUME)
% uiwait(handles.AUTOTUNE);

% --- Outputs from this function are returned to the command line.
function varargout = AUTOTUNE_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Registration.
function Registration_Callback(hObject, eventdata, handles)
RegistrationWin

% --- Executes on button press in DendriticProc_SingleMovie.
function DendriticProc_SingleMovie_Callback(hObject, eventdata, handles)
SpineTrace_IndividualMovie

% --- Executes on button press in SpineStruct.
function SpineStruct_Callback(hObject, eventdata, handles)
SpineTurnover

% --- Executes on button press in GeneratePlots.
function GeneratePlots_Callback(hObject, eventdata, handles)
InputMapping



% --- Executes on button press in exitprog.
function exitprog_Callback(hObject, eventdata, handles)
if ~isempty(findall(0,'Tag','InputMappingGUI'))
    close(InputMapping)
end
if ~isempty(findall(0,'Tag','RegistrationWin'))
    close(RegistrationWin)
end
if ~isempty(findall(0,'Tag','FeatureDetection'))
    close(SpineTrace_IndividualMovie)
end
if ~isempty(findall(0,'Tag','SpineStruct'))
    close(SpineTurnover)
end
closereq();

