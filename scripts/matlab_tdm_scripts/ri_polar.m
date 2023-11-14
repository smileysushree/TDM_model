function [ri] = ri_polar(trans_amp, e_diff,w, linewidth)
%RI_POLAR Summary of this function goes here
%   w is in eV, ediff = ei- ef

roh = 6.02214076*10^(23) * 5.17 *1000/ (737.94*10^(-3)); %density in kg/m^3  (roh = Na*density/mol.wt
e_charge = 1.60217663*(10^(-19)); % in C


alpha_i_final = [];                             % matrix for each alpha_i for sum over all final BN
for j = 2:size(trans_amp,1)                     % #of rows - gives #of initial bands considered
    alpha_final = [];                           % alpha_f 
    for i = 2:size(trans_amp,2)                 % #of columns -gives #of final bands considered subtracting column
        %if abs(e_diff(j,i) - w -((linewidth^2)/4)) > 0.04
        if w > 0.2
            x = (1/3)*(trans_amp(j,i)*e_charge)/(abs(e_diff(j,i)) -w -(complex(0,1)/2)*linewidth);  % individual alpha_f
            alpha_final = [alpha_final, x];             % matrix alpha_f for each initial BN(j)
    
        end
    end
    y = sum(alpha_final);                       % sum of all alpha_f for each alpha_i  #eqn 5
    alpha_i_final = [alpha_i_final,y];          % matrix of all alpha_i
end
alpha_i_total = sum(alpha_i_final);             % sum over all initial band numbers #eqn 4
%ri = (1 + 4 * pi* roh * alpha_i_total)^(1/2);       % ri for alpha(w) for all transitions
ri = (2 * pi* roh * alpha_i_total);
end

