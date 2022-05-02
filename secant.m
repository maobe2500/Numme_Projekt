function [tMin, yMin] = secant(LPI, tVec, yVec)
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
        yMin = y;
        tMin = t;
end
