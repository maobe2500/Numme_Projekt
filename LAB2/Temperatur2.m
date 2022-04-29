clear all
clc
format long
Ex = 200;
Ey = 10;

q0 = 3000;
q1 = 200;



NVec = [40, 80, 160, 320, 640, 1280, 2560, 5120];

% Ez = |Zexp_x - Zt| + |Zexp_y - Zt|
for i = 1:length(NVec)
    Zt = stav(NVec(i), q0, q1);
    Zexp1 = stav(NVec(i), q0 + Ex, q1);
    Zexp2 = stav(NVec(i), q0, q1 + Ey);
    Ez(i) = abs(Zexp1 - Zt) + abs(Zexp2 - Zt);
    display("N: " + NVec(i) + ", Uncertainty: " + Ez(i));
end


 

