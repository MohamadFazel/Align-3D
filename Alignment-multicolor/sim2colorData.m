
%% generating templates 

Theta = linspace(0,2*pi,9);
Theta(end) = [];
R1 = 50*ones(1,8);
R2 = 35*ones(1,8);

[X1,Y1] = pol2cart(Theta,R1);
[X2,Y2] = pol2cart(Theta+pi/8,R2);
Z1 = 50*ones(1,8); 
Z2 = 40*ones(1,8);

figure;plot(X1,Y1,'*')
hold;plot(X2,Y2,'*')

Temp1.X = [X1,X1];
Temp1.Y = [Y1,Y1];
Temp1.Z = [Z1,-Z1];

Temp2.X = [X2,X2];
Temp2.Y = [Y2,Y2];
Temp2.Z = [Z2,-Z2];

figure;plot3(Temp1.X,Temp1.Y,Temp1.Z,'*')
hold;plot3(Temp2.X,Temp2.Y,Temp2.Z,'*')
xlabel('X[nm]');ylabel('Y[nm]');zlabel('Z[nm]')

%% generating localizations

Locs(100,2).X = [];
Locs(100,2).Y = [];
Locs(100,2).Z = [];
for ii = 1:100
    
    ID1 = ones(1,16);
    ID1(randperm(16,randi(5))) = 0;
    ID2 = ones(1,16);
    ID2(randperm(16,randi(12))) = 0;
    Points1 = [Temp1.X(ID1==1);Temp1.Y(ID1==1);Temp1.Z(ID1==1)];
    Points2 = [Temp2.X(ID2==1);Temp2.Y(ID2==1);Temp2.Z(ID2==1)];
    for nn = 1:4
        Axtmp = randi(3);
        Theta_P = pi*rand()/4;
        if Axtmp == 1
            Rx = [1,0,0; 0,cos(Theta_P),-sin(Theta_P); 0,sin(Theta_P),cos(Theta_P)];
            Points1 = (Rx*Points1);
            Points2 = (Rx*Points2);
        elseif Axtmp == 2
            Ry = [cos(Theta_P),0,sin(Theta_P); 0,1,0; -sin(Theta_P),0,cos(Theta_P)];
            Points1 = (Ry*Points1);
            Points2 = (Ry*Points2);
        elseif Axtmp == 3
            Rz = [cos(Theta_P),-sin(Theta_P),0; sin(Theta_P),cos(Theta_P),0; 0,0,1];
            Points1 = (Rz*Points1);
            Points2 = (Rz*Points2);
        end
        Xshift = 100*rand(); 
        Yshift = 100*rand(); 
        Zshift = 100*rand(); 
        Points1(1,:) = Points1(1,:) + Xshift;
        Points1(2,:) = Points1(2,:) + Yshift;
        Points1(3,:) = Points1(3,:) + Zshift;
        Points2(1,:) = Points2(1,:) + Xshift;
        Points2(2,:) = Points2(2,:) + Yshift;
        Points2(3,:) = Points2(3,:) + Zshift;
    end

    Locs(ii,1).X = Points1(1,:)'+5*rand(size(Points1(1,:)'));
    Locs(ii,1).Y = Points1(2,:)'+5*rand(size(Points1(1,:)'));
    Locs(ii,1).Z = Points1(3,:)'+5*rand(size(Points1(1,:)'));
    Locs(ii,2).X = Points2(1,:)'+5*rand(size(Points2(1,:)'));
    Locs(ii,2).Y = Points2(2,:)'+5*rand(size(Points2(1,:)'));
    Locs(ii,2).Z = Points2(3,:)'+5*rand(size(Points2(1,:)'));

end

figure;hold
for ii = 1:100
    plot(Locs(ii,1).X,Locs(ii,1).Y,'.k')
    plot(Locs(ii,2).X,Locs(ii,2).Y,'.r')
end

save('simLocs','Locs')
Temp = Temp1;
save('RefTemplate','Temp')
