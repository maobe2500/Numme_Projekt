clear all
clc

y0 = 0.5;
y0_prim = 0;
u0 = [y0, y0_prim];
t0 = 0;
tf = 5;
tspan = [t0 tf];



[tVec, yVec] = ode45(@(t, y) myode(y), tspan, u0);

plot(tVec, yVec(:,1))
hold on 
plot(tVec, yVec(:,2))

%% Functions

function [y_prim] = myode(y)
    L = 1.5;
    m = 0.6;
    g = 9.81;
    mu = 0.2;
    y1 = y(1);
    y2 = y(2);
    y_prim = [y2 ; - (mu/m)*y2 - (g/L)*sin(y1)];
end