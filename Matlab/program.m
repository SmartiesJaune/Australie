% taux_dot_mag=109590;

function varargout = program(varargin)
% PROGRAM MATLAB code for program.fig
%      PROGRAM, by itself, creates a new PROGRAM or raises the existing
%      singleton*.
%
%      H = PROGRAM returns the handle to a new PROGRAM or the handle to
%      the existing singleton*.
%
%      PROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRAM.M with the given input arguments.
%
%      PROGRAM('Property','Value',...) creates a new PROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before program_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to program_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help program

% Last Modified by GUIDE v2.5 02-Aug-2016 17:09:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @program_OpeningFcn, ...
                   'gui_OutputFcn',  @program_OutputFcn, ...
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
global path2;




% --- Executes just before program is made visible.
function program_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to program (see VARARGIN)
'Lancement du programme'

handles.imageisloaded=0;
handles.chosen_algorithm=1;
handles.folder_cal='No Path Chosen';
handles.notbusy=1; %If troncature is busy or not during rect
handles.contrast=0; %best contrast for image
handles.maxbeforecontrast=255;
handles.minbeforecontrast=0;




guidata(hObject,handles)
% Choose default command line output for program
handles.output = hObject;

% Update handles structure
guidata(hObject, handles)

% UIWAIT makes program wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = program_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_ApproxGo. CREATION CAL
function pushbutton_ApproxGo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ApproxGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.chosen_algorithm==1)
    'Lancement de l''algorithme 1: ApproxGauss'
if(handles.imageisloaded)
    img2=handles.img2;
    histo=mean(img2); %histogram of image
    if(handles.pixelrate)
        x=(1:length(histo))*handles.pixelrate; % to do before or after fit ?
    else
        x=1:length(histo);
    end
    figure
    plot(x,histo);
    hold on
    
    
    power= handles.lastSliderVal
    p=fit_hgauss(x,histo,power);

    %  p=fit_gauss_2(x,histo);
    fit=p(1)+p(2)*exp(-((x-p(3))./(sqrt(2)*p(4))).^power);

    
    plot(x,fit)
    xlabel('pixel')
    error=histo-fit;
        mean_square_error=(error*error')/length(error);

    %set title (in nm if pixelrate has been defined, else in pixels)
    if(power==2) %Gaussian fit (not hypergaussian)
        if(handles.pixelrate) %is defined
            %fit has been done with x in pixelrate
%           title(['Gaussian fit: FWHM=',num2str(2.355*p(4)*handles.pixelrate),'nm   Error=',num2str(round(mean_square_error))])
            title(['Gaussian fit: FWHM=',num2str(2.355*p(4)),'pix   Error=',num2str(round(mean_square_error))])            
            xlabel('nm')
        else
            title(['Gaussian fit: FWHM=',num2str(2.355*p(4)),'pix   Error=',num2str(round(mean_square_error))])
        end
    else
        if(handles.pixelrate) %is defined
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*p(4)*handles.pixelrate),'nm'];['Error=',num2str(round(mean_square_error)), ' power=',num2str(power)]})
            xlabel('nm')
        else
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*p(4)),'pix'];[ 'Error=',num2str(round(mean_square_error)),' power=',num2str(power)]})
        end
    end

else
     axes(handles.axes1)
     title('You could load an image before ?')
end
%FWHM -ie half maximum width- is sqrt(ln(256))*sigma so approximately 2.355*sigma
%If hypergaussian of power n:
% FWHM=2sqrt(2)*ln(2)^1/n *sigma =2.8284*(0.6931)^(1/n)*sigma



elseif(handles.chosen_algorithm==2) %Autopower

    'Lancement de l''algorithme 2: ApproxGauss, automatic best power'
if(handles.imageisloaded)

    img2=handles.img2;
    histo=mean(img2); %histogram of image

    x=1:length(histo);
    if(handles.pixelrate)
        x=x*handles.pixelrate; %maybe change x before fit and not after?
    end
    figure
    plot(x,histo);
    hold on

%search best power for fit
	chosen_p=zeros(1,5);
  	best_pow=2;
	minimalerror=Inf;
