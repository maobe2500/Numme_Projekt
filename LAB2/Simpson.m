%% a) Calculates integral with Simpson's formula, also displays number of intervals (n)
n1 = 8;
n2 = 16;
t0 = 3;
t1 = 9;
h1 = (t1-t0)/n1;
h2 = (t1-t0)/n2;

format Long
Mh1 = Simpson_func(h1);
Mh2 = Simpson_func(h2);

disp(Mh1)
disp(Mh2)
disp("end of a)")

%% b) Number of correct decimal places?
accuracy = abs(floor(log10(Mh1 - Mh2))); %Överensstämmande decimaler
disp("accuracy: " + accuracy)
% Answer: It depends (3 decimaler överensstämmer?)
disp("end of b)")



%% c) How does Eh depend on h?
% Gissning: för varje extra decimal i h (dvs 10^n till 10^(n-1)) kommer
% felets storleksordning sjunka med fyra (dvs 10^n till 10^(n-4)).
% Dock visar plotten på två linjära samband och gissningen stämmer bara för den undre linjen.

M = Simpson_func(1e-6); %Reference value (accurate approx with Simpsons formula)
h_vals = 0.01:0.01:0.1;
%n_vals = 1:10000;

Mh = ones(1, length(h_vals));
Eh = ones(1, length(h_vals));
for i = 1:length(h_vals)
    % h_vals(i) = (t1-t0)/n_vals(i);
    Mh(i) = Simpson_func(h_vals(i));
    Eh(i) = abs(M-Mh(i));
end

loglog(h_vals,Eh)


%% d) Approx the noggrannhetsordning by using the given formula and values for h.
% Nogrannhetsordningen converges to 4 for smaller values of h

p = ones(1, length(h_vals));
for i = 1:length(h_vals)
    p = log(Nogrannhet(h_vals(i)))/log(2);
    disp("Nogrannhet: " + p)
end




%% Functions


function [Kvot] = Nogrannhet(h)
    disp("h: " + h)
    Mh = Simpson_func(h);
    disp("Mh: " + Mh)
    Mh_half = Simpson_func(h/2);
    disp("Mh/2: " + Mh_half)
    Mh_quarter = Simpson_func(h/4);
    disp("Mh/4: " + Mh_quarter)

    Kvot = abs(Mh - Mh_half)/abs(Mh_half - Mh_quarter);
    disp(" ")
    disp("+++++++++++++++++++")
    disp(" ")
end



function [Mh] = Simpson_func(h)
    Q = @(t) 9 + 5.*(cos(0.4.*t)).^2;
    C = @(t) 5.*exp(-0.5.*t) + 2.*exp(0.15.*t);
    
    t0 = 3;
    t1 = 9;
    
    x = t0:h:t1;
    for i = 1:length(x)
        f(i) = Q(x(i))*C(x(i));
    end
    
    S_odd = sum(f(2:2:end-1));
    S_even = sum(f(3:2:end-1));

    Mh = h/3 * (f(1) + 4*sum(S_odd) + 2*sum(S_even) + f(length(f)));
    
end
