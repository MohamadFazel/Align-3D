function [guiFig]=selectROIs_gui()

    guiFig = figure('NumberTitle','off','Resize','off','Units','Pixels',...
             'Name','select regions user interface','Visible','on',...
             'Interruptible','off','Position',[400,300,700,500]);

    uicontrol('Parent',guiFig,'Style','pushbutton','String','LOAD DATA',...
        'Position',[570 400 100 30],'Callback',@loadData)

    uicontrol('Parent',guiFig,'Style','pushbutton','String','ADD LOCS',...
        'Position',[570 330 100 30],'Callback',@addLOCS)

    uicontrol('Parent',guiFig,'Style','text','String','ROI counts',...
        'Position',[570,240,100,30]);

    ROIcount = uicontrol('Parent',guiFig,'Style','edit','Position',[585 230 70 20],...
        'String','0');

    uicontrol('Parent',guiFig,'Style','pushbutton','String','SAVE DATA',...
        'Position',[570 150 100 30],'Callback',@saveData)

    Ax = uiaxes(guiFig,'Position',[15,15,530,480]);

    %global parameters
    filename = [];
    pathname = [];
    Locs(1).X = [];
    Locs(1).Y = [];
    function loadData(~,~)
        [filename, pathname]=uigetfile(pwd,'\*.mat;*.ics;*.h5');
        load(fullfile(pathname,filename),'Xc','Yc')

        Data.X = Xc;
        Data.Y = Yc;
        
        hold(Ax,"on")
        plot(Data.X,Data.Y,'.')
        axis tight
    end

    function addLOCS(~,~)

        XLimits = xlim;
        YLimits = ylim;
        ID = Data.X > XLimits(1) & Data.X < XLimits(2) & ...
            Data.Y > YLimits(1) & Data.Y < YLimits(2);
        if isempty(Locs(1).X)
            Locs(1).X = Data.X(ID);
            Locs(1).Y = Data.Y(ID);
        else
            Locs(end+1).X = Data.X(ID);
            Locs(end).Y = Data.Y(ID);
        end
        set(ROIcount,'String',length(Locs))

    end

    function saveData(~,~)
        
        save([pathname,filename(1:end-4),sprintf('_ROIcount_%d',length(Locs))],'Locs')

    end

end