for(power=2:2:16)
    p=fit_hgauss(x,histo,power);
    fit=p(1)+p(2)*exp(-((x-p(3))./(sqrt(2)*p(4))).^power);
    error=histo-fit;
    mean_square_error=(error*error')/length(error);
	if(mean_square_error<minimalerror)
		best_pow=power;
		minimalerror=mean_square_error
		chosen_p=p;
	end
end

    power=best_pow;
    fit=chosen_p(1)+chosen_p(2)*exp(-((x-chosen_p(3))./(sqrt(2)*chosen_p(4))).^power);

    plot(x,fit)
    xlabel('pixel')

    %set title (in nm if pixelrate has been defined, else in pixels)
    if(power==2) %Gaussian fit (not hypergaussian)
        if(handles.pixelrate) %is defined
%             title(['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)*handles.pixelrate),'nm   Error=',num2str(round(minimalerror))])
            title(['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)),'nm   Error=',num2str(round(minimalerror))])
            xlabel('nm')
        else
            title(['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)),'pix   Error=',num2str(round(minimalerror))])
        end
    else
        if(handles.pixelrate) %is defined
%             title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)*handles.pixelrate),'nm'];['Error=',num2str(round(minimalerror)), ' power=',num2str(power)]})
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)),'nm'];['Error=',num2str(round(minimalerror)), ' power=',num2str(power)]})
            xlabel('nm')
        else
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)),'pix'];['Error=',num2str(round(minimalerror)),' power=',num2str(power)]})
        end
    end

else
     axes(handles.axes1)
     title('You could load an image before ?')
end

%FWHM -ie half maximum width- is sqrt(ln(256))*sigma so approximately 2.355*sigma
%If hypergaussian of power n:
% FWHM=2sqrt(2)*ln(2)^1/n *sigma =2.8284*(0.6931)^(1/n)*sigma



% imgauss=p0(1)+p0(2)*exp(-(( x-p0(3)).^2+(y-p0(4)).^2)/(2*p0(5)^2));
% imshow(imgauss);
    
elseif(handles.chosen_algorithm==3)
    'Lancement de l''algorithme 3'
%TO do: check if image is loaded

maxiter=50;
iter=0;
n_holes=handles.n_holes;
% n_holes=get();
num=0;
im=handles.img2;
im_med=median(median(im));
%on fait varier le seuil jusqua trouver n_holes trous:
%threshold change until we find the good number of hole (we always
%decrease, so we may pass the good threshold => improvement...)
while((iter<maxiter)*(num~=n_holes))
	imbinary=im<im_med/(1+iter/5);
	[L_note,num]=bwlabel(imbinary);
	iter=iter+1;
end


%detection des contours: quand il n'y a pas de '1' sur une colonne
Histo=max(imbinary);
i=1:length(Histo)-1;
contours=(Histo(i)~=Histo(i+1));
% for exemple Histo= [0 0 1 1 1 0 0 a] will give contours=[0 1 0 0 1 0 0 ]
position_contours=contours.*i % give 0 2 0 0 5 0 0
position_contours(position_contours==0)=[] %DELETE THE 0s
edge_positions=reshape(position_contours,[2 n_holes]);
edge_positions(2,:)=min(length(Histo),edge_positions(2,:)+1);


%eventually we can horizontally enlarge the chosen area with:
radius_x=handles.xplus;
edge_positions(1,:)=max(0,edge_positions(1,:)-radius_x);
edge_positions(2,:)=min(length(Histo),edge_positions(2,:)+radius_x);
% problem?


%or
% detect_left=1;
% holenumber=1;
% shift=2;
% for(i=1:length(Histo)-1)
% 	if(position_contours(i))
% 		if(detect_left)
% 			detect_left=0;
% 			edge_positions(1,holenumber)=position_contours(i)-shift;
% 		else
% 			detect_left=1;	
% 			edge_positions(2,holenumber)=position_contours(i)+shift;
% 			holenumber=holenumber+1;
% 		end
% 	end
% end

%We cut the image in n_holes images containing the hole
% We make the automatic best fit
radius=handles.yplus; %we will do approxgauss on a X*radius image
img_for_user=im; %to show which regions have been selected
figure

hole_size_mean=0;

