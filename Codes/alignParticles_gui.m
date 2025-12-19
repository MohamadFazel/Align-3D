function [guiFig]=alignParticles_gui()
%This gui provides a user friendly interface to pick particles and then
%align them using a given template. The gui has two section: "piack
%particles" and "align paticle". In the following, the description for each
%button and parameter is given. 
%
%pick particles section:
%   LOAD DATA: 
%   This button allow picking and loading the localizations. The
%   localizations can be either 2D or 3D and the parameters must be (Xc,Yc,Zc)
%   or (Xt,Yt,Zt). When the data is loaded the localizations are plotted on
%   the left. The loaded data contains multiple similar structures, which
%   can be picked one-by-one by zooming on them.
%   ADD LOCS:
%   After zooming on an individual structure, this button adds the
%   sturuvture to the set of picked particles and highlights it in red.
%   ROI counts: 
%   Shows the number of picked structures/particles/ROIS.
%   SAVE PARTICLES:
%   After picking all the structures, this button will save them into a mat-file
%
%align particles section:
%   LOAD PARTICLES:
%   This button loads the set of previously picked and saved particles.
%   LOAD TEMPLATE:
%   This button loads the template used for alignment.
%   ALIGN PARTICLES:
%   This button starts aligning the particles with the give template. The
%   progress is shown in the tab bellow. 
%   SAVE ALIGNED:
%   This button save the aligned particles into a mat-file.
%
%   GEN IMAGE: 
%   This button opens up a new sub-gui to filter out some of the
%   localizations and reconstruct an image from the remaining ones.
%   LOAD DATA: 
%   This button is used to load the aligned particles saves in the previous
%   section. If you have already aligned and saved the particles, you won't
%   need to load them again as they already exist in the work enviroment.
%   FIND NND:
%   This button finds the neighboring localization distances where the
%   neighbor order is given in the text to the right. 
%   DISTANCE THRESH:
%   The threshold used for filtering. All the localizations with
%   neighboring distances larger than this threhsold will be filter out.
%   MAKE IMAGE: 
%   This button generates images from the remaining localizations after
%   filtering and uses the zoom factor given on the right.
%   SAVE IMAGE:
%   This will save the generaged images in the png-format.
%   
%

    guiFig = figure('NumberTitle','off','Resize','off','Units','Pixels',...
             'Name','align particles user interface','Visible','on',...
             'Interruptible','off','Position',[400,300,700,500]);

    Ax = uiaxes(guiFig,'Position',[15,15,530,480]);

    PickParticles=uipanel('Parent',guiFig,'Title','pick particles','Position',[0.79 0.555 0.187 0.43]);

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','LOAD DATA',...
        'Position',[14 165 100 30],'Callback',@loadData)

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','ADD LOCS',...
        'Position',[14 120 100 30],'Callback',@addLOCS)

    uicontrol('Parent',PickParticles,'Style','text','String','ROI counts',...
        'Position',[15,70,100,30]);

    ROIcount = uicontrol('Parent',PickParticles,'Style','edit','Position',[30 60 70 20],...
        'String','0');

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','SAVE PARTICLES',...
        'Position',[14 10 100 30],'Callback',@saveData)

    AlignParticles=uipanel('Parent',guiFig,'Title','align particles','Position',[0.79 0.125 0.187 0.42]);

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','LOAD PARTICLES',...
        'Position',[14 160 100 30],'Callback',@loadParticles)

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','LOAD TEMPLATE',...
        'Position',[14 120 100 30],'Callback',@loadTemplate)

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','ALIGN PARTICLES',...
        'Position',[14 75 100 30],'Callback',@alignParticles)
    
    Iteration = uicontrol('Parent',AlignParticles,'Style','edit','Position',[30 55 70 20],...
        'String','0');

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','SAVE ALIGNED',...
        'Position',[14 10 100 30],'Callback',@saveAligned)

     uicontrol('Parent',guiFig,'Style','pushbutton','String','GEN IMAGE',...
        'Position',[570 30 100 30],'Callback',@genImage)

    %global parameters
    filename = [];
    pathname = [];
    Locs(1).X = [];
    Locs(1).Y = [];
    Data = [];
    Temp = [];
    AlignedParticles = [];
    Xall = [];
    Yall = [];
    Zall = [];
    Thresh = [];
    NeighborNum = [];
    D = [];
    SRImXY = [];
    SRImXZ = [];
    SRImYZ = [];
    Mag = [];

    function loadData(~,~)
        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        VariableInfo = who('-file', fullfile(pathname,filename));
        if ismember('Zc', VariableInfo)
            load(fullfile(pathname,filename),'Xc','Yc','Zc')
        elseif ismember('Xc', VariableInfo)
            load(fullfile(pathname,filename),'Xc','Yc')
        elseif ismember('Zt', VariableInfo)
            load(fullfile(pathname,filename),'Xt','Yt','Zt')
        else
            load(fullfile(pathname,filename),'Xt','Yt')
        end
        
        if exist('Xc','var')
            Data.X = Xc;
            Data.Y = Yc;
        else
            Data.X = Xt;
            Data.Y = Yt;
        end

        if ismember('Zc', VariableInfo)
           Data.Z = Zc;
        end
        if ismember('Zt', VariableInfo)
           Data.Z = Zt;
        end
        
        hold(Ax,"on")
        plot(Data.X,Data.Y,'.')
        axis tight
    end

    function loadTemplate(~,~)
         
        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        load(fullfile(pathname,filename),'Temp')
        
        figure;
        plot3(Temp.X,Temp.Y,Temp.Z,'.')
        xlabel('X');ylabel('Y');zlabel('Z')

    end

    function loadParticles(~,~)

        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        load(fullfile(pathname,filename),'Locs')

    end

    function addLOCS(~,~)

        XLimits = xlim;
        YLimits = ylim;
        ID = Data.X > XLimits(1) & Data.X < XLimits(2) & ...
            Data.Y > YLimits(1) & Data.Y < YLimits(2);
        if isempty(Locs(1).X)
            Locs(1).X = Data.X(ID);
            Locs(1).Y = Data.Y(ID);
            if isfield(Data,'Z')
                Locs(1).Z = Data.Z(ID);
            else
                Locs(1).Z = zeros(size(Locs(1).Y));
            end
        else
            Locs(end+1).X = Data.X(ID);
            Locs(end).Y = Data.Y(ID);
            if isfield(Data,'Z')
                Locs(end).Z = Data.Z(ID);
            else
                Locs(end).Z = zeros(size(Locs(end).Y));
            end
        end
        set(ROIcount,'String',length(Locs))
        Xs = linspace(XLimits(1),XLimits(2),10);
        Ys = linspace(YLimits(1),YLimits(2),10);
        plot(Xs,YLimits(1)*ones(1,10),'r')
        plot(Xs,YLimits(2)*ones(1,10),'r')
        plot(XLimits(1)*ones(1,10),Ys,'r')
        plot(XLimits(2)*ones(1,10),Ys,'r')

    end

    function saveData(~,~)
        
        save([pathname,filename(1:end-4),sprintf('_ROIcount_%d',length(Locs))],'Locs')

    end

    function saveAligned(~,~)
        
        save([pathname,filename(1:end-4),'_Aligned'],'AlignedParticles','Xall','Yall','Zall')
       
    end

    function alignParticles(~,~)

        AlignedParticles = [];
        Xall = [];
        Yall = [];
        Zall = [];
        for ii = 1:length(Locs)

            if ii/10 == floor(ii/10)
                set(Iteration,'String',ii)
                pause(0.05)
            end
            
            Start.Theta = 0;
            Start.ShiftX = 0;
            Start.ShiftY = 0;
            Start.ShiftZ = 0;
            Cutoff = 50;
            NChain = 1000;
            PlotFlag = 0;
            VideoFlag = 0;
            Locs(ii).Z = Locs(ii).Z*0.8;
            tmp = align3D_template(Temp,Locs(ii),Start,Cutoff,NChain,PlotFlag,VideoFlag);
            AlignedParticles(ii).X = tmp.X;
            AlignedParticles(ii).Y = tmp.Y;
            AlignedParticles(ii).Z = tmp.Z;
            AlignedParticles(ii).Error = tmp.Error;

            Xall = cat(1,Xall,tmp.X);
            Yall = cat(1,Yall,tmp.Y);
            Zall = cat(1,Zall,tmp.Z);

        end

        figure;plot3(Xall,Yall,Zall,'.')

    end

    function genImage(~,~)

          subGui = figure('NumberTitle','off','Resize','off','Units','Pixels',...
             'Name','gen image','Visible','on','MenuBar','none',...
             'Interruptible','off','Position',[900,400,180,245]);

           uicontrol('Parent',subGui,'Style','pushbutton','String','LOAD DATA',...
            'Position',[18 200 150 30],'Callback',@loadLocs)

          uicontrol('Parent',subGui,'Style','pushbutton','String','FIND NND',...
            'Position',[18 155 100 30],'Callback',@findNND)

          NeighborNum=uicontrol('Parent',subGui,'Style','edit','String','1',...
            'Position',[129 160 30 20]);

          uicontrol('Parent',subGui,'Style','text','String','DISTANCE THRESH',...
            'Position',[18 105 100 30],'Callback',@findNND)

          Thresh=uicontrol('Parent',subGui,'Style','edit','String','inf',...
            'Position',[129 118 30 20]);

          uicontrol('Parent',subGui,'Style','pushbutton','String','MAKE IMAGE',...
            'Position',[18 65 75 30],'Callback',@genIm)

          uicontrol('Parent',subGui,'Style','text','String','ZOOM',...
            'Position',[98 60 35 30])

          Mag=uicontrol('Parent',subGui,'Style','edit','String','1',...
            'Position',[135 72 25 20]);

          uicontrol('Parent',subGui,'Style','pushbutton','String','SAVE IMAGE',...
            'Position',[18 15 150 30],'Callback',@saveImage)

    end

    function findNND(~,~)
        tmp = str2double(NeighborNum.String);
        [~,D] = knnsearch([Xall,Yall,Zall],[Xall,Yall,Zall],'K',tmp+1);
        figure;histogram(D(:,tmp+1))
    end

    function genIm(~,~)

        if exist('makeIm','file') ~= 2
            error('path to the makeIm() function must be added')
        end
        
        Neighb = str2double(NeighborNum.String) + 1;
        Thr = str2double(Thresh.String);
        SMD.X = Xall(D(:,Neighb)<Thr) - min(Xall(D(:,Neighb)<Thr)) + 10;
        SMD.Y = Yall(D(:,Neighb)<Thr) - min(Yall(D(:,Neighb)<Thr)) + 10;
        SMD.X_SE = 2*ones(size(Xall));
        SMD.Y_SE = 2*ones(size(Xall));
        PixSize = 2;
        SZ = ceil(max(max(SMD.X) - min(SMD.X), max(SMD.Y) - min(SMD.Y))/PixSize)*PixSize + 10;
        XStart = 0;
        YStart = 0;
        BoxSize = 20;
        SRIm=makeIm(SMD,SZ,PixSize,XStart,YStart,BoxSize);
        tmp=prctile(SRIm(:),99.8);
        SRIm(SRIm > tmp) = tmp;
        SRImXY = 255*SRIm/tmp;
        PiXNum = SZ/PixSize;
        SRImXY(PiXNum-11:PiXNum-9,PiXNum-20:PiXNum-11) = 255;
        Zoom = str2double(Mag.String);
        figure;imshow(SRImXY,[],'InitialMagnification',Zoom);colormap('hot')
        
        SMD.X = Xall(D(:,Neighb)<Thr) - min(Xall(D(:,Neighb)<Thr)) + 10;
        SMD.Y = Zall(D(:,Neighb)<Thr) - min(Zall(D(:,Neighb)<Thr)) + 10;
        SRIm=makeIm(SMD,SZ,PixSize,XStart,YStart,BoxSize);
        tmp=prctile(SRIm(:),99.8);
        SRIm(SRIm > tmp) = tmp;
        SRImXZ = 255*SRIm/tmp;
        SRImXZ(PiXNum-11:PiXNum-9,PiXNum-20:PiXNum-11) = 255;
        figure;imshow(SRImXZ,[],'InitialMagnification',Zoom);colormap('hot')

        SMD.X = Yall(D(:,Neighb)<Thr) - min(Yall(D(:,Neighb)<Thr)) + 10;
        SMD.Y = Zall(D(:,Neighb)<Thr) - min(Zall(D(:,Neighb)<Thr)) + 10;
        SRIm=makeIm(SMD,SZ,PixSize,XStart,YStart,BoxSize);
        tmp=prctile(SRIm(:),99.8);
        SRIm(SRIm > tmp) = tmp;
        SRImYZ = 255*SRIm/tmp;
        SRImYZ(PiXNum-11:PiXNum-9,PiXNum-20:PiXNum-11) = 255;
        figure;imshow(SRImYZ,[],'InitialMagnification',Zoom);colormap('hot')

    end

    function loadLocs(~,~)
        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        load(fullfile(pathname,filename),'Xall','Yall','Zall')
        figure;plot3(Xall,Yall,Zall,'.')
        xlabel('X(nm)');ylabel('Y(nm)');zlabel('Z(nm)')
    end

    function saveImage(~,~)
        imwrite(SRImXY,hot(256),[pathname,filename(1:end-4),'_AlignedXY.png'])
        imwrite(SRImXZ,hot(256),[pathname,filename(1:end-4),'_AlignedXZ.png'])
        imwrite(SRImYZ,hot(256),[pathname,filename(1:end-4),'_AlignedYZ.png'])
    end

end
