
clear

%Set this to the directory where you have the Aligned files.
DataDir = '/Volumes/Group01/LRBGE/IMG-LRBGEImage/McNallyGroup/Mohamed/Kyung/Data/0407-Cep57 MINFLUX';
List = dir([DataDir,'/*Aligned.mat']);

Theta = 0:0.6981:2*pi;
R = 150;

[X,Y] = pol2cart(Theta,R);
figure;plot(X,Y,'.');
xlim([-180 180]);ylim([-180 180])

X = repmat(X,[1,16]);
Y = repmat(Y,[1,16]);
Z = [zeros(1,10),20*ones(1,10),40*ones(1,10),60*ones(1,10),80*ones(1,10),...
    100*ones(1,10),120*ones(1,10),140*ones(1,10),160*ones(1,10),180*ones(1,10),...
    200*ones(1,10),220*ones(1,10),240*ones(1,10),260*ones(1,10),280*ones(1,10),300*ones(1,10)];
figure;plot3(X,Y,Z,'ok','linewidth',1.2)
xlabel('X(nm)');ylabel('Y(nm)');zlabel('Z(nm)')
title('Template-Pattern')

Temp.X = X;
Temp.Y = Y;
Temp.Z = Z;

St.Theta = 0;
St.ShiftX = 0;
St.ShiftY = 0;
St.ShiftZ = 0;
Cutoff = 300;
NChain = 3000;
PlotFlag = 1;

%% 

for ii = 1:length(List)

    ii

    load([DataDir,'/',List(ii).name])
    
    Aligned=align3D_template(Temp,Aligned,St,Cutoff,NChain,PlotFlag);
    
    save([DataDir,'/',List(ii).name(1:end-16),'Aligned_Z'],'Aligned')
end

