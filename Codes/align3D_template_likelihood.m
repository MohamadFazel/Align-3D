function [Aligned,Chain] = align3D_template_likelihood(Temp,Input,Start,Penalty,NChain,PlotFlag,VideoFlag)
%align3D_template Aligns a set of points to a template.
% [Aligned,Chain] = align3D_template(Temp,Input,Start,Penalty,NChain,PlotFlag,VideoFlag)
%
% This version replaces nearest-neighbor distance scoring with a robust
% mixture likelihood:
%   p(y_i) = sum_j exp(-||R*y_i + t - x_j||^2/(2*sigma^2)) + beta
% and minimizes the average negative log-likelihood using a Monte Carlo
% rigid-registration search.
%
% INPUTS:
%   Temp:       SMD Structure of the template with fields X,Y,Z
%   Input:      SMD Structure of the sample with fields X,Y,Z
%   Start:      Structure of starting values for shift and rotation
%               Required fields (same as original): Theta, ShiftX, ShiftY, ShiftZ
%               Optional fields: Ax (1=x, 2=y, 3=z, 4=random axis), R (3x3)
%   Penalty:    Distance scale (nm) used here as the Gaussian width sigma.
%   NChain:     Number of Monte Carlo steps (Default = 5000)
%   PlotFlag:   0 or 1, Show an animation of the accepted jumps (Default = 0)
%   VideoFlag:  0 or 1, Make a video if PlotFlag is 1 (Default = 0)
%
% OUTPUTS:
%   Aligned:    Structure containing the aligned coordinates
%       X,Y,Z:  transformed sample coordinates
%       Error:  average negative log-likelihood per point
%   Chain:      Accepted Monte Carlo states
%       Theta:  proposed incremental rotation angle (rad)
%       Ax:     axis code of the proposal
%       XShift: translation in X (nm)
%       YShift: translation in Y (nm)
%       ZShift: translation in Z (nm)
%       Error:  average negative log-likelihood per point
%       R:      accepted rotation matrix at each step
%
% Created by:
%   Mohamadreza Fazel (LidkeLab 2019)
%   Modified to use likelihood-based many-to-one registration.

if nargin < 4
   error('There must be at leat 4 inputs.')
end

if nargin < 5 || isempty(NChain)
   NChain = 5000;
end
if nargin < 6 || isempty(PlotFlag)
   PlotFlag = 0;
end
if nargin < 7 || isempty(VideoFlag)
   VideoFlag = 0;
end

if VideoFlag == 1 && PlotFlag == 0
    error('to make a video PlotFlag must be 1 as well')
end

Aligned.X = [];
Aligned.Y = [];
Aligned.Z = [];
Aligned.Error = [];

% -------------------------------------------------------------------------
% Center template and data
% -------------------------------------------------------------------------
if size(Temp.X,1) == 1
    TempX = Temp.X' - mean(Temp.X);
    TempY = Temp.Y' - mean(Temp.Y);
    TempZ = Temp.Z' - mean(Temp.Z);
else
    TempX = Temp.X - mean(Temp.X);
    TempY = Temp.Y - mean(Temp.Y);
    TempZ = Temp.Z - mean(Temp.Z);
end
TempXYZ = [TempX, TempY, TempZ];

XLim = [min(TempX)-10 max(TempX)+10];
YLim = [min(TempY)-10 max(TempY)+10];
ZLim = [min(TempZ)-10 max(TempZ)+10];

if size(Input.X,1) == 1
    X = Input.X';
    Y = Input.Y';
    Z = Input.Z';
else
    X = Input.X;
    Y = Input.Y;
    Z = Input.Z;
end

% Move data center to the origin, as in the original code.
X = X - mean(X);
Y = Y - mean(Y);
Z = Z - mean(Z);
Data0 = [X, Y, Z];