for(n=1:n_holes)
    imcutbinary=imbinary(:,edge_positions(1,n):edge_positions(2,n));
    Histoy=max(imcutbinary');
    L=length(Histoy);
    i=1:L-1;
    contoursy=(Histoy(i)~=Histoy(i+1));
    position_contours_y=contoursy.*i;
    position_contours_y(position_contours_y==0)=[];
    middle=(position_contours_y(1)+position_contours_y(2))/2;
    img=im(max(0,round(middle-radius/2)):min(L,round(middle+radius/2)),edge_positions(1,n):edge_positions(2,n)); %tronq image
    subplot(2,n_holes,n)
    imshow(img)
    title(['Hole # ',num2str(n)])
        
    %Now we have the cutted image, we proceed with fit:
    

    subplot(2,n_holes,n+n_holes)
    histo=mean(img); %histogram of image

    if(handles.pixelrate)
        x=(1:length(histo))*handles.pixelrate; % to do before or after fit ?
    else
        x=1:length(histo);
    end
    plot(x,histo);
    hold on
    
%search best power for fit
	chosen_p=zeros(1,5); %5: the five parameters for p
  	best_pow=2;
	minimalerror=Inf;
    for(power=2:2:16)
        p=fit_hgauss(x,histo,power);
        fit=p(1)+p(2)*exp(-((x-p(3))./(sqrt(2)*p(4))).^power);
        error=histo-fit;
        mean_square_error=(error*error')/length(error);
        if(mean_square_error<minimalerror)
            best_pow=power;
            minimalerror=mean_square_error;
            chosen_p=p;
        end
    end

    power=best_pow;
    fit=chosen_p(1)+chosen_p(2)*exp(-((x-chosen_p(3))./(sqrt(2)*chosen_p(4))).^power);

    plot(x,fit)
    xlabel('pixel')

    %set title (in nm if pixelrate has been defined, else in pixels)
    if(power==2) %Gaussian fit (not hypergaussian)
        if(handles.pixelrate) %is defined
%             title({['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)*handles.pixelrate),'nm'];['Error=',num2str(round(minimalerror))]})
            title({['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)),'nm'];['Error=',num2str(round(minimalerror))]})
            xlabel('nm')
        else
            title({['Gaussian fit: FWHM=',num2str(2.355*chosen_p(4)),'pix'];['Error=',num2str(round(minimalerror))]})
        end
    else
        if(handles.pixelrate) %is defined
%             title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)*handles.pixelrate),'nm'];['Error=',num2str(round(minimalerror)), ' power=',num2str(power)]})
           %fit has been done in nm, so no need to multiply by pixelrate !
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)),'nm'];['Error=',num2str(round(minimalerror)), ' power=',num2str(power)]})
            xlabel('nm')
        else
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*chosen_p(4)),'pix' ];[  'Error=',num2str(round(minimalerror)),' power=',num2str(power)]})
        end
    end

    hole_size_mean=hole_size_mean+2.8284*(0.6931)^(1/power)*chosen_p(4);
    
    %finally, we will make a visible rectangle for user:
    img_for_user(max(0,round(middle-radius/2)),edge_positions(1,n):edge_positions(2,n))=255-n;
    img_for_user(min(L,round(middle+radius/2)),edge_positions(1,n):edge_positions(2,n))=255-n;
    img_for_user(max(0,round(middle-radius/2)):min(L,round(middle+radius/2)),edge_positions(1,n))=255-n;
    img_for_user(max(0,round(middle-radius/2)):min(L,round(middle+radius/2)),edge_positions(2,n))=255-n;
end
hole_size_mean=hole_size_mean/n_holes


figure
subplot(2,2,3)
imshow(img_for_user)
subplot(2,2,1)
imshow(L_note);
subplot(2,2,2)
imshow(im)
% ecart_final=3; %will take 3 or 4 thick -images to do the gaussian fit
% shift=floor(max(0,(edge_positions(2,:)-ecart_final-edge_positions(1,:))/2))
% shifted_positions=[edge_positions(1,:)+shift;edge_positions(2,:)-shift]



else 'Erreur: l''algorithme choisi n''est pas entier';







end



    
% --- Executes on button press in pushbutton_tronc. TRONQUER
function pushbutton_tronc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tronc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%On se place sur la premiere image
if(handles.imageisloaded)
    if(handles.notbusy)
        handles.notbusy=0;
        guidata(hObject,handles)

        axes(handles.axes1)
        img_old=handles.img2; %we save the precedent image, if needed user can go back

        imshow(img_old)
        rect = round(getrect());

