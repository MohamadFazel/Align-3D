
Theta = linspace(0,2*pi,9);
Theta(end) = [];
R = 104*ones(1,8);

[X1,Y1] = pol2cart(Theta,R/2);
[X2,Y2] = pol2cart(Theta+0.0905*2,R/2+6.5);
[X3,Y3] = pol2cart(Theta+0.12*2,R/2);
[X4,Y4] = pol2cart(Theta+0.035*2,R/2+6.5);

Temp.X = [X1,X2,X3,X4];
Temp.Y = [Y1,Y2,Y3,Y4];
Temp.Z = [25*ones(1,16),-25*ones(1,16)];
ID = Temp.Z > 0;
figure;plot3(Temp.X(ID),Temp.Y(ID),Temp.Z(ID),'o')
hold;plot3(Temp.X(~ID),Temp.Y(~ID),Temp.Z(~ID),'o')