% -------------------------------------------------------------------------
% Likelihood model parameters
% -------------------------------------------------------------------------
sigma = max(Penalty, eps);     % Gaussian width for template match likelihood
betaOutlier = 1e-3;            % background/outlier likelihood floor
stepTheta = 0.13;              % proposal width for rotation angle
stepShift = 0.20;              % proposal width for translation updates
acceptTemp = 1.0;              % Metropolis temperature on average NLL

% -------------------------------------------------------------------------
% Initialize transform
% -------------------------------------------------------------------------
Start_Theta  = Start.Theta;
Start_ShiftX = Start.ShiftX;
Start_ShiftY = Start.ShiftY;
Start_ShiftZ = Start.ShiftZ;

if isfield(Start,'R') && ~isempty(Start.R)
    R_Current = Start.R;
elseif isfield(Start,'Ax') && ~isempty(Start.Ax)
    R_Current = axisAngleToMatrix(Start.Ax, Start_Theta);
else
    % Backward-compatible default: start rotation about z-axis.
    R_Current = axisAngleToMatrix(3, Start_Theta);
end

t_Current = [Start_ShiftX, Start_ShiftY, Start_ShiftZ];
Points_Current = transformPoints(Data0, R_Current, t_Current);
Cost_Current = negativeLogLikelihood(Points_Current, TempXYZ, sigma, betaOutlier);

Theta = zeros(NChain,1);
Ax = zeros(NChain,1);
DelX = zeros(NChain,1);
DelY = zeros(NChain,1);
DelZ = zeros(NChain,1);
Cost = zeros(NChain,1);
Rchain = zeros(3,3,NChain);

Theta(1) = Start_Theta;
Ax(1) = 0;
DelX(1) = t_Current(1);
DelY(1) = t_Current(2);
DelZ(1) = t_Current(3);
Cost(1) = Cost_Current;
Rchain(:,:,1) = R_Current;

Aligned.X = Points_Current(:,1);
Aligned.Y = Points_Current(:,2);
Aligned.Z = Points_Current(:,3);
Aligned.Error = Cost_Current;

% -------------------------------------------------------------------------
% Plot initial state
% -------------------------------------------------------------------------
if PlotFlag
    if VideoFlag
        V = VideoWriter('Video.avi');
        V.FrameRate = 3;
        open(V)
    end
    figure(110);
    plot3(TempX,TempY,TempZ,'ok','linewidth',1.25)
    hold on;
    plot3(Points_Current(:,1),Points_Current(:,2),Points_Current(:,3),'.')
    xlim(XLim); ylim(YLim); zlim(ZLim)
    legend('proposal: 1')
    title('Step: 1')
    hold off
    if VideoFlag
        F = getframe(gcf);
        writeVideo(V,F);
    end
end

% -------------------------------------------------------------------------
% Monte Carlo search
% -------------------------------------------------------------------------
for nn = 2:NChain

    % Propose incremental rigid motion.
    Theta_P = stepTheta * randn();
    AXtmp = randi(4); % 1=x, 2=y, 3=z, 4=random axis
    R_Delta = axisAngleToMatrix(AXtmp, Theta_P);
    R_Prop = R_Delta * R_Current;

    t_Prop = t_Current + stepShift * randn(1,3);
    Points_Prop = transformPoints(Data0, R_Prop, t_Prop);

    Cost_Prop = negativeLogLikelihood(Points_Prop, TempXYZ, sigma, betaOutlier);
    Cost(nn) = Cost_Prop;

    DeltaCost = Cost_Prop - Cost_Current;
    if DeltaCost <= 0 || rand() < exp(-DeltaCost / acceptTemp)
        Theta(nn) = Theta_P;
        Ax(nn) = AXtmp;
        DelX(nn) = t_Prop(1);
        DelY(nn) = t_Prop(2);
        DelZ(nn) = t_Prop(3);
        R_Current = R_Prop;
        t_Current = t_Prop;
        Points_Current = Points_Prop;
        Cost_Current = Cost_Prop;
        Rchain(:,:,nn) = R_Current;
        Aligned.X = Points_Current(:,1);
        Aligned.Y = Points_Current(:,2);
        Aligned.Z = Points_Current(:,3);
        Aligned.Error = Cost_Current;

        if PlotFlag
            figure(110);
            plot3(TempX,TempY,TempZ,'ok','linewidth',1.25)
            hold on;
            plot3(Points_Current(:,1),Points_Current(:,2),Points_Current(:,3),'.')
            title(sprintf('Step:%g',nn))
            SP = sprintf('proposal: %g',nn);
            legend(SP)
            xlim(XLim); ylim(YLim); zlim(ZLim)
            hold off
            drawnow
            pause(0.1)
            if VideoFlag
                F = getframe(gcf);
                writeVideo(V,F);
            end
        end
    else
        Theta(nn) = Theta(nn-1);
        Ax(nn) = Ax(nn-1);
        DelX(nn) = DelX(nn-1);
        DelY(nn) = DelY(nn-1);
        DelZ(nn) = DelZ(nn-1);
        Rchain(:,:,nn) = R_Current;
    end
