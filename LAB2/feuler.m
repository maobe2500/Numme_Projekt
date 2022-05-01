function [tVec, yVec] = feuler(u0, h, T)
    L = 1.5;
    m = 0.6;
    g = 9.81;
    mu = 0.2;

    t0 = 0;
    n = (T-t0)/h; 
    
    tVec = t0:h:T;

    yVec = [u0(1) u0(2)]; % Dvs första index i yVec innehåller initialvärdesvektorn u0
    % y1_prim = y2;
    % y2_prim = - (mu/m)*y2 - (g/L)*sin(y1);
    
    for i = 1:n
        y1_old = yVec(i, 1);
        y2_old = yVec(i, 2);
        y_prim = @(y1, y2) [y2 ; - (mu/m)*y2 - (g/L)*sin(y1)];
        
        y_prim_vec = y_prim(y1_old, y2_old);

        yVec(i+1, 1) = yVec(i, 1) + h*y_prim_vec(1,1);
        yVec(i+1, 2) = yVec(i, 2) + h*y_prim_vec(2,1);
    end
end