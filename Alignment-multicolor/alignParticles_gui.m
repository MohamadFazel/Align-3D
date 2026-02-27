function [guiFig]=alignParticles_gui()

    guiFig = figure('NumberTitle','off','Resize','off','Units','Pixels',...
             'Name','align particles user interface','Visible','on',...
             'Interruptible','off','Position',[400,300,700,500]);

    Ax = uiaxes(guiFig,'Position',[15,15,530,480]);

    PickParticles=uipanel('Parent',guiFig,'Title','pick particles','Position',[0.79 0.52 0.187 0.46]);

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','LOAD DATA',...
        'Position',[14 170 100 30],'Callback',@loadData)

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','ADD LOCS',...
        'Position',[14 120 100 30],'Callback',@addLOCS)

    uicontrol('Parent',PickParticles,'Style','text','String','ROI counts',...
        'Position',[15,70,100,30]);

    ROIcount = uicontrol('Parent',PickParticles,'Style','edit','Position',[30 60 70 20],...
        'String','0');

    uicontrol('Parent',PickParticles,'Style','pushbutton','String','SAVE PARTICLES',...
        'Position',[14 10 100 30],'Callback',@saveData)

    AlignParticles=uipanel('Parent',guiFig,'Title','align particles','Position',[0.79 0.065 0.187 0.44]);

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','LOAD PARTICLES',...
        'Position',[14 165 100 30],'Callback',@loadParticles)

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','LOAD TEMPLATE',...
        'Position',[14 120 100 30],'Callback',@loadTemplate)

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','ALIGN PARTICLES',...
        'Position',[14 75 100 30],'Callback',@alignParticles)
    
    Iteration = uicontrol('Parent',AlignParticles,'Style','edit','Position',[30 55 70 20],...
        'String','0');

    uicontrol('Parent',AlignParticles,'Style','pushbutton','String','SAVE ALIGNED',...
        'Position',[14 10 100 30],'Callback',@saveAligned)

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

    function loadData(~,~)
        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        VariableInfo = who('-file', fullfile(pathname,filename));
        if ismember('Zc', VariableInfo)
            load(fullfile(pathname,filename),'Xc','Yc','Zc')
        else
            load(fullfile(pathname,filename),'Xc','Yc')
        end
        
        Data.X = Xc;
        Data.Y = Yc;
        if ismember('Zc', VariableInfo)
           Data.Z = Zc;
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

        % [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        % load(fullfile(pathname,filename),'Locs')

        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5','MultiSelect','on');
        if iscell(filename)
            NIter = length(filename);
        else
            NIter = 1;
        end

        for ii = 1:NIter

            if NIter > 1
               load(fullfile(pathname,filename{ii}),'Locs')
            else
               load(fullfile(pathname,filename),'Locs')
            end

            if ii == 1
                tmp = Locs;
            else
                tmp = cat(2,tmp,Locs);
            end
        end
        if NIter > 1
            filename = sprintf('multiple_datasets_merged');
        end
        clear Locs
        Locs = tmp;

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

end
