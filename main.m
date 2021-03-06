clear all
clc

%% Funktioner, konstanter, begynnelsevärden
%{
    KONSTANTER
    g = 20
    a = 90
    F = g/(1+H)^2

    FUNKTIONER
    r(t) - avståndet från jordens mitt
    phi(t) - vinkeln från startpunkten
%}

%% a) Omskrivning av ODE till system av första ordningen 
%{
    Omskrivning:
    r = u1          phi = v1
    r' = u2         phi' = v2
    r'' = u3       phi'' = v3

    u3 - u1*v2^2 = F*cos(a) - g/u1^2
    u1*v3 + 2*u2*v2 = F*sin(a)

    u3 = F*cos(a) - g/u1^2 + u1*(v2)^2
    v3 = (F*sin(a) - 2*u2*v2)/u1
%}


%---------------------------------------------------------------------------------------------------------------------------------------------%
%% b) RK4 program som löser ODE
clear all
clc
%{
    BEGYNNELSEVÄRDEN
    t = 0
    r = H+1         phi = 0
    r' = 0          phi' = 0
%}

% Test av olika starthöjder H mellan 1 och 10 (plottade)
a = 90;
T = 2;
h = 0.001

format long;
HVec = 1:0.2:2;
for i = 1:length(HVec)
    H = HVec(i);
    [tVec, rVec, ~, ~, ~] = RK4(H, T, a, h);
    plot(tVec, rVec);
    hold on
    fprintf('Distance at start: %f earth radii \n', H+1)
end
yline(1)
legend("H = 1.0", "H = 1.2", "H = 1.4", "H = 1.6", "H = 1.8", "H = 2.0")
title("Flightpath with Earth's Surface at y = 1")
ylabel("Distance from earth [e.r.]")
xlabel("Time since start [h]")


%---------------------------------------------------------------------------------------------------------------------------------------------%
%% c) Beräkna tidpunkt och position för banans lägsta punkt
clear all
clc

a = 90;
T = 5;
H = 2;
h = 0.001;

% Skriver ut positionsangivelsen för lägsta punkten under flygturen. 
[tMin, rMin, phiMin] = Minimum(H, h, T)

disp(" (t_p, r_p, phi_p) = (" + tMin + ", " + rMin + ", " + phiMin + ")")


%{
index = 1;
for i = 0.01:0.01:10
    [tVec, rVec, ~, phiVec, ~] = RK4(i, T, a);
    [~, LPI] = min(rVec);
    phitest(index) = phiVec(LPI);
    index = index + 1;
end
x =  0.01:0.01:10;
plot(x, phitest)
%}

%---------------------------------------------------------------------------------------------------------------------------------------------%
%% d) Hitta gränsfall, bestämma hastighet v0 och rita bankurva.
%% e) Beräkna färdbanans längd.
clear all;
clc;

% H-värdet måste ligga mellan H3 och H4
HCrash = 1;     % definitiv krash
HEscape = 2;     % definitiv undflykt

a = 90;
T = 5;
h = 10^-2;      % Steglängd mellan H3 och H4.

% Generera HVec och rMinVec
HVec = HCrash:h:HEscape;
rMinVec = ones(1, length(HVec));
for i = 1:length(HVec)
    H = HVec(i);
    [tMin, rMin, ~] = Minimum(H, h, T);
    rMinVec(i) = rMin;
end


% plot(HVec, rMinVec)



% Ger rät linje ==> y = kx + m
% Ser att det är då H är mellan 3.4 och 3.5

% Beräkna k
H1 = HVec(end);
H0 = HVec(1);
rMin1 = rMinVec(end);
rMin0 = rMinVec(1);
k = (rMin1 - rMin0)/(H1 - H0);
disp("  k: " + k)

% Beräkna m
y = rMin0;
x = H0;
m = y - k*x;
disp("  m: " + m)

% Omskrivning av räta linjens ekvation för att räkna baklänges.
% Vi söker H (d.v.s. x) då y (rMin) är 1.
% y = kx+m  ==>  x = (y-m)/k
x = @(y) (y - m)/k;

