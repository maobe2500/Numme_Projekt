function [H_star, v0, L, tMin, rMin, phiMin] = ErrRaket(a, h)
    % H-värdet måste ligga mellan H3 och H4
    HCrash = 1;     % definitiv krash
    HEscape = 2;     % definitiv undflykt
    T = 5;
    step = 10^-2;      % Steglängd mellan H3 och H4.

    % Generera HVec och rMinVec
    HVec = HCrash:step:HEscape;
    rMinVec = ones(1, length(HVec));
    for i = 1:length(HVec)
        H = HVec(i);
        [tVec, rVec, ~, ~, ~] = RK4(H, T, a, h);
        [~, LPI] = min(rVec);                                       % Returnerar index för den lägsta punkten under flygturen.
	span = 10;      % interpolerar över 21 punkter närmast lägsta punkten
	ySpan = rVec(LPI-span:LPI+span);
	tSpan = tVec(LPI-span:LPI+span);
	c = polyfit(tSpan, ySpan, 2);
	f = @(t) c(1)*t^2 + c(2)*t + c(3);
	t0 = tVec(LPI-1);
	t1 = tVec(LPI+1);
	[tMin, rMin] = secant(t0, t1, f);
	rMinVec(i) = rMin;
    end

    c = polyfit(HVec, rMinVec, 2);
    f = @(t) c(1)*t^2 + c(2)*t + c(3) - 1;
    h0 = 1.29; h1 = 1.31;
    [H_star, ~] = secant(h0, h1, f);


    % Hastigheten v0 raketen sveper förbi jordytan med.
    [tVec, rVec, ~, phiVec, phiPrimeVec] = RK4(H_star, T, a, h);
    [~, LPI] = min(rVec);
    phiPrimeMin = phiPrimeVec(LPI);         % Gör noggrannare??
    tMin = tVec(LPI);
    rMin = rVec(LPI);
    phiMin = phiVec(LPI);

    EARTH_CIRCUMF = 4*10^4;                 % (km)
    v0 = phiPrimeMin * EARTH_CIRCUMF/(2*pi*3.6);        
 
    % Ritar ut färdbanan då raketen precis sveper över trädtopparna
    
    L = 0;
    for i = 1:LPI
       dr = rVec(i+1)-rVec(i);
       dt = tVec(i+1)-tVec(i);
       dphi = (phiVec(i+1)-phiVec(i));
       L = L + sqrt((rVec(i)*dphi/dt)^2 + (dr/dt)^2)*dt;
    end
end
