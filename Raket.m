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

%H = 6;
h = 0.01;
T = 5;
format long;
for i = 1:10
    H = i;
    [tVec, rVec, rPrimeVec, phiVec, phiPrimVec, status] = RK4(H, T);
    disp(' ')
    plot(tVec, rVec);
    hold on
    disp(' ')
    disp(status)
    disp(' ')
    fprintf('Distance at start: %f earth radii', H+1)
    disp(' ')
end
y1 = ones(length(tVec), 1);
plot(tVec, y1) 


%% c) Beräkna tidpunkt och position för banans lägsta punkt
clear all;
clc;

T = 5;
H = 3.426016;
H = 4;

[f, x, y, tSpan, rPrimeSpan] = secant(10, H, T);
disp('Minimum is: ')
disp(y)
plot(tSpan, rPrimeSpan) 
hold on
for i = 1:length(tSpan)
    fitted(i) = f(tSpan(i));
end
plot(tSpan, fitted)




% H = 3.426016; ger iaf minsta avstånd = 1.000000...?
%{
[tMin, phiMin, rMin] = lowest_point(H, T);
fprintf('Distance at start: %f e.r.\n', H+1)
fprintf('Shortest distance: %f e.r.\n', rMin)
fprintf('At angle: %f rad.\n', phiMin)
fprintf('At time: %f h\n', tMin)
[rVec,x,x,x,x] = RK4(H, T)
x = interp1()
%}

%% d) Hitta gränsfall, bestämma hastighet v0 och rita bankurva.
clear all
clc
% rMin = 1
% f(H) = rMin
% ==> f(H) - rMin = 0

% Plotta HVec och rMinVec - avläsa H där rMin = 1.
% ex. Vi vet: H=3 ger "crash" och H=4 ger "escape".
% ==> H = 3:noggrannhet:4;
% iterativ funktion som tar in värden på H och beräknar rMin

% ngt ==> 100 datapunkter {interpolation!} ==> 10^7 datapunkter ==> mer exakt värde på H / rMin
% ngt ==> 100 datapunkter {interpolation!} ==> koefficienter, med nogrannhet 10^-7 ==> polynom f(x) ==> sätt f(x) = 1 ==> sekantmetoden g(x) = f(x) - 1 = 0 (hitta nollställen), med nogrannhet 10^-14

T=5;
H3 = 3;     % definitiv krash
H4 = 4;     % definitiv undflykt
h = 0.001;
% Dvs H-värdet måste ligga mellan H3 och H4
spanSize = 10
% Generera HVec och rMinVec
HVec = H3:h:H4;
for i = 1:length(HVec)
    H = HVec(i);
    [f, x, y, tSpan, rPrimeSpan] = secant(spanSize, H, T);
    rMinVec(i) = y;
end
plot(HVec, rMinVec)


%% Functions

function [f, x, y, tSpan, rPrimeSpan] = secant(spanSize, H, T)
    [tVec, rVec, rPrimeVec, phiVec, phiPrimVec, status, LPI] = RK4(H, T, spanSize);
    rPrimeSpan = rPrimeVec(LPI-spanSize*2:length(rVec));
    tSpan = tVec(LPI-spanSize*2:length(tVec));
    c = polyfit(tSpan, rPrimeSpan, 3);
    f = @(x) c(1)*x^3 + c(2)*x^2 + c(3)*x + c(4);
    n = 2;

    % Startgissningar
    x0 = tVec(LPI-1);
    x1 = tVec(LPI+1);
    y0 = f(x0);
    y1 = f(x1);
    for i = 1:n
        x = x1 - (x1 - x0)*y1 / (y1 - y0);
        y = f(x);
        x0 = x1;
        x1 = x;
        y0 = y1;
        y1 = y;
    end
end

function [tVec, rVec, rPrimeVec, phiVec, phiPrimVec, status, LPI] = RK4(H, T, spanSize)
    g = 20;
    F = g/(1+H)^2;
    a = 90;
    status = 'Died';
    counter = 0;

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

        % Vi stoppar när vi nått rätt värde
        % Hastigheten är i negativ rikting därav ">"

        speed = yMtrx(i+1, 2);
        height = yMtrx(i+1, 1);
        if speed > 0 || i+1 == length(tVec)
            LPI = i+1;                        % LPI - lowest point index (need for parabola fitting)
            counter = counter + 1;
            if height > 1
                status = 'Survived';
            end
            if counter == spanSize
                tVec = tVec(1:i+1);
                break
            end
        end
    end
    rVec = yMtrx(:, 1);
    rPrimeVec = yMtrx(:, 2);
    phiVec = yMtrx(:, 3);
    phiPrimVec = yMtrx(:, 4);
end

