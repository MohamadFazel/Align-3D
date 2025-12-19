%% laoding template and data

load('Data_rotatedNPC.mat')
load('Template_NPC.mat')

figure;plot3(Data.X,Data.Y,Data.Z,'.')
hold;plot3(Temp.X,Temp.Y,Temp.Z,'o','linewidth',1.5)
axis equal
xlabel('X(nm)');ylabel('Y(nm)');zlabel('Z(nm)')
legend('simulated data','template')
set(gca,'FontSize',14)

%% run the code

%initial rotations and shifts set to zero
Start.Theta = 0;
Start.ShiftX = 0;
Start.ShiftY = 0;
Start.ShiftZ = 0;

%localizations further than 50nm from the template are not considered
Cutoff = 50;
%number of iterations (number of random shifts and rotations proposed)
NChain = 4000;
%showin an animation of the alignment on the fly
PlotFlag = 1;
%saving video of the animation
VideoFLag = 0;

align3D_template(Temp,Data,Start,Cutoff,NChain,PlotFlag,VideoFLag);
