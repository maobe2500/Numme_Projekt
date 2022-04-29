clear all
clc


%% a) Rewrite ODE to a system of order one. (Google docs??)
%{
y1 = phi
y2 = phi_prim
y1_prim = y2
y2_prim = - (u/m)*y2 - (g/L)*sin(y1)
%}

%% b) Write Euler.m to solve the ODE-system from a)

% Initial values for y

   
u0 = [0.5, 0];
T = 5;
h = 0.01;


[tVec, yVec] = feuler(u0, h, T);


plot(tVec, yVec(:,1))
hold on 
plot(tVec, yVec(:,2))

%% c) Order of accuracy

hVec = [0.1 0.01 0.001 0.0001];
for i = 1:length(hVec)
    h = hVec(i);
    Kvot(i) = Nogrannhet(u0, h, T);
    p(i) = log(Kvot(i))/log(2);
end
Kvot = Kvot';
p = p';
results = table(Kvot, p)




%% Functions

function [Kvot] = Nogrannhet(u0, h, T)
    Mh = phi(5, u0, h, T);
    Mh_half = phi(5, u0, h/2, T);
    Mh_quarter = phi(5, u0, h/4, T);
    Kvot = (Mh - Mh_half)/(Mh_half - Mh_quarter);
end


function [value] = phi(t, u0, h, T)
    [tVec, yVec] = feuler(u0, h, T);
    phiVec = yVec(:,1);
    value = phiVec(end);
end



