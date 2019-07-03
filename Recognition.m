function varargout = Recognition(varargin)
% RECOGNITION MATLAB code for Recognition.fig
%      RECOGNITION, by itself, creates a new RECOGNITION or raises the existing
%      singleton*.
%
%      H = RECOGNITION returns the handle to a new RECOGNITION or the handle to
%      the existing singleton*.
%
%      RECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECOGNITION.M with the given input arguments.
%
%      RECOGNITION('Property','Value',...) creates a new RECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Recognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Recognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Recognition

% Last Modified by GUIDE v2.5 25-May-2019 20:40:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Recognition_OpeningFcn, ...
                   'gui_OutputFcn',  @Recognition_OutputFcn, ...
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


% --- Executes just before Recognition is made visible.
function Recognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Recognition (see VARARGIN)

% Choose default command line output for Recognition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Recognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Recognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)  %打开文件显示时域、频谱图按钮
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x
global Fs
global music
[filename,filepath] = uigetfile({'*'},'选择音频文件');
if filename==0
    return
else
    music=[filepath,filename];
    [x,Fs] = audioread(music);%读取音频数据
    samplesize=size(x);
    if samplesize(2)>1
        x=x(:,1);
    end
end
x = x(:,1);
x = x';
xx=x/max(abs(x));
N = length(x);%求取抽样点数
t = (0:N-1)/Fs;%显示实际时间
y = fft(x);%对信号进行傅里叶变换
f = Fs/N*(0:round(N/2)-1);%显示实际频点的一半
axes(handles.axes1)
plot(t,xx);%绘制时域波形
axis([0 max(t) -1.1 1.1]);
xlabel('Time / (s)');ylabel('Amplitude');
title('信号的波形');
grid;
axes(handles.axes2)
plot(f,abs(y(1:round(N/2))));
xlabel('Frequency / (Hz)');ylabel('Amplitude');
set(gca, 'XLim',[20 20000]); 
title('信号的频谱');
grid;
set(handles.text3,'String','');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)  %识别按钮
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text3,'String','识别中...');
global music
[sound,rfs] = audioread(music);
[v_num]=EndDetection(sound);
if (v_num<2)    %有一个语音段就为音乐，两个以上则为人声
    set(handles.text3,'String','音乐');
else
    set(handles.text3,'String','人声');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)  %播放按钮
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x;
global Fs;
sound(x,Fs);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)  %停止按钮
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear sound


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)  %录音10s
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text3,'String','录音中...');
R = audiorecorder(16000, 16 ,1) ;
recordblocking(R, 10);
myspeech = getaudiodata(R);
audiowrite('record.wav',myspeech,16000)
set(handles.text3,'String','录音完成');
