function varargout = TIP(varargin)
% TIP MATLAB code for TIP.fig
%      TIP, by itself, creates a new TIP or raises the existing
%      singleton*.
%
%      H = TIP returns the handle to a new TIP or the handle to
%      the existing singleton*.

%      TIP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIP.M with the given input arguments.
%
%      TIP('Property','Value',...) creates a new TIP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TIP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TIP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TIP

% Last Modified by GUIDE v2.5 30-Jun-2022 22:39:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TIP_OpeningFcn, ...
                   'gui_OutputFcn',  @TIP_OutputFcn, ...
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


% --- Executes just before TIP is made visible.
function TIP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TIP (see VARARGIN)

% Choose default command line output for TIP
screen_size = get(groot, "ScreenSize");
screenWidth = screen_size(3);
screenHeight = screen_size(4);
left = screenWidth*0.1;
bottom = screenHeight*0.1;
width = screenWidth*0.6;
height = screenHeight*0.6;
handles.Figure.position = [left bottom width height];

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TIP wait for user response (see UIRESUME)
% uiwait(handles.figure1);
handles.unselectedTabColor = get(handles.pushbutton3, 'BackgroundColor');
handles.selectedTabColor = handles.unselectedTabColor - 0.1;


% --- Outputs from this function are returned to the command line.
function varargout = TIP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clicke the button "Choose an image" and choose one ficture from the docu
% /images, and show the path in the text edit and preview of image in
% axes3(left)

axes(handles.axes2)
hold off;
cla reset;
[filename, pathname] = uigetfile({'*.bmp;*.png'}, 'choose an image');
% if not chosen then exit
if isequal(filename, 0) ||isequal(pathname, 0)
    return;
end
axes(handles.axes3);
fpath = strcat(pathname, filename);
set(handles.edit1, 'string', [pathname, filename])
imgsrc = imread(fpath);
% show in axes3
setappdata(handles.axes3, 'imgsrc', imgsrc);
imshow(imgsrc);

handles.i = 0;
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clicke the button "Select Foreground" 

handles.i = handles.i + 1;
i = handles.i;

road = get(handles.edit1, 'string');
axes(handles.axes2);
img = imread(road);
imageHandle = imshow(img, []);
hold on;
handles.img = img;

[J{i},rect{i},mask{i}] = foregroundsele(img);
if ~isequal(J{i}, 0)
    handles.J{i} = J{i};
    handles.rect{i} = rect{i};
    handles.mask{i} = mask{i};
    guidata(hObject, handles);
else
    imshow(img, [])
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the road from infomation carrier handles (in GUI use handles to 
% realize the information deliver between different functions)
road = get(handles.edit1, 'string');
axes(handles.axes2);
img = imread(road);
imageHandle = imshow(img, []);
hold on;
handles.img = img;
[height, width, ~] = size(img);

% initial plotting of rear wall and vanished point
x_ul = round(height / 10); y_ul = round(width / 10);
rear_rectan = images.roi.Rectangle(gca, 'Position', ...
    [x_ul, y_ul, width - 2*x_ul, height - 2*y_ul], ...
    'Color','b', 'FaceAlpha',0);
% handles.ROIrect = rear_rectan;

vx = round(width / 2);
vy = round(height / 2);
vanishedPoint = images.roi.Point(gca, 'Position', [vx, vy]);
vanishedPoint.Label = 'Vanished Point';

% irx, iry: x,y pixel position of the four point of rectange
irx = round([rear_rectan.Position(1), rear_rectan.Position(1) + rear_rectan.Position(3), ...
rear_rectan.Position(1) + rear_rectan.Position(3), ...
rear_rectan.Position(1), rear_rectan.Position(1)]);
iry = round([rear_rectan.Position(2), rear_rectan.Position(2) , ...
rear_rectan.Position(2) + rear_rectan.Position(4),...
rear_rectan.Position(2)+ rear_rectan.Position(4), rear_rectan.Position(2)]);

% search the intertaction with image rand
[ox,oy] = find_corner(vx,vy,irx(1),iry(1),0,0);
orx(1) = ox;  ory(1) = oy;
[ox,oy] = find_corner(vx,vy,irx(2),iry(2),width,0);
orx(2) = ox;  ory(2) = oy;
[ox,oy] = find_corner(vx,vy,irx(3),iry(3),width,height);
orx(3) = ox;  ory(3) = oy;
[ox,oy] = find_corner(vx,vy,irx(4),iry(4),0,height);
orx(4) = ox;  ory(4) = oy;
orx = round(orx);
ory = round(ory); 
% draw vanished point and lines, use a array the store the lines

