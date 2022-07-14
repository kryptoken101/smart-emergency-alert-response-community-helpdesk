function GeInterface(obj)

GeFig = figure;
obj.LAIdx = 1;

set(GeFig,...
     'MenuBar','none',...
     'Name','GoogleEarth',...
     'NumberTitle','off',...     
     'Position', [0 50 810 710]);

uicontrol(...
    'Parent',GeFig,...            
    'BackgroundColor',[0.2 0.2 0.2],...
    'Callback',{@incrLAIdx,obj},...
    'CData',imread('NextCam.png'),...
    'Units','normalized',...
    'Position',[407.5/810 655/710 50/810 50/710],...
    'String',blanks(0),...    
    'TooltipString','Get the view from the next camera',...
    'Style','pushbutton');

uicontrol(...
    'Parent',GeFig,...            
    'BackgroundColor',[0.2 0.2 0.2],...
    'Callback',{@decrLAIdx,obj},...
    'CData',imread('PrevCam.png'),...
    'Units','normalized',...
    'Position',[352.5/810 655/710 50/810 50/710],...
    'String',blanks(0),...    
    'TooltipString','Get the view from the previous camera',...
    'Style','pushbutton');

uicontrol(...
    'Parent',GeFig,...
    'BackgroundColor',[0.2 0.2 0.2],...
    'Style', 'slider',...
    'Units','normalized',...
    'Min',1,'Max',50,'Value',41,...
    'Position', [790/810 0/710 20/810 645/710],...
    'String',blanks(0),...
    'TooltipString','Zoom in and out',...
    'Callback', {@zoomCamera,obj}); 


uicontrol(...
    'Parent',GeFig,...            
    'BackgroundColor',[0.2 0.2 0.2],...
    'Callback',{@CameraView,obj},...
    'CData',imread('Camera.png'),...
    'Units','normalized',...
    'Position',[5/810 655/710 50/810 50/710],...
    'String',blanks(0),...
    'TooltipString','Switch to Camera View',...
    'Style','pushbutton');

uicontrol(...
    'Parent',GeFig,...            
    'BackgroundColor',[0.2 0.2 0.2],...
    'Callback',{@SpanView,obj},...
    'CData',imread('Hand.png'),...
    'Units','normalized',...
    'Position',[63/810 655/710 50/810 50/710],...
    'String',blanks(0),...
    'TooltipString','Switch to Camera View',...
    'Style','togglebutton');

uicontrol(...
    'Parent',GeFig,...            
    'BackgroundColor',[0.2 0.2 0.2],...
    'Callback',{@resetView,obj},...
    'CData',imread('Refresh.png'),...
    'Units','normalized',...
    'Position',[121/810 655/710 50/810 50/710],...
    'String',blanks(0),...
    'TooltipString','Reset View',...
    'Style','pushbutton');


wrapDial1 = dial('refVal',5,...
    'refOrientation',90*pi/180,...
    'valRangePerRotation',360, ...
    'Min',0,...
    'Max',359,...
    'doWrap',1,...
    'Value',0,...
    'Position',[755/810 655/710 50/810 50/710],...
    'VerticalAlignment','bottom',...
    'Tag','wrapDial1',...
    'CallBack',@wrap_cb1,... 
    'tickVals', [0 90 180 270],...
    'tickStrs',{''  ''  ''  ''});

% Static text object superimposed on dial panel. Will look better if text
% background is same colour as panel.
faceColour = get(wrapDial1.panelHndl,'facecolor');
set(findobj('Tag','wrapText'),'BackgroundColor',faceColour,'ForegroundColor','r');
set(findobj('Tag','wrapText'),'string','0');

% Shrink the size of the dial face to show more of the tick lines.
set(wrapDial1,'dialRadius',0.55);

% Customise dial pointer using handle graphics (want arrow instead of
% straight line).
x = [0 .55 .4 NaN .55 .4];
y = [0 0 .14 NaN 0 -.14];
set(wrapDial1.linePointerHndl,'xdata',x,'ydata',y);
set(wrapDial1.linePointerHndl,'color','r');

% Move the tick labels a little further away from the dial face.
set(wrapDial1,'tickLabelRadius',0.69);

wrapDial2 = dial('refVal',5,...
    'refOrientation',90*pi/180,...
    'valRangePerRotation',90, ...
    'Min',0,...
    'Max',90,...
    'doWrap',1,...
    'Value',0,...
    'Position',[700/810 655/710 50/810 50/710],...
    'VerticalAlignment','bottom',...
    'Tag','wrapDial2',...
    'CallBack',@wrap_cb2,... 
    'tickVals', [0 30 60],...
    'tickStrs',{''  ''  ''});

% Static text object superimposed on dial panel. Will look better if text
% background is same colour as panel.
faceColour = get(wrapDial2.panelHndl,'facecolor');
set(findobj('Tag','wrapText'),'BackgroundColor',faceColour,'ForegroundColor','r');
set(findobj('Tag','wrapText'),'string','0');

% Shrink the size of the dial face to show more of the tick lines.
set(wrapDial2,'dialRadius',0.55);

% Customise dial pointer using handle graphics (want arrow instead of
% straight line).
x = [0 .55 .4 NaN .55 .4];
y = [0 0 .14 NaN 0 -.14];
set(wrapDial2.linePointerHndl,'xdata',x,'ydata',y);
set(wrapDial2.linePointerHndl,'color','r');

% Move the tick labels a little further away from the dial face.
set(wrapDial2,'tickLabelRadius',0.69);


end

function decrLAIdx(~,~,obj)
    if (obj.LAIdx == 1)
        obj.LAIdx = obj.Views; 
    else
        obj.LAIdx = obj.LAIdx -1;
    end
    obj.CamRoll = 5;
    obj.CamTilt = 5;
    evalin('base','Ch = 1;');
    obj.updateGe();
end

function CameraView(~,~,obj)
     obj.Cr = ~obj.Cr;
     obj.LAIdx = 1;
end

function incrLAIdx(~,~,obj)
    if (obj.LAIdx == obj.Views)
        obj.LAIdx = 1; 
    else
        obj.LAIdx = obj.LAIdx +1;        
    end
    obj.CamRoll = 5;
    obj.CamTilt = 5; 
    evalin('base','Ch = 1;');
    obj.updateGe();
end

function SpanView(src,~,obj)
        switch get(src,'Value')
            case get(src,'Max')                
                stopTimer(obj);
            case get(src,'Min')
                startTimer(obj);
        end

end

function zoomCamera(src,~,obj)
    obj.CamRoll = get(src,'Value');
    obj.updateGe();
end

function resetView(~,~,obj)
    obj.CamRoll = 5;
    obj.CamTilt = 5; 
    evalin('base','Ch = 1;');
    obj.updateGe();
end

function wrap_cb2()
% wrap_cb.m--Callback for "wrap" dial.
%-------------------------------------------------------------------------
obj = evalin('base','GE');
wrapDial = dial.find_dial('wrapDial2');
obj.CamTilt = round(get(wrapDial{1},'Value'));
obj.updateGe();
end       
%-------------------------------------------------------------------------
function wrap_cb1()
% wrap_cb.m--Callback for "wrap" dial.
%-------------------------------------------------------------------------
obj = evalin('base','GE');
wrapDial = dial.find_dial('wrapDial1');
obj.CamHead = round(get(wrapDial{1},'Value'));
obj.updateGe();
evalin('base','Ch = 0;');
end   

