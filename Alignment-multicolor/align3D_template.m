function [Aligned,Chain] = align3D_template(Temp,Input,Start,Penalty,NChain,PlotFlag,VideoFlag)
%align_template Aligns a set of points to a template.
% [Aligned,Chain] = BaGoL.align_template(Temp,Input,Start,Penalty,NChain,PlotFlag,VideoFlag)
%
% This method finds the shift and rotation of a set of points that minimizes
% the sum of distances of pairs from the sample to the template. Pair
% distances above a cutoff and unmatched points use the cost at the 
% cutoff distance. It shifts around the set of given points and rotates 
% them around a random axis by a random angle. 
%
% INPUTS:
%   Temp:       SMD Structure of the template with fields
%       X:      X positions of the template (nm)(Nx1)
%       Y:      Y positions of the template (nm)(Nx1)
%       Z:      Z positions of the template (nm)(Nx1)
%   Input:      SMD Structure of the sample with fields
%       X:      X positions of the sample (nm)(Mx1)
%       Y:      Y positions of the sample (nm)(Mx1)
%       Z:      Z positions of the sample (nm)(Mx1)
%   Start:      Structure of starting values for shift and rotation
%       Theta:  (radians)
%       ShiftX: (nm)
%       ShiftY: (nm)  
%       ShiftZ: (nm)
%    Penalty:   Saturation distance for cost function (nm) 
%    NChain:   Number of jumps in MCMC algorithm. (Default = 5000)
%    PlotFlag: 0 or 1, Show an animation of the accepted jumps. (Default = 0)
%
% OUTPUTS:
%    Aligned:  Structure containing the aligned coordinates
%       X:     (Mx1) (nm)
%       Y:     (Mx1) (nm)
%       Z:     (Mx1) (nm)
%       Error: distances between input template and data + penalties
%    Chain:    Structure array of accepted jumps in parameter space 
%       Theta:      Angle (radians) (NChain x 1)
%       Ax:         unit vector (NChain x 1)
%       XShift:     Sample shift in X (nm) (NChain x 1)
%       YShift:     Sample shift in Y (nm) (NChain x 1)
%       ZShift:     Sample shift in Z (nm) (NChain x 1)
%       Error:      sum distances between the template and data + penalties
%
% Created by:
%    Mohamadreza Fazel (LidkeLab 2019)

if nargin < 4
   error('There must be at leat 4 inputs.') 
end

if nargin < 5
   NChain = 5000;
   PlotFlag = 0;
   VideoFlag = 0;
end

if nargin < 6
   PlotFlag = 0; 
   VideoFlag = 0;
end

if nargin < 7
   VideoFlag = 0;
end

if VideoFlag == 1 && PlotFlag == 0
    error('to make a video PlotFlag must be 1 as well')
end

Aligned.X = [];
Aligned.Y = [];
Aligned.Z = [];

%Moving the center of mass of template to the origin
if size(Temp.X,1) == 1
    TempX = Temp.X' - mean(Temp.X);
    TempY = Temp.Y' - mean(Temp.Y);
    TempZ = Temp.Z' - mean(Temp.Z);
else
    TempX = Temp.X - mean(Temp.X);
    TempY = Temp.Y - mean(Temp.Y);
    TempZ = Temp.Z - mean(Temp.Z);
end

XLim = [min(TempX)-10 max(TempX)+10];
YLim = [min(TempY)-10 max(TempY)+10];

if size(Input.X,1) == 1
    X = Input.X';
    Y = Input.Y';
    Z = Input.Z';
else
    X = Input.X;
    Y = Input.Y;
    Z = Input.Z;
end
%Moving the center of mass of the data to the origin
X = X - mean(X);
Y = Y - mean(Y);
Z = Z - mean(Z);

%Finding the initial difference (cost/error) between data and template
Points = [X,Y,Z];
[~,Dis] = knnsearch([TempX,TempY,TempZ],Points);
Dis = abs(Dis);
Dis(Dis>Penalty) = Penalty;
Cost_Current = sum(Dis);

Start_Theta = Start.Theta;
Start_ShiftX = Start.ShiftX;
Start_ShiftY = Start.ShiftY;
Start_ShiftZ = Start.ShiftZ;

Theta = zeros(NChain,1);
Ax = zeros(NChain,1);
DelX = zeros(NChain,1);
DelY = zeros(NChain,1);
DelZ = zeros(NChain,1);
Cost = zeros(NChain,1);

Theta(1) = Start_Theta;
Ax(1) = 0;
DelX(1) = Start_ShiftX;
DelY(1) = Start_ShiftY;
DelZ(1) = Start_ShiftZ;
Cost(1) = Cost_Current;

%Ploting template and data
if PlotFlag
    %making video
    if VideoFlag
        V = VideoWriter('Video.avi');
        V.FrameRate = 3;
        open(V)
    end
     figure(110);
     plot3(TempX,TempY,TempZ,'ok','linewidth',1.25)
     hold;
     plot3(Points(:,1),Points(:,2),Points(:,3),'.')
     xlim(XLim);ylim(YLim)
     legend('proposal: 1')
     xlim([-120 120]);ylim([-120 120]);zlim([-120 120])
     %xlim([-40 40]);ylim([-40 40]);zlim([-40 40])
     hold off
     if VideoFlag
        F=getframe(gcf);
        writeVideo(V,F);
     end
