clear all
clc

%{
y1 = phi
y2 = phi_prim
y1_prim = y2
y2_prim = - (u/m)*y2 - (g/L)*sin(y1)
%}

%% d) Write Euler.m to solve the ODE-system from a)

% Initial values for y

   
u0 = [0.5, 0];
T = 5;
h = 0.01;
format long

[tVec, yVec] = RK4(u0, h, T);


plot(tVec, yVec(:,1))
hold on 
plot(tVec, yVec(:,2))

%% e) Order of accuracy

hVec = [0.1 0.01 0.001 0.0001 0.00001];
for i = 1:length(hVec)
    h = hVec(i);
    [Kvot(i), p(i)] = Nogrannhet(u0, h, T);
end
p = p';
Kvot = Kvot';
results = table(Kvot, p)





%% Functions

function [Kvot, p] = Nogrannhet(u0, h, T)
    Mh = phi(5, u0, h, T);
    Mh_half = phi(5, u0, h/2, T);
    Mh_quarter = phi(5, u0, h/4, T);
    Kvot = (Mh - Mh_half)/(Mh_half - Mh_quarter);
    p = log(Kvot)/log(2); 
end


function [value] = phi(t, u0, h, T)
    [tVec, yVec] = RK4(u0, h, T);
    phiVec = yVec(:,1);
    value = phiVec(end);
end