end

if PlotFlag && VideoFlag
    close(V)
end

Chain.Theta = Theta;
Chain.Ax = Ax;
Chain.XShift = DelX;
Chain.YShift = DelY;
Chain.ZShift = DelZ;
Chain.Error = Cost;
Chain.R = Rchain;

end

% ========================================================================
% Helper functions
% ========================================================================
function Points = transformPoints(Data0, R, t)
Points = (R * Data0')';
Points = Points + t;
end

function Cost = negativeLogLikelihood(Points, TempXYZ, sigma, betaOutlier)
% Average negative log-likelihood per data point:
%   -mean_i log( sum_j exp(-||p_i-x_j||^2/(2*sigma^2)) + betaOutlier )

    N = size(Points,1);
    if N == 0
        Cost = inf;
        return;
    end
    
    % Manual pairwise squared distances (no toolbox needed).
    sP = sum(Points.^2, 2);            % N x 1
    sT = sum(TempXYZ.^2, 2)';          % 1 x M
    D2 = bsxfun(@plus, sP, sT) - 2*(Points * TempXYZ');
    D2 = max(D2, 0);
    
    A = -D2 ./ (2*sigma^2);
    c = log(max(betaOutlier, realmin));
    Amax = max(max(A, [], 2), c);
    logp = Amax + log(sum(exp(bsxfun(@minus, A, Amax)), 2) + exp(c - Amax));
    
    Cost = -mean(logp);
end

function R = axisAngleToMatrix(axisCode, theta)
% axisCode: 1=x, 2=y, 3=z, 4=random axis
    switch axisCode
        case 1
            R = [1,0,0; 0,cos(theta),-sin(theta); 0,sin(theta),cos(theta)];
        case 2
            R = [cos(theta),0,sin(theta); 0,1,0; -sin(theta),0,cos(theta)];
        case 3
            R = [cos(theta),-sin(theta),0; sin(theta),cos(theta),0; 0,0,1];
        case 4
            u = randn(1,3);
            u = u / sqrt(sum(u.^2));
            ct = cos(theta);
            st = sin(theta);
            R = [ct+u(1)^2*(1-ct),       u(1)*u(2)*(1-ct)-u(3)*st, u(1)*u(3)*(1-ct)+u(2)*st;
                 u(1)*u(2)*(1-ct)+u(3)*st, ct+u(2)^2*(1-ct),       u(2)*u(3)*(1-ct)-u(1)*st;
                 u(1)*u(3)*(1-ct)-u(2)*st, u(2)*u(3)*(1-ct)+u(1)*st, ct+u(3)^2*(1-ct)];
        otherwise
            error('axisCode must be 1, 2, 3, or 4.');
    end
end