%verify size
s=size(img_old)
	if(rect(2)+rect(4)>s(1))
	rect(4)=s(1)-rect(2);
	end
	if(rect(1)+rect(3)>s(2))
	rect(3)=s(2)-rect(1);
	end

        img2=img_old(rect(2):(rect(2)+rect(4)),rect(1):(rect(1)+rect(3)));
        axes(handles.axes1)
        imshow(img2)

        handles.img2=img2;
        handles.img_old=img_old;
        handles.notbusy=1;
        guidata(hObject,handles)

    end
else
     axes(handles.axes1)
     title('You could load an image before ?')
end



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.chosen_algorithm=get(hObject,'Value');
guidata(hObject,handles); %sauvegarde le nouveau handle

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Set or unset best contrast
function checkbox_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageisloaded)
    if(handles.contrast)
%set old contrast
        handles.contrast=0;
        img2=handles.img2;
        maxi=handles.maxbeforecontrast;
        mini=handles.minbeforecontrast;
        img2=uint8((double(img2)*(maxi-mini)/255+mini));
        axes(handles.axes1)
        handles.img2=img2;
        imshow(img2,'DisplayRange',[0 255],'InitialMagnification','fit');
        
        guidata(hObject,handles)
        
    else
        %Contrast
        img2=handles.img2;

        handles.contrast=1;

        temp=double(img2);
        maxi=max(max(temp));
        mini=min(min(temp));
        handles.maxbeforecontrast=maxi;
        handles.minbeforecontrast=mini;
        img2=uint8((((temp-mini)*255/(maxi-mini))));
        
        axes(handles.axes1)
        handles.img2=img2;
        imshow(img2,'DisplayRange',[0 255],'InitialMagnification','fit');
        
        guidata(hObject,handles)


    end
    guidata(hObject,handles)
else
     axes(handles.axes1)
     title('You could load an image before ?')
end



% Hint: get(hObject,'Value') returns toggle state of checkbox_contrast


% Button LOAD
function pushbutton_loadpath_Callback(hObject, eventdata, handles)

% handles.folder_cal=uigetdir;
% guidata(hObject,handles); %sauvegarde le nouveau handle
% set(handles.edit_path, 'String', handles.folder_cal);
try
[NomFic,NomEmp] = uigetfile({'*';'*.jpg';'*.png';'*.bmp'},'Choisissez une image',get(handles.edit_path,'String')); % Choisir une image 
catch
[NomFic,NomEmp] = uigetfile({'*';'*.jpg';'*.png';'*.bmp'},'Choisissez une image'); % Choisir une image 
end
if(NomFic) %if a file has been chosen
    img=(imread(strcat(NomEmp,NomFic)));
    s=size(img);
    try %if image has multiple arrays
        img=rgb2gray(img(:,:,1:3)); % 1:3 because of problem with tiff image, fourth dimension exist with only 255 in it
        'conversion en gris'
    end
    
    
    handles.img=img;
    handles.img2=img;
    handles.NomFic=NomFic;
    %reset contrast:
    set(handles.checkbox_contrast,'Value',0)
    handles.maxbeforecontrast=255;
    handles.minbeforecontrast=0;
    
    
    handles.contrast=0;
    handles.imageisloaded=1;
    set(handles.edit_mag,'BackgroundColor',[0.8,0.1,0.1]);
    guidata(hObject,handles)

    %display image
    axes(handles.axes2)
    imshow(img); title(NomFic);
    axes(handles.axes1)
    imshow(img)
    axes(handles.axes_mag)
    s=size(img) %already done ?
if(s(1)>70)
    im_mag=img(s(1)-70:s(1),round(s(2)/2):s(2));
else
    im_mag=img(1:s(1),round(s(2)/2):s(2));
end
    imshow(im_mag);
    title('Mag');

	addpath(NomEmp)
    %Path
    path2=NomEmp;
    set(handles.edit_path,'String',path2);
    
end
% guidata(hObject,handles); %sauvegarde le nouveau handle
% set(handles.edit_path, 'String', handles.folder_cal);


% edit2_Callback(hObject, eventdata, handles)

% hObject    handle to pushbutton_loadpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%TEXT for path
function edit_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.folder_cal=get(hObject,'String');

% Hints: get(hObject,'String') returns contents of edit_path as text
%        str2double(get(hObject,'String')) returns contents of edit_path as a double


% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function pushbutton_tronc_CreateFcn(hObject, eventdata, handles)

% hObject    handle to pushbutton_loadpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function pushbutton_loadpath_CreateFcn(hObject, eventdata, handles)

% hObject    handle to pushbutton_loadpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Reset Troncature 
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.imageisloaded)
    handles.img2=handles.img;   
    handles.notbusy=1;
    guidata(hObject,handles)
%     handles.img=img;
%     handles.img2=img;
%     guidata(hObject,handles)
    
    axes(handles.axes1)
    imshow(handles.img);
else
     axes(handles.axes1)
     title('You could load an image before ?')
end


%USER GIVE THE MAGNIFICATION
function edit_mag_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

magnif=str2double(get(hObject,'String'));
if isnan(magnif) %not va valid number
    set(handles.edit_mag,'String','x');
    handles.pixelrate=0;
    set(hObject,'BackgroundColor','red')
    set(handles.text_taux,'String','Maybe try a number?');
else %set new magnification , and new pixelrate
    handles.magnification=str2double(get(hObject,'String'));
    handles.pixelrate=109590/magnif; %on Image: 1pix = pixelrate nm
    set(handles.text_taux,'String',strcat('1 Pix=',num2str(round(109590/magnif,3)),'nm'));
    set(hObject,'BackgroundColor','white')
    pause(0.05)
    set(hObject,'BackgroundColor','green')
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit_mag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mag (see GCBO)
% eventdataguidata(hObject,handles)  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.pixelrate=0; %not defined
guidata(hObject,handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','red');
end


% --- Executes on button press in pushbutton_manual.
%User choose two points and receive the distance in nm between them.
function pushbutton_manual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageisloaded)

        axes(handles.axes1)
        rect = round(getrect());
        distance=sqrt(rect(3)*rect(3)+rect(4)*rect(4)) %in pixel
        if(handles.pixelrate)
            distance=distance*handles.pixelrate; %in nm
            title(['distance = ',num2str(distance),' nm']);
            handles.distance=distance;
        else
            title(['distance = ',num2str(distance),' pix']);
        end
        guidata(hObject,handles)
else
     axes(handles.axes1)
     title('You could load an image before ?')
end




% --- Set the actual image as the working image
function pushbutton_saveimg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageisloaded)
    axes(handles.axes2)
    handles.img=handles.img2; 
    imshow(handles.img)
    guidata(hObject,handles)
else
     axes(handles.axes1)
     title('You could load an image before ?')
end


% --- Executes on button press in pushbutton_backimg.
function pushbutton_backimg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_backimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageisloaded)
    axes(handles.axes1)
    handles.img2=handles.img_old; %we save the precedent image, if needed user can go back
    imshow(handles.img_old)
    guidata(hObject,handles)
else
     axes(handles.axes1)
     title('You could load an image before ?')
end




% --- Executes on slider movement.
% Slider for Hypergaussian or Gaussian fit (set the power)
function slider_power_Callback(hObject, eventdata, handles)
% hObject    handle to slider_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 value=2*round(get(hObject, 'Value')/2); %only odd number

 handles.lastSliderVal = value;
 set(handles.text_sliderpower,'String',num2str(value));
 set(handles.slider_power, 'Value', value);
 guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Slider for Hypergaussian or Gaussian fit (set the power)
function slider_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% set the slider range and step size
 numSteps = 8;
 set(hObject, 'Min', 2);
 set(hObject, 'Max', 16);
 set(hObject, 'Value', 2);
 set(hObject, 'SliderStep', [1/(numSteps-1) , 1/(numSteps-1) ]);
 % save the current/last slider value
 handles.lastSliderVal = 2;
 % Update handles structure
 guidata(hObject, handles);



% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- _approxgauss2D.
function pushbutton_approxgauss2d_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_approxgauss2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)4

'Approxgauss2D'

if(handles.imageisloaded)
    img2=double(handles.img2);
    s=size(img2);
    figure
    subplot(2,2,1)
    imshow2(img2)
title('original image')
    subplot(2,2,3)
    power= handles.lastSliderVal;