hline1(1) = line(handles.axes2, [vx irx(1)], [vy iry(1)], ...
    'Color','b', 'tag', 'line');
hline1(2) = line(handles.axes2, [orx(1) irx(1)], [ory(1) iry(1)], ...
    'Color','b', 'tag', 'line');
hline1(3) = line(handles.axes2, [vx irx(2)], [vy iry(2)], ...
    'Color','b', 'tag', 'line');
hline1(4) = line(handles.axes2, [orx(2) irx(2)], [ory(2) iry(2)], ...
    'Color','b', 'tag', 'line');
hline1(5) = line(handles.axes2, [vx irx(3)], [vy iry(3)], ...
    'Color','b', 'tag', 'line');
hline1(6) = line(handles.axes2, [orx(3) irx(3)], [ory(3) iry(3)], ...
    'Color','b', 'tag', 'line');
hline1(7) = line(handles.axes2, [vx irx(4)], [vy iry(4)], ...
    'Color','b', 'tag', 'line');
hline1(8) = line(handles.axes2, [orx(4) irx(4)], [ory(4) iry(4)], ...
    'Color','b', 'tag', 'line');

handles.hline1 = hline1;
handles.orx = orx;
handles.ory = ory;
handles.iry = iry;
handles.irx = irx;
handles.vx = vx;
handles.vy = vy;

hold on;
guidata(hObject, handles);

% call the reaction function
addlistener(rear_rectan, 'MovingROI', ...
    @(src, evt) new_rear_rectan(src, evt, hObject,handles, ...
    vanishedPoint, img));

addlistener(vanishedPoint, 'MovingROI', ...
    @(src, evt) new_vanished_point(src, evt,  hObject, handles,...
    rear_rectan, img));


% move the rear wall, delete its old plot and generate a new one 
function new_rear_rectan(src, evt, hObject, handles, vanishedPoint, img )

irx = round([evt.CurrentPosition(1), evt.CurrentPosition(1) + evt.CurrentPosition(3), ...
evt.CurrentPosition(1) + evt.CurrentPosition(3), ...
evt.CurrentPosition(1), evt.CurrentPosition(1)]);
iry = round([evt.CurrentPosition(2), evt.CurrentPosition(2) , ...
evt.CurrentPosition(2) + evt.CurrentPosition(4),...
evt.CurrentPosition(2)+ evt.CurrentPosition(4), evt.CurrentPosition(2)]);
vx = vanishedPoint.Position(1);
vy = vanishedPoint.Position(2);
handles.vx = vx;
handles.vy = vy;
[height, width, ~] = size(img);
[ox,oy] = find_corner(vx,vy,irx(1),iry(1),0,0);
orx(1) = ox;  ory(1) = oy;
[ox,oy] = find_corner(vx,vy,irx(2),iry(2),width,0);
orx(2) = ox;  ory(2) = oy;
[ox,oy] = find_corner(vx,vy,irx(3),iry(3),width,height);
orx(3) = ox;  ory(3) = oy;
[ox,oy] = find_corner(vx,vy,irx(4),iry(4),0,height);
orx(4) = ox;  ory(4) = oy;
handles.orx = round(orx);
handles.ory = round(ory);
handles.irx = irx;
handles.iry = iry;

% delete the elements in image with tag "line" 
axesHandlesToChildObjects = findobj(handles.axes2, 'Type', 'line');
if ~isempty(axesHandlesToChildObjects)
    delete(axesHandlesToChildObjects);
end 
delete(handles.hline1)

% draw the line according to new irx, iry
handles.hline1(1) = line(handles.axes2, [vx handles.irx(1)], ...
    [vy handles.iry(1)], 'Color','b', 'tag', 'line');
handles.hline1(2) = line(handles.axes2, [handles.orx(1) handles.irx(1)],...
    [handles.ory(1) handles.iry(1)], 'Color','b', 'tag', 'line');
handles.hline1(3) = line(handles.axes2, [vx handles.irx(2)], ...
    [vy handles.iry(2)], 'Color','b','tag', 'line' );
handles.hline1(4) = line(handles.axes2, [handles.orx(2) handles.irx(2)],...
    [handles.ory(2) handles.iry(2)], 'Color','b', 'tag', 'line');
handles.hline1(5) = line(handles.axes2, [vx handles.irx(3)], ...
    [vy handles.iry(3)], 'Color','b', 'tag', 'line');
handles.hline1(6) = line(handles.axes2, [handles.orx(3) handles.irx(3)],...
    [handles.ory(3) handles.iry(3)], 'Color','b','tag', 'line' );
handles.hline1(7) = line(handles.axes2, [vx handles.irx(4)], ...
    [vy handles.iry(4)], 'Color','b', 'tag', 'line');
