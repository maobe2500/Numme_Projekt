function [tVec, rVec, rPrimeVec, phiVec, phiPrimeVec] = RK4(H, T, a, h)
    g = 20;
    F = g/(1+H)^2;

    u1 = H+1;
    u2 = 0;
    v1 = 0;
    v2 = 0;
    t0 = 0;
    n = (T-t0)/h; 
    tVec = t0:h:T;
    a = a * 2*pi/360;

    y_prim = @(u1, u2, v1, v2) [u2  ;  F*cos(a) - g/(u1^2) + u1*(v2)^2  ;  v2  ;  (F*sin(a) - 2*u2*v2)/u1];

    rVec = ones(n, 1);          rVec(1) = u1;
    rPrimeVec = ones(n, 1);     rPrimeVec(1) = u2;
    phiVec = ones(n, 1);        phiVec(1) = v1;
    phiPrimeVec = ones(n, 1);   phiPrimeVec(1) = v2;
    
    for i = 1:n
        u1 = rVec(i);
        u2 = rPrimeVec(i);
        v1 = phiVec(i);
        v2 = phiPrimeVec(i);

        f1 = y_prim(u1, u2, v1, v2);
        f2 = y_prim(u1 + h/2*f1(1), u2 + h/2*f1(2), v1 + h/2*f1(3), v2 + h/2*f1(4));         
        f3 = y_prim(u1 + h/2*f2(1), u2 + h/2*f2(2), v1 + h/2*f2(3), v2 + h/2*f2(4));
        f4 = y_prim(u1 + h*f3(1), u2 + h*f3(2), v1 + h*f3(3), v2 + h*f3(4));

        rVec(i+1) = u1 + h/6*(f1(1) + 2*f2(1) + 2*f3(1) + f4(1));               % r(t)
        rPrimeVec(i+1) = u2 + h/6*(f1(2) + 2*f2(2) + 2*f3(2) + f4(2));          % r'(t)
        phiVec(i+1) = v1 + h/6*(f1(3) + 2*f2(3) + 2*f3(3) + f4(3));             % phi(t)
        phiPrimeVec(i+1) = v2 + h/6*(f1(4) + 2*f2(4) + 2*f3(4) + f4(4));        % phi'(t) 

    end
end