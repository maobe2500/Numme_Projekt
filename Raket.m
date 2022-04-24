
%% Funktioner, konstanter, begynnelsevärden, 
%{
KONSTANTER
g = 20 jr/h^2       - tyngsaccelerationen vid jordytan
H = 2 jr
T = ??              - sluttid


FUNKTIONER
r(t) - avståndet från jordens mitt
phi(t) - vinkeln från startpunkten
F = g/(1+H)^2 - Gravitationskraften

r'' - r*(phi')**2 = F*cos(a) - g/r**2
r''  = F*cos(a) - g/r**2 + r*(phi')**2

r*phi'' + 2*r'*phi' = F*sin(a)
phi''= v' = (F*sin(a) - 2*r'*phi')/r

Omskrivning:
r = u1          phi = v1
r' = u2         phi' = v2
r'' = u2'       phi'' = v3

u3 = F*cos(a) - g/u1**2 + u1*(v2)**2
v3 = (F*sin(a) - 2*u2*v2)/u1

y_prim = @(y1, y2) [y2; - (mu/m)*y2 - (g/L)*sin(y1)];

BEGYNNELSEVÄRDEN
t = 0
r = H+1         phi = 0
r' = 0          phi' = 0
a = 90

%}


%% a) Omskrivning av ODE till system av första ordningen
% Se omskrivning ovan


%% b) RK4 program som löser ODE
H = 4;
h = 0.01;
T = 10;

%{
y1 = phi
y2 = phi_prim
y1_prim = y2
y2_prim = - (u/m)*y2 - (g/L)*sin(y1)
%}
[tVec, yMtrx, a] = RK4(H, h, T);
distVec = yMtrx(:, 1);
numColsVec = yMtrx(1,:);
display(numColsVec)
i = 1
while true
    dist = distVec(i);
    angle = a(i);
    if angle == 0 || i == length(distVec) - 1 || dist <= 1
        if dist <= 1
            display('CRASHED') 
            break
        else
            display('ESCAPED')
            break
        end
    end
    i = i + 1;
end
display('Dist: ' + dist)

%% Functions
function [tVec, yMtrx, a] = RK4(H, h, T)
    g = 20;
    F_0 = g/(1+H)^2;
    F = F_0;
    a_0 = 90;
    a(1) = a_0;

    u1 = H+1; u2 = 0;
    v1 = 0; v2 = 0;

    t0 = 0;
    n = (T-t0)/h; 
    tVec = t0:h:T;

    
    yMtrx = [u1, u2, v1, v2]; % Dvs första index i yMtrx innehåller begynnelsevärdena

    y_prim = @(u1, u2, v1, v2, a, F) [u2  ;  F*cos(a) - g/u1^2 + u1*(v2)^2  ;  v2  ;  (F*sin(a) - 2*u2*v2)/u1];


    for i = 1:n
        y1 = yMtrx(i, 1);
        y2 = yMtrx(i, 2);
        y3 = yMtrx(i, 3);
        y4 = yMtrx(i, 4);

        f1 = y_prim(y1, y2, y3, y4, a(i) , F);
        f2 = y_prim(y1 + h/2*f1(1), y2 + h/2*f1(2), y3 + h/2*f1(3), y4 + h/2*f1(4), a(i) , F);
        f3 = y_prim(y1 + h/2*f2(1), y2 + h/2*f2(2), y3 + h/2*f2(3), y4 + h/2*f2(4), a(i) , F);
        f4 = y_prim(y1 + h*f3(1), y2 + h*f3(2), y3 + h*f3(3), y4 + h*f3(4), a(i) , F);

        yMtrx(i+1, 1) = y1 + h/6*(f1(1) + 2*f2(1) + 2*f3(1) + f4(1));       % r(t)
        yMtrx(i+1, 2) = y2 + h/6*(f1(2) + 2*f2(2) + 2*f3(2) + f4(2));       % r'(t)
        yMtrx(i+1, 3) = y3 + h/6*(f1(3) + 2*f2(3) + 2*f3(3) + f4(3));       % phi(t)
        yMtrx(i+1, 4) = y4 + h/6*(f1(4) + 2*f2(4) + 2*f3(4) + f4(4));       % phi'(t)

        phi = yMtrx(i+1, 3);
        r = yMtrx(i+1, 1);

        a(i+1) = a(i) - phi;
        F = g/r^2;
    end
end
