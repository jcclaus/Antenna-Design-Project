% John Claus
% ECE584 Project

clear all;          % clears all variables
format short;       % decimals have 4 sigfigs

%These are initial input values
N = 12;                 % Number of Dipoles
lambda = 1;             % Wavelength 
k = (2 * pi)/lambda;    % k val
d = lambda  ;         % distance between dipoles
beta = 0;              % phase offset beta1

% This loop creates an array of angles to be later used
% in calculations 
for count = 1:18000
    theta(count) = count./100 * (pi / 180);
end

% The psi function used in calculations
psi = (k * d * cos(theta)) + beta;

% AF is calculated here using exponentials
AF = (1 + (-0.161 * exp(1i * psi)) + (-1.177 * exp(1i * 2 * psi)) + (-0.485 * exp(1i * 3 * psi))...
    + (2.650 * exp(1i * 4 * psi)) + (5.790 * exp(1i * 5 * psi)) + (5.790 * exp(1i * 6 * psi))...
    + (2.650 * exp(1i * 7 * psi)) + (-0.485 * exp(1i * 8 * psi)) + (-1.177 * exp(1i * 9 * psi))...
    + (-0.161 * exp(1i * 10 * psi)) + (1 * exp(1i * 11 * psi)));

% for n = 1:(N)
%     AF = AF + exp(1i * (n-1) * psi);
% end

% AF is normalized here to become AFn
AFn = AF / (2*(1-0.161-1.177-0.485+2.650+5.790));
AFn;

% U is calculated by squaring the normalized AFn
for count = 1:18000
    U(count) = abs(AFn(count)) * abs(AFn(count));
end

% The max value of U is calculated here
U_max = max(U);

% An array of dB values for U is created here
U_dB = 10 * log10(U);

% An intermediate array for calulating radiated power
F=U.*sin(theta)*(pi/180)*0.01;

% Radiated power is calculated here
P=2*pi*sum(F);

% Directivity is calculated here using radiated power and max U
D = (4 * pi * U_max) / P

% Eqn used to verify the half-power algorithm
%half_set = U(U<0.51 & U>0.49)

% Half power algorithm used for HPBW by finding the angles
% with U values closest to 0.5 of the main lobe
U_max_ang = 1;
closest = 0.55;
diffest = 0.05;
for count = 1:5000 
    if U(count) == 1
        U_max_ang = count./ 100;
    end
    diff = abs(0.5 - U(count));
    if diff < diffest
        closest = U(count);
        closest_ang = count./ 100;
        diffest = diff;
    end
end
hpbw = 2 * abs(closest_ang - U_max_ang)       % HPBW from simulation

% Used to find the sidelobe peak values
pks=findpeaks(U); 
% Returns a dB value for the sidelobe peak values
sidelobe_db = 10*log10(pks)         % Sidelobe dB values

% Algorithm used to determine the theta values were the 
% sidelobe peaks occur
pks_index = 1;
for count = 1:18000
    if pks_index <= length(pks)
        if pks(pks_index) == U(count)
            pks_ang(pks_index) = count./ 100;
            pks_index = pks_index + 1;
        end
    end
end
% Returns the angles of the sidelobes
pks_ang                             % Sidelobe angle values

% Graph of the U values
theta_deg = theta * (180/pi);           % Converts the theta values to deg
figure(1)                               % define figure #1
plot(theta_deg,U_dB,'b-')               % plot the data in x and y coordinates
xlabel('\theta (degrees)')              % label x coordinate
ylabel('Normalized Power (dB)')         % label y coordinate
title(' 12 Element Flat-topped (d = \lambda)')   % title of the figure
axis([0 180 -60 0])                     % define the min/max of the x and y axis
text(10,-5,['D = ' num2str(D)])
text(10,-9,['HPBW = ' num2str(hpbw)])
