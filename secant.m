function [tMin, yMin] = secant(t0, t1, f)
   
        n = 3;          % sekantmetoden 3 iterationer.
        % Startgissningar
        y0 = f(t0);
        y1 = f(t1);
        
        for i = 1:n
            t = t1 - y1 * (t1 - t0) / (y1 - y0);
            y = f(t);
 
            t0 = t1;            y0 = y1;
            t1 = t;             y1 = y;
        end
        yMin = y;
        tMin = t;
end
