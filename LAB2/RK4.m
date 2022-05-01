function [tVec, yVec] = RK4(u0, h, T)
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
    
    y_prim = @(y1, y2) [y2; - (mu/m)*y2 - (g/L)*sin(y1)];
    
    for i = 1:n
        y1 = yVec(i, 1);
        y2 = yVec(i, 2);


        f1 = y_prim(y1, y2);
        f2 = y_prim(y1 + h/2*f1(1), y2 + h/2*f1(2));
        f3 = y_prim(y1 + h/2*f2(1), y2 + h/2*f2(2));
        f4 = y_prim(y1 + h*f3(1), y2 + h*f3(2));


        yVec(i+1, 1) = y1 + h/6*(f1(1) + 2*f2(1) + 2*f3(1) + f4(1));
        yVec(i+1, 2) = y2 + h/6*(f1(2) + 2*f2(2) + 2*f3(2) + f4(2));
    end
end