handles.hline1(8) = line(handles.axes2, [handles.orx(4) handles.irx(4)],...
    [handles.ory(4) handles.iry(4)], 'Color','b', 'tag', 'line');
guidata(hObject, handles)

function new_vanished_point(src, evt, hObject, handles, rear_rectan, img)
% get the current vanished point's position
vx = evt.CurrentPosition(1);
vy = evt.CurrentPosition(2);

handles.vx = vx;
handles.vy = vy;
[height, width, ~] = size(img);

irx = round([rear_rectan.Position(1), rear_rectan.Position(1) + rear_rectan.Position(3), ...
rear_rectan.Position(1) + rear_rectan.Position(3), ...
rear_rectan.Position(1), rear_rectan.Position(1)]);
iry = round([rear_rectan.Position(2), rear_rectan.Position(2) , ...
rear_rectan.Position(2) + rear_rectan.Position(4),...
rear_rectan.Position(2)+ rear_rectan.Position(4), rear_rectan.Position(2)]);
[ox,oy] = find_corner(vx,vy,irx(1),iry(1),0,0);
orx(1) = ox;  ory(1) = oy;
[ox,oy] = find_corner(vx,vy,irx(2),iry(2),width,0);
orx(2) = ox;  ory(2) = oy;
[ox,oy] = find_corner(vx,vy,irx(3),iry(3),width,height);
orx(3) = ox;  ory(3) = oy;
[ox,oy] = find_corner(vx,vy,irx(4),iry(4),0,height);
orx(4) = ox;  ory(4) = oy;
handles.orx = round(orx);
handles.ory = round(ory);
handles.irx = irx;
handles.iry = iry;

axesHandlesToChildObjects = findobj(handles.axes2, 'Type', 'line');
if ~isempty(axesHandlesToChildObjects)
    delete(axesHandlesToChildObjects);
end 
delete(handles.hline1)

handles.hline1(1) = line(handles.axes2, [vx handles.irx(1)], ...
    [vy handles.iry(1)], 'Color','b', 'tag', 'line');
handles.hline1(2) = line(handles.axes2, [handles.orx(1) handles.irx(1)],...
    [handles.ory(1) handles.iry(1)], 'Color','b', 'tag', 'line');
handles.hline1(3) = line(handles.axes2, [vx handles.irx(2)], ...
    [vy handles.iry(2)], 'Color','b','tag', 'line' );
handles.hline1(4) = line(handles.axes2, [handles.orx(2) handles.irx(2)],...
    [handles.ory(2) handles.iry(2)], 'Color','b', 'tag', 'line');
handles.hline1(5) = line(handles.axes2, [vx handles.irx(3)], ...
    [vy handles.iry(3)], 'Color','b', 'tag', 'line');
handles.hline1(6) = line(handles.axes2, [handles.orx(3) handles.irx(3)],...
    [handles.ory(3) handles.iry(3)], 'Color','b','tag', 'line' );
handles.hline1(7) = line(handles.axes2, [vx handles.irx(4)], ...
    [vy handles.iry(4)], 'Color','b', 'tag', 'line');
handles.hline1(8) = line(handles.axes2, [handles.orx(4) handles.irx(4)],...
    [handles.ory(4) handles.iry(4)], 'Color','b', 'tag', 'line');
guidata(hObject, handles)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% J is foreground object
% rect is user-selected rectangle
% img filled is the repaired img after foreground interpolation
% click the start tour button and begin to tour

% check if there is foreground object, if so change the image
if ~isequal(handles.i, 0)
    for i=1:handles.i
        [img_filled,J{i},rect{i},~] = fill_the_hole(handles.img, handles.J{i}, handles.rect{i}, handles.mask{i});
        handles.img = img_filled;
    end
else
    J = 0;
    rect = [0,0,0,0];
end

rear_wall_x = handles.irx;
rear_wall_y = handles.iry;
vanished_point_x = handles.vx;
vanished_point_y = handles.vy;
rand_intersection_x = handles.orx;
rand_intersection_y = handles.ory;

% get 5 rectangles based on user-chosen shapes
[bim, vx, vy, ceilx, ceily, floorx, floory, leftx, lefty, rightx, ...
    righty, backx, backy, lmargin, tmargin] = get5rects(handles.img, vanished_point_x, ...
    vanished_point_y, rear_wall_x, rear_wall_y, ...
    rand_intersection_x, rand_intersection_y);

% start tours!
walk_through_3d(bim, vx, vy, ceilx, ceily, floorx, floory, leftx, lefty, rightx, ...
    righty, backx, backy, lmargin, tmargin, J, rect, handles.i);
