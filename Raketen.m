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

%{
    BEGYNNELSEVÄRDEN
    t = 0
    r = H+1         phi = 0
    r' = 0          phi' = 0
%}
%{
H = 6;
h = 0.01;
T = 5;
format long;
for i = 1:10
    H = i;
    [status, tVecToEnd, distVecToEnd, iter] = run_simulation(H, h, T);
    plot(tVecToEnd, distVecToEnd);
    hold on
    disp(' ')
    disp(status)
    disp(' ')
    fprintf('Distance at start: %f earth radii', H+1)
    disp(' ')
 
end
%}

%% c) Beräkna tidpunkt och position för banans lägsta punkt

T = 5;
H = 3.426016;
% H = 3.426016; ger iaf minsta avstånd = 1.000000...?

[tMin, phiMin, rMin] = lowest_point(H, T);
fprintf('Distance at start: %f e.r.\n', H+1)
fprintf('Shortest distance: %f e.r.\n', rMin)
fprintf('At angle: %f rad.\n', phiMin)
fprintf('At time: %f h\n', tMin)

[tVec, yMtrx] = RK4(H, T);
rData = yMtrx(:, 1);
phiData = yMtrx(:, 2);

%[coeffVec] = MKV(tVec, rData);
c = polyfit(tVec, rData, 5)
f = @(x) c(4)*x^0 + c(3)*x^1 + c(2)*x^2 +c(1)*x^3% + c(2)*x^4 + c(1)*x^5 + 
for i = 1:length(tVec)
    y(i) = f(tVec(i));
end
plot(tVec, y)




%% d) Hitta gränsfall, bestämma hastighet v0 och rita bankurva.

% rMin = 1
% f(H) = rMin
% ==> f(H) - rMin = 0

% Plotta HVec och rMinVec - avläsa H där rMin = 1.
% ex. Vi vet: H=3 ger "crash" och H=4 ger "escape".
% ==> H = 3:noggrannhet:4;
% iterativ funktion som tar in värden på H och beräknar rMin

% ngt ==> 100 datapunkter {interpolation!} ==> 10^7 datapunkter ==> mer exakt värde på H / rMin
% ngt ==> 100 datapunkter {interpolation!} ==> koefficienter, med nogrannhet 10^-7 ==> polynom f(x) ==> sätt f(x) = 1 ==> sekantmetoden g(x) = f(x) - 1 = 0 (hitta nollställen), med nogrannhet 10^-14


H3 = 3;     % definitiv krash
H4 = 4;     % definitiv undflykt
% Dvs H-värdet måste ligga mellan H3 och H4

% Generera HVec och rMinVec
HVec = H3:h:H4;
for i = 1:length(HVec)
    H = HVec(i);
    [tMin, phiMin, rMin] = lowest_point(H, T);
    rMinVec(i) = rMin;
end
plot(HVec, rMinVec)
[sdaf] = divDiff(HVec, rMinVec)






%{

def divDiff(x,Y):
    diffs = []
    for i in range(len(Y)-1):
        diffs.append((Y[i+1] - Y[i])/(x+1))
    return diffs[0], diffs 

def main():
    Y = [102, 108, 124, 156, 210, 292, 408, 564]
    steps = 0
    y_data = Y
    firsts = [102]
    for i in range(len(y_data[steps:])):

        if sum(y_data) == len(y_data):
            break

        first, diffs = divDiff(i, y_data)
        y_data = diffs
        steps += 1
        if first != 0:
            firsts.append(first)
    print(firsts)

    x = range(len(Y))
    y = [P(x) for x in x]
    plot_poly(x, Y, y)

main()


%}

%% Functions

% Kan det vara MKV??? fortsättning följer...
function [coeffVec] = MKV(xData, yData)
    coeffVec = xData'\yData;
end
%{
function [coeffVec] = dividedDifference(xVec, yVec)
    maxIndex = length(xVec);
    diffMtrx = zeros(maxIndex, maxIndex);
    diffMtrx(:, 1) = yVec;
    for j = 1:maxIndex
        for i = j:maxIndex
            dY = diffMtrx(i, j-1) - diffMtrx(i-1, j-1);
            dX = xVec(i) - xVec(i-j+1);
            diffMtrx(i, j) = dY/dX;
        if i == j:
            coeffVec(j) = diffMtrx(i, j)        % lagrar koefficienterna i en vektor
        end
    end
end
%
function [sum] = P_(x, coeffVec, xVec)
    sum = coeffVec(1);
    for i = 2:length(coeffVec)
        term = coeffVec(i);
        for j = 1:i
            term = term * (x - xVec(j));
        end
        sum = sum + term;
    end
end

% Does ones round of divdiffs
function [divDiffVec] = divDiff(xVec, yVec)
    for i = 1:length(xVec)-1
        currentY = yVec(i); nextY = yVec(i+1);
        currentX = xVec(i); nextX = xVec(i+1);
        divDiffVec(i) = (nextY - currentY) / (nextX - currentX);
    end
end

%}

function [tMin, phiMin, rMin] = lowest_point(H, T)
    t0 = 0;
    h = 10^-3;
    [tVec, yMtrx] = RK4(H, T);

    % data vectors
    rVec = yMtrx(:, 1);
    phiVec = yMtrx(:, 3);
    tq = t0:0.001:T;

    % Splined vectors
    rSpline = spline(tVec, rVec, tq);
    phiSpline = spline(tVec, phiVec, tq);

    % finding lowest point (t, phi, r)
    rMin = min(rSpline);
    i = find(rSpline==rMin);
    tMin = tq(i);
    phiMin = phiSpline(i);
end

function [status, tVecToEnd, distVecToEnd, iter] = run_simulation(H, T)
    [tVec, yMtrx] = RK4(H, T);
    status = "unknown";
    previous_distance = inf;
    for i = 1:length(tVec)
        current_distance = yMtrx(i, 1);
        tVecToEnd = tVec(1:i);
        distVecToEnd = yMtrx(1:i, 1);
        iter = i;
        if current_distance <= 1
            status = "crashed";
            break;
        elseif current_distance > previous_distance
            status = "Escaped!!";
        end
        previous_distance = current_distance;
    end
end

function [tVec, yMtrx] = RK4(H, T)
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
end

function [result] = P(x, coeffVec)
    result = coeffVec(1)
    for i = 2:length(coeffVec)
        result = result + coeffVec(i) * x^(i-1)
    end
end
