clear all
clc

%% A) Create A matrix
N = 10;
L = 3;
k = 2;
h = (L)/(N+1);

A = getA(N, h);



%% B) Calculate T vector, create X vector and plot the results
[xVec, T] = getTemp(N, A, h, L, k);
plot(xVec, T);
hold off




%% C) 
NVec = [40, 80, 160, 320, 640, 1280, 2560, 5120, 10240];
for i = 1:length(NVec)
    h = L/(NVec(i)+1);
    A = getA(NVec(i), h);
    [xVec TVec] = getTemp(NVec(i), A, h, L, k);

    plot(xVec, TVec);
    hold on

    T_mean(i) = sum(TVec)/length(TVec);
    T_max(i) = max(TVec);
    T_min(i) = min(TVec);

end
T_mean = T_mean'; 
T_max = T_max';
T_min = T_min';
NVec = NVec';
results = table(NVec, T_min, T_max, T_mean);
display(results)

err = abs(T_max(end) - T_max(4))                                % T_max(end) is the pseudo exact (analytical) value
display("Estimated absolute error for N = 320: " + err)




%% D)
% See stav.m and Temperatur2.m




%% Functions

function [xVec, T] = getTemp(N, A, h, L, k)
    t0 = 290;
    tEND = 400;

    q0 = 3000;
    q1 = 200;

    T_bis = @(x) 1/k*(q0*exp(-q1*(x - 0.7*L)^2) + 200);

    % X vector
    xVec = 0:h:L;

    % b vector
    b(1) = -T_bis(xVec(2)) - t0/(h^2);
    b(N) = -T_bis(xVec(N-1)) - tEND/(h^2);
    for i=2:N-1
        b(i) = -T_bis(xVec(i+1));
    end
    b=b'; % Needs to be a colmn vector

    % Calculate T vector
    T = zeros(N+2, 1);
    T(1) = t0;
    T(end) = tEND;
    T(2:end-1) = A\b;
end


function A = getA(N, h)
    A = zeros(N, N);
    A_diag = [1 -2 1];
    A(1, 1:2) = [-2 1];
    A(end, end-1:end) = [1 -2];

    for i = 2:N-1
        A(i, i-1:i+1) = A_diag;
    end
    
    A = A*1/(h^2);
end

