function [H_precise, v0, L] = ErrRaket(a)
    % H-värdet måste ligga mellan H3 och H4
    HCrash = 1;     % definitiv krash
    HEscape = 2;     % definitiv undflykt
    T = 5;
    h = 10^-2;      % Steglängd mellan H3 och H4.

    % Generera HVec och rMinVec
    HVec = HCrash:h:HEscape;
    rMinVec = ones(1, length(HVec));
    for i = 1:length(HVec)
        H = HVec(i);
        [tVec, rVec, ~, ~, ~] = RK4(H, T, a);
        [~, LPI] = min(rVec);                                       % Returnerar index för den lägsta punkten under flygturen.
        [~, ~, rMin, ~, ~] = secant(LPI, tVec, rVec);
        rMinVec(i) = rMin;
    end


    % Beräkna k
    H1 = HVec(end);
    H0 = HVec(1);
    rMin1 = rMinVec(end);
    rMin0 = rMinVec(1);
    k = (rMin1 - rMin0)/(H1 - H0);

    % Beräkna m
    y = rMin0;
    x = H0;
    m = y - k*x;

    % Omskrivning av räta linjens ekvation för att räkna baklänges
    x = @(y) (y - m)/k;

    H_precise = x(1);

    % Hastigheten v0 raketen sveper förbi jordytan med.
    [tVec, rVec, rPrimeVec, phiVec, phiPrimeVec] = RK4(H_precise, T, a);
    [~, LPI] = min(rVec);
    phiPrimeMin = phiPrimeVec(LPI);         % Gör noggrannare??
    tMin = tVec(LPI);
    rMin = rVec(LPI);

    EARTH_CIRCUMF = 4*10^4;                 % (km)
    v0 = phiPrimeMin * EARTH_CIRCUMF/(2*pi*3.6);        
 
    % Ritar ut färdbanan då raketen precis sveper över trädtopparna
    L = 0;
    for i = 1:LPI
        dr = rVec(i+1)-rVec(i);
        dt = tVec(i+1)-tVec(i);
        L = L + sqrt(1 + (dr/dt)^2)*dt;
    end

end