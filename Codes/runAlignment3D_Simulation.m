%% loading the template

load('Template_NPC.mat')

%% generating data

tmpX = [];
tmpY = [];
tmpZ = [];
for ii = 1:length(Temp.X)
    tmpX = cat(2,tmpX,Temp.X(ii)+10*randn(1,25));
    tmpY = cat(2,tmpY,Temp.Y(ii)+10*randn(1,25));
    tmpZ = cat(2,tmpZ,Temp.Z(ii)+10*randn(1,25));
end
figure;plot3(tmpX,tmpY,tmpZ,'.')

%rotation
ThetaX = pi/4;
Rx = [1 0 0;
     0 cos(ThetaX) -sin(ThetaX);
     0 sin(ThetaX) cos(ThetaX)];
Locs = Rx*[tmpX;tmpY;tmpZ];
tmpX = Locs(1,:);
tmpY = Locs(2,:)+150;
tmpZ = Locs(3,:);
figure;plot3(tmpX,tmpY,tmpZ,'.')

ThetaY = pi/5;
Ry = [cos(ThetaY) 0 sin(ThetaY);
      0 1 0;
      -sin(ThetaY) 0 cos(ThetaY)];
Locs = Rx*[tmpX;tmpY;tmpZ];
tmpX = Locs(1,:)-230;
tmpY = Locs(2,:)+10;
tmpZ = Locs(3,:)-70;
figure;plot3(tmpX,tmpY,tmpZ,'.')
hold;plot3(Temp.X,Temp.Y,Temp.Z,'o','linewidth',1.5)
axis equal
xlabel('X(nm)');ylabel('Y(nm)');zlabel('Z(nm)')
legend('simulated data','template')
set(gca,'FontSize',14)

Data.X = tmpX;
Data.Y = tmpY;
Data.Z = tmpZ;

%% run the code

addpath('Codes')

Start.Theta = 0;
Start.ShiftX = 0;
Start.ShiftY = 0;
Start.ShiftZ = 0;
Cutoff = 50;
NChain = 4000;
PlotFlag = 1;

align3D_template(Temp,Data,Start,Cutoff,NChain,PlotFlag,1);