end

%In each iteration of the for-loop random shifts and rotations are proposed 
%of the cost/error decreases the proposed values are accepted.
for nn = 2:NChain
    
    %propose shifts and a rotation angle
%     if nn < NChain/2
%         Theta_P = Theta(nn-1)+0.3*randn();
%         DelX_P = DelX(nn-1) + 0.5*randn();
%         DelY_P = DelY(nn-1) + 0.5*randn();
%         DelZ_P = DelZ(nn-1) + 0.5*randn();
%     else
%         Theta_P = Theta(nn-1)+0.1*randn();
%         DelX_P = DelX(nn-1) + 0.02*randn();
%         DelY_P = DelY(nn-1) + 0.02*randn();
%         DelZ_P = DelZ(nn-1) + 0.02*randn();
%     end
    
    Theta_P = Theta(nn-1)+0.13*randn();
        DelX_P = DelX(nn-1) + 0.2*randn();
        DelY_P = DelY(nn-1) + 0.2*randn();
        DelZ_P = DelZ(nn-1) + 0.2*randn();

    %propose a rotation
    Points = [X,Y,Z];
    AXtmp = randi(5);
    if AXtmp == 1
        %rotation with respect to x-axis
        Rx = [1,0,0; 0,cos(Theta_P),-sin(Theta_P); 0,sin(Theta_P),cos(Theta_P)];
        Points = (Rx*Points')';
    elseif AXtmp == 2
        %rotation with respect to y-axis
        Ry = [cos(Theta_P),0,sin(Theta_P); 0,1,0; -sin(Theta_P),0,cos(Theta_P)];
        Points = (Ry*Points')';
    elseif AXtmp == 3
        %rotation with respect to z-axis
        Rz = [cos(Theta_P),-sin(Theta_P),0; sin(Theta_P),cos(Theta_P),0; 0,0,1];
        Points = (Rz*Points')';
    elseif AXtmp == 4
        %rotation with respect to a random axis
        u = randn(1,3);
        u = u/sqrt(sum(u.^2));
        R_arb = [cos(Theta_P)+u(1)^2*(1-cos(Theta_P)), u(1)*u(2)*(1-cos(Theta_P))-u(3)*sin(Theta_P), u(1)*u(3)*(1-cos(Theta_P))+u(2)*sin(Theta_P);
                 u(1)*u(2)*(1-cos(Theta_P))+u(3)*sin(Theta_P), cos(Theta_P)+u(2)^2*(1-cos(Theta_P)), u(2)*u(3)*(1-cos(Theta_P))-u(1)*sin(Theta_P);
                 u(1)*u(3)*(1-cos(Theta_P))-u(2)*sin(Theta_P), u(2)*u(3)*(1-cos(Theta_P))+u(1)*sin(Theta_P), cos(Theta_P)+u(3)^2*(1-cos(Theta_P))];
        Points = (R_arb*Points')';
    else
        DelX_P = DelX(nn-1);
        DelY_P = DelY(nn-1);
        DelZ_P = DelZ(nn-1) + 2*randn();
    end
    
    %implementing shifts
    Points(1,:) = Points(1,:)+DelX_P;
    Points(2,:) = Points(2,:)+DelY_P;
    Points(3,:) = Points(3,:)+DelZ_P;

    %calculating error/cost
    [~,Dis]=knnsearch([TempX,TempY,TempZ],Points);
    Dis = abs(Dis);
    Dis(Dis>Penalty) = Penalty;
    Cost_Proposed = sum(Dis);
    Cost(nn) = Cost_Proposed;

    if Cost_Current - Cost_Proposed > -rand()
        if PlotFlag
            figure(110);
            plot3(TempX,TempY,TempZ,'ok','linewidth',1.25)
            hold;
            plot3(Points(:,1),Points(:,2),Points(:,3),'.')
            title(sprintf('Step:%g',nn))
            %xlim(XLim);ylim(YLim)
            SP = sprintf('proposal: %g',nn);
            legend(SP)
            xlim([-120 120]);ylim([-120 120]);zlim([-120 120])
            hold off
            pause(0.5)
            if VideoFlag
                F = getframe(gcf);
                writeVideo(V,F);
            end
        end
        Theta(nn) = Theta_P;
        Ax(nn) = AXtmp;
        DelX(nn) = DelX_P;
        DelY(nn) = DelY_P;
        DelZ(nn) = DelZ_P;
        Aligned.X = Points(:,1);
        Aligned.Y = Points(:,2); 
        Aligned.Z = Points(:,3);
        Cost_Current = Cost_Proposed;
        Aligned.Error = Cost_Current;
        
    else
        Theta(nn) = Theta(nn-1);
        Ax(nn) = Ax(nn-1);
        DelX(nn) = DelX(nn-1);
        DelY(nn) = DelY(nn-1);
        DelZ(nn) = DelZ(nn-1);
    end
    
end

if VideoFlag
    close(V)
end

Chain.Theta = Theta;
Chain.Ax = Ax;
Chain.XShift = DelX;
Chain.YShift = DelY;
Chain.ZShift = DelZ;
Chain.Error = Cost;

end