H_precise = x(1);
disp("  H*: " + H_precise)

a = 90;
% Hastigheten v0 raketen sveper förbi jordytan med.
[tVec, rVec, rPrimeVec, phiVec, phiPrimeVec] = RK4(H_precise, T, a, h);
[~, LPI] = min(rVec);
phiPrimeMin = phiPrimeVec(LPI);         % Gör noggrannare??
tMin = tVec(LPI);
rMin = rVec(LPI);
% plot(tVec, rPrimeVec)

EARTH_CIRCUMF = 4*10^4;                 % (km)
v0 = phiPrimeMin * EARTH_CIRCUMF/(2*pi*3.6);        

disp("Lowest point for H* is at:")
disp("  time t: " + tMin)
disp("  velocity v0: " + v0)

% Ritar ut färdbanan då raketen precis sveper över trädtopparna
% Bara fram till lägsta punkten?? Se uppgiftsbeskrivning
plot(tVec(1:LPI), rVec(1:LPI))
yline(1)
legend("H*")
title("Flightpath for exact escape")
ylabel("Minimum distance form earth's center [e.r.]")
xlabel('Start height H [e.r.]')

% hold on
% plot(tMin, rMin, 'rO')        % markering för lägsta punkten
format long;
L = 0;
for i = 1:LPI
    dr = rVec(i+1)-rVec(i);
    dt = tVec(i+1)-tVec(i);
    L = L + sqrt(1 + (dr/dt)^2)*dt;
end
disp("  Arc length L: " + L + " e.r.")



%% f) Störningsanalys
a = 90;
aErrs = [2, -2];
HSum = 0; v0Sum = 0; LSum = 0;
h = 0.001;
for i = 1:length(aErrs)
    [H, v0_, L_] = ErrRaket(a+aErrs(i), h);
    HSum = HSum + abs(H);
    v0Sum = v0Sum + abs(v0_);
    LSum = LSum + abs(L_);
end

EH = abs(HSum/2 - H_precise);
Ev0 = abs(v0Sum/2 - v0);
EL = abs(LSum/2 - L);

disp("Error in H*: " + EH)
disp("Error in v0: " + Ev0)
disp("Error in L: " + EL)


%% Tillförlitlighetsbedömning
a = 90;

h = 10^-2;
h_2 = h/2;
h_4 = h/4;
h_8 = h/8;
hVec = [h h_2 h_4 h_8];

ansMtrx = [];
for i = 1:length(hVec)
    h = hVec(i);
    [H_precise, v0, L, tMin, rMin, phiMin] = ErrRaket(a, h);
    ansMtrx(i, 1:6) = [H_precise, v0, L, tMin, rMin, phiMin];
end

disp(ansMtrx)


Acc_H_pre = Noggrannhet(ansMtrx(1,1), ansMtrx(2,1), ansMtrx(3,1))
Acc_v0 = Noggrannhet(ansMtrx(1,2), ansMtrx(2,2), ansMtrx(3,2))
Acc_L = Noggrannhet(ansMtrx(1,3), ansMtrx(2,3), ansMtrx(3,3))
Acc_tMin = Noggrannhet(ansMtrx(1,4), ansMtrx(2,4), ansMtrx(3,4))
Acc_rMin = Noggrannhet(ansMtrx(1,5), ansMtrx(2,5), ansMtrx(3,5))
Acc_phiMin = Noggrannhet(ansMtrx(1,6), ansMtrx(2,6), ansMtrx(3,6))


%% Uppskatta felet i de numeriska svaren.
function [Kvot, p] = Noggrannhet(Mh, Mh_half, Mh_quarter)
    Kvot = (Mh - Mh_half)/(Mh_half - Mh_quarter);
    p = log(Kvot)/log(2); 
end

function [tMin, rMin, phiMin] = Minimum(H, h, T)
    h = 1e-3;
    a = 90;
    [tVec, rVec, ~, phiVec, ~] = RK4(H, T, a, h);
    [~, LPI] = min(rVec);
    [tMin, rMin] = secant(LPI, tVec, rVec);
    phiMin = phiVec(LPI);
end
