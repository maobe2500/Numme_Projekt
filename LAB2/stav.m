

function [T_max] = stav(N, q0, q1)
    L = 3;
    k = 2;
    h = (L)/(N+1);

    % Create A matrix
    A = zeros(N, N);
    A_diag = [1 -2 1];
    A(1, 1:2) = [-2 1];
    A(end, end-1:end) = [1 -2];
    for i = 2:N-1
        A(i, i-1:i+1) = A_diag;
    end
    A = A*1/(h^2);


    t0 = 290;
    tEND = 400;

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

    T_max = max(T);

end