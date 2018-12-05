function varargout = motorControlsV4(varargin)
%MOTORCONTROLSV4 M-file for motorControlsV4.fig

% Edit the above text to modify the response to help motorControlsV4

% Last Modified by GUIDE v2.5 30-Aug-2012 11:11:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motorControlsV4_OpeningFcn, ...
                   'gui_OutputFcn',  @motorControlsV4_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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

function motorControlsV4_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = motorControlsV4_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Main Subpanel - Position controls
function pbReadPos_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
handles.hController.changedMotorPosition;

function etPosX_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,1);

function etPosY_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,2);

function etPosZ_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,3);

function etPosZZ_Callback(hObject, eventdata, handles)
handles.hController.changeMotorPosition(hObject,4);

function pbZeroXYZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXYZ');

function pbZeroZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroZ');

function pbZeroXY_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXY');

function pbAltZeroXY_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroXY');

function pbAltZeroZ_Callback(hObject, eventdata, handles)
handles.hController.motorZeroAction('motorZeroZ');

function cbSecZ_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

%% Main Subpanel - Arrow controls

function pbStepXInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','x');

function pbStepYInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','y');

function pbStepZInc_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('inc','z');

function pbStepXDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','x');

function pbStepYDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','y');

function pbStepZDec_Callback(hObject, eventdata, handles)
handles.hController.motorStepPosition('dec','z');

function etStepSizeX_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(1) = str2double(get(hObject,'String'));

function etStepSizeY_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(2) = str2double(get(hObject,'String'));

function etStepSizeZ_Callback(hObject, eventdata, handles)
handles.hController.motorStepSize(3) = str2double(get(hObject,'String'));

%% User-defined positions subpanel
function etPositionNumber_Callback(hObject, eventdata, handles)
posnIdx = str2double(get(hObject,'String'));
try
    handles.hController.motorUserPositionIndex = posnIdx;
catch %#ok<*CTCH>
    set(hObject,'String',num2str(handles.hController.motorUserPositionIndex));
end

function pbAddCurrent_Callback(hObject, eventdata, handles)
handles.hController.motorDefineUserPositionAndIncrement();

function tbTogglePosn_Callback(hObject, eventdata, handles)
hPosnGUI = handles.hController.hGUIs.posnControlsV4;
if get(hObject,'Value')
    set(hPosnGUI,'Visible','on');
else
    set(hPosnGUI,'Visible','off');
end

%% Stack subpanel
function pbSetStart_Callback(hObject, eventdata, handles)
handles.hController.stackSetStackStart();

function pbSetEnd_Callback(hObject, eventdata, handles)
handles.hController.stackSetStackEnd();

function pbClearStartEnd_Callback(hObject, eventdata, handles)
handles.hController.stackClearStartEnd();

function pbClearEnd_Callback(hObject, eventdata, handles)
handles.hController.stackClearEnd();

function cbUseStartPower_Callback(hObject,eventdata,handles)
tfUseStartPower = get(hObject,'Value');
if ~tfUseStartPower
    % Using overrideLz without stackUseStartPower is very rare. The SI4
    % API permits this with a warning, but here in UI we help the user out.
    handles.hController.hModel.stackUserOverrideLz = false;
end
handles.hController.hModel.stackUseStartPower = tfUseStartPower;

function cbOverrideLz_Callback(hObject, eventdata, handles)
tfOverrideLz = get(hObject,'Value');
if tfOverrideLz
    % Using overrideLz without stackUseStartPower is very rare. The SI4
    % API permits this with a warning, but here in the UI we help the user out.
    handles.hController.hModel.stackUseStartPower = true;
end
handles.hController.hModel.stackUserOverrideLz = tfOverrideLz;

function etNumberOfZSlices_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function etZStepPerSlice_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbReturnHome_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

function cbCenteredStack_Callback(hObject, eventdata, handles)
handles.hController.updateModel(hObject,eventdata,handles);

%% The yellow button
function pbRecover_Callback(hObject,eventdata,handles)
handles.hController.motorRecover();

%% CREATE FCNS 

% --- Executes during object creation, after setting all properties.
function etPosnID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosnID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etStepSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etStepSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etStepSizeZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etNumberOfZSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNumberOfZSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etZStepPerSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etZStepPerSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etStepSizeZZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStepSizeZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etPosY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etPosZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etPosX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etPosR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etStackEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStackEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etEndPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etEndPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etStackStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStackStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function etStartPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etStartPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etPosZZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPosZZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

%% CREATE FCNS


% --- Executes during object creation, after setting all properties.
function pbStepXDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepXDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,180,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepXInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepXInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,[],[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepYDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepYDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,90,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepYInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepYInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,270,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepZDec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepZDec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,90,[0 0 1]));


% --- Executes during object creation, after setting all properties.
function pbStepZInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbStepZInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'CData',most.gui.loadIcon('arrow.bmp',16,270,[0 0 1]));


% --- Executes on button press in pbOverrideLz.
function pbOverrideLz_Callback(hObject, eventdata, handles)
% hObject    handle to pbOverrideLz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.hModel.beamLengthConstants = handles.hModel.beamComputeOverrideLzs();
