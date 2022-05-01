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
T = 4;
format long;
for i = 1:10
    H = i;
    [tVec, rVec, ~, ~, ~] = RK4(H, T);
    plot(tVec, rVec);
    hold on
    fprintf('Distance at start: %f earth radii \n', H+1)
end
yline(1)


%% c) Beräkna tidpunkt och position för banans lägsta punkt
clear all;
clc;

T = 5;
% H = 3.42600297724385;      Ger minsta höjd 1.00000...
H = 3.426;

% Skriver ut minimihöjden och plottar genererade värden mot polynomet (nästan identiska)
[tVec, rVec, ~, ~, ~] = RK4(H, T);
[~, LPI] = min(rVec);
[f, t, rMin, tSpan, rSpan] = secant(LPI, tVec, rVec);
disp('  rMin: ' + rMin)

% fitted är vektorn med höjderna (r) beräknat med f(t). 
fitted = ones(1, length(tSpan));
for i = 1:length(tSpan)
    t = tSpan(i);
    fitted(i) = f(t);
end

% Jämförelseplot mellan rSpan och fitted
plot(tSpan, rSpan)
hold on
plot(tSpan, fitted)


%% d) Hitta gränsfall, bestämma hastighet v0 och rita bankurva.
clear all;
clc;

% H-värdet måste ligga mellan H3 och H4
H3 = 3;     % definitiv krash
H4 = 4;     % definitiv undflykt

T = 5;
h = 10^-2;      % Steglängd mellan H3 och H4.

% Generera HVec och rMinVec
HVec = H3:h:H4;
rMinVec = ones(1, length(HVec));
for i = 1:length(HVec)
    H = HVec(i);
    [tVec, rVec, ~, ~, ~] = RK4(H, T);
    [~, LPI] = min(rVec);                                       % Returnerar index för den lägsta punkten under flygturen.
    [f, t, rMin, tSpan, ySpan] = secant(LPI, tVec, rVec);
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


% Hastigheten v0 raketen sveper förbi jordytan med.
[tVec, rVec, rPrimeVec, phiVec, phiPrimeVec] = RK4(H_precise, T);
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
% hold on
% plot(tMin, rMin, 'rO')        % markering för lägsta punkten

% phiPrime max 6.416286864014754 rad/h
% LPI = 2203
[~, phiLPI] = max(phiPrimeVec);
disp(phiLPI)
% Egetnligen uppnås högsta hastigheten för LPI = 2207
disp(rPrimeVec(2203))


%% Functions


function [f, t, y, tSpan, ySpan] = secant(LPI, tVec, yVec)
% Använder sekantmetoden för att bestämma mer exakta minsta värden för yVec.
    span = 10;      % interpolerar över 21 punkter närmast lägsta punkten
    ySpan = yVec(LPI-span:LPI+span);
    tSpan = tVec(LPI-span:LPI+span);
    c = polyfit(tSpan, ySpan, 2);
    f = @(t) c(1)*t^2 + c(2)*t + c(3);

    n = 3;          % sekantmetoden 3 iterationer.
    % Startgissningar
    t0 = tVec(LPI-1);       y0 = f(t0);
    t1 = tVec(LPI+1);       y1 = f(t1);
    
    for i = 1:n
        t = t1 - (t1 - t0)*y1 / (y1 - y0);
        y = f(t);

        t0 = t1;            y0 = y1;
        t1 = t;             y1 = y;
    end
end



function [tVec, rVec, rPrimeVec, phiVec, phiPrimVec] = RK4(H, T)
    g = 20;
    F = g/(1+H)^2;
    a = 90;

    u1 = H+1;
    u2 = 0;
    v1 = 0;
    v2 = 0;
    t0 = 0;
    h = 10^-3;
    n = (T-t0)/h; 
    tVec = t0:h:T;

    
    yMtrx = [u1, u2, v1, v2]; % Dvs första index i yMtrx innehåller begynnelsevärdena
    y_prim = @(u1, u2, v1, v2) [u2  ;  F*cos(a) - g/(u1^2) + u1*(v2)^2  ;  v2  ;  (F*sin(a) - 2*u2*v2)/u1];

    for i = 1:n
        u1 = yMtrx(i, 1);
        u2 = yMtrx(i, 2);
        v1 = yMtrx(i, 3);
        v2 = yMtrx(i, 4);

        f1 = y_prim(u1, u2, v1, v2);
        f2 = y_prim(u1 + h/2*f1(1), u2 + h/2*f1(2), v1 + h/2*f1(3), v2 + h/2*f1(4));         
        f3 = y_prim(u1 + h/2*f2(1), u2 + h/2*f2(2), v1 + h/2*f2(3), v2 + h/2*f2(4));
        f4 = y_prim(u1 + h*f3(1), u2 + h*f3(2), v1 + h*f3(3), v2 + h*f3(4));

        yMtrx(i+1, 1) = u1 + h/6*(f1(1) + 2*f2(1) + 2*f3(1) + f4(1));       % r(t)
        yMtrx(i+1, 2) = u2 + h/6*(f1(2) + 2*f2(2) + 2*f3(2) + f4(2));       % r'(t)
        yMtrx(i+1, 3) = v1 + h/6*(f1(3) + 2*f2(3) + 2*f3(3) + f4(3));       % phi(t)
        yMtrx(i+1, 4) = v2 + h/6*(f1(4) + 2*f2(4) + 2*f3(4) + f4(4));       % phi'(t) 

    end
    rVec = yMtrx(:, 1);
    rPrimeVec = yMtrx(:, 2);
    phiVec = yMtrx(:, 3);
    phiPrimVec = yMtrx(:, 4);
end