%Gaussian Fit:
%     p=fit_hgauss2D((255-img2),power) %hgauss2D is for rising gaussians, not 'U' or 'hole' like
%     p(1)=255-p(1);
%     p(2)=-p(2);
    %or:
    p=fit_hgauss2D_neg(img2,power);
    
    G=hgauss2D(s,p,power);
    imshow2(G)
    error=reshape(G-img2,1,s(1)*s(2)); %column with differences value-fit
    mean_square_error=(error*error')/length(error);

    %set title (in nm if pixelrate has been defined, else in pixels)
    if(power==2) %Gaussian fit (not hypergaussian)
        if(handles.pixelrate) %is defined
            
            title({['Gaussian fit: FWHM=',num2str(2.355*p(5)*handles.pixelrate),'nm'] ; [ ' MSE=',num2str(round(mean_square_error))]})
        else
            title({['Gaussian fit: FWHM=',num2str(2.355*p(5)),'pix'];[' MSE=',num2str(round(mean_square_error))]})
        end
    else
        if(handles.pixelrate) %is defined
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*p(5)*handles.pixelrate),'nm'];['   MSE=',num2str(round(mean_square_error)), ' power=',num2str(power)]})
        else
            title({['HyperGaussian fit: FWHM=',num2str(2.8284*(0.6931)^(1/power)*p(5)),'pix'];[  ' MSE=',num2str(round(mean_square_error)),' power=',num2str(power)]})
        end
    end

    
%     img2(1:5,1:5)
%     G(1:5,1:5)
    coupeX=(img2(round(p(3)),:));
    coupeY=(img2(:,round(p(4))));
    subplot(2,2,2)
    plot(coupeX)
    hold on
    plot(G(round(p(3)),:))
    title('x profile')
    
    subplot(2,2,4)
    plot(coupeY)
    hold on
    plot(G(:,round(p(4))))
    title('y profile')
    
%     p(3)

    
else
     axes(handles.axes1)
     title('You could load an image before ?')
end

%FWHM -ie half maximum width- is sqrt(ln(256))*sigma so approximately 2.355*sigma
%If hypergaussian of power n:
% FWHM=2sqrt(2)*ln(2)^1/n *sigma =2.8284*(0.6931)^(1/n)*sigma



% USER GIVE N_HOLES TO SEARCH WITH APPROXGAUSS FULL AUTO
function edit_nholesforApproxg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nholesforApproxg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nholesforApproxg as text
%        str2double(get(hObject,'String')) returns contents of edit_nholesforApproxg as a double
n_holes=str2double(get(hObject,'String'))
if isnan(n_holes) %not va valid number
    set(handles.edit_nholesforApproxg,'String','x');
    handles.n_holes=0;
    set(hObject,'BackgroundColor','red')
    set(handles.text_taux,'String','Maybe try a number?');
else %set new n_holes
    handles.n_holes=str2double(get(hObject,'String'));
    set(hObject,'BackgroundColor','white')
    pause(0.05)
    set(hObject,'BackgroundColor','green')
end
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function edit_nholesforApproxg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nholesforApproxg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xplus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xplus as text
%        str2double(get(hObject,'String')) returns contents of edit_xplus as a double
x_plus=str2double(get(hObject,'String'))
if isnan(x_plus) %not va valid number
    set(handles.edit_xplus,'String','x');
    handles.xplus=0;
    set(hObject,'BackgroundColor','red')
else %set new n_holes
    handles.xplus=str2double(get(hObject,'String'));
    set(hObject,'BackgroundColor','white')
    pause(0.05)
    set(hObject,'BackgroundColor','green')
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit_xplus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

handles.xplus=2;
set(hObject,'String',num2str(handles.xplus));
guidata(hObject,handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yplus_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yplus as text
%        str2double(get(hObject,'String')) returns contents of edit_yplus as a double
y_plus=str2double(get(hObject,'String'))
if isnan(y_plus) %not va valid number
    set(handles.edit_yplus,'String','x');
    handles.yplus=0;
    set(hObject,'BackgroundColor','red')
else %set new n_holes
    handles.yplus=str2double(get(hObject,'String'));
    set(hObject,'BackgroundColor','white')
    pause(0.05)
    set(hObject,'BackgroundColor','green')
end
guidata(hObject,handles)







% --- Executes during object creation, after setting all properties.
function edit_yplus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

handles.yplus=3;
set(hObject,'String',num2str(handles.yplus));
guidata(hObject,handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
