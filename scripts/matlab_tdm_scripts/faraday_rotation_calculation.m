clear
clc
close all

% Constants
c =  3*10^8;          % speed of light m/s^2
%hbar = 1.05457182*10^(-34);   %m^2kg/s
hbar = 1; % gaussian units
e_charge = 1.60217663*(10^(-19)) ;    % electron charge in C
e_mass = 9.1093837*(10^(-31))   ;     % electron mass in kg

multi_fac=2.38*(10^(-4));
leff = 10^9;      % in nm


%% faraday rotation for bulk
trans_amp_down = readmatrix('TDM_bulk.xlsx','Sheet','down','Range',"B2:G5");
trans_amp_up = readmatrix('TDM_bulk.xlsx','Sheet','up','Range',"B2:J9");
ediff_down = readmatrix('TDM_bulk.xlsx','Sheet','E_down','Range',"B2:G5");
ediff_up = readmatrix('TDM_bulk.xlsx','Sheet','E_up','Range',"B2:J9");

%%%%%
% Formula for faraday rotation
%ri_polar(input = transition amplitude, e_final- e_initial, w, roh, linewidth)
%%%%%
theta = [];
lambda_plot_bulk = [];
linewidth = 4.7*10^(-9);
E_probe = linspace(0.05,6.05,2000);

for i = 1:length(E_probe)
    lambda = 1239.84193/E_probe(i) ;         % in nm    #eqn 1
    theta_x = (multi_fac)*pi*(ri_polar(trans_amp_up, ediff_up, E_probe(i),linewidth) ...
        -ri_polar(trans_amp_down, ediff_down, E_probe(i), linewidth))/(lambda);
    theta = [theta, theta_x];
    lambda_plot_bulk = [lambda_plot_bulk, lambda] ;

end


%% Removing outliers from theta
movmean_window=300;
theta_wo_outliers=nan(size(theta));
theta_wo_outliers(theta<(2000E06*multi_fac) & theta>-(2000E06*multi_fac))=theta(theta<(2000E06*multi_fac) & theta >-(2000E06*multi_fac));
theta_prime_bulk =  movmean(fillgaps(theta_wo_outliers),movmean_window);

%% Plotting
Ftsz_tic=15;
fnsz_lab=15;

figure(1);clf;
set(gcf,'Position',[300, 200, 1300,800]);
ha=tight_subplot(1,2,[0.09 0.08],[0.1 0.1],[0.1 0.07]); %spacing outside plots


% Plot 1 (left): Faraday rotation vs E(ev) bulk
axes(ha(1))
plot(E_probe,theta_prime_bulk/(leff),"Color",'blue', 'LineWidth',1.5);
set(gca,'FontSize',Ftsz_tic,'TickDir','out')
xlim([0 6])
xlabel('Probe Energy (eV)','FontSize', fnsz_lab)
ylabel('Specific Faraday Rotation (deg/unit-length)','FontSize', fnsz_lab)
hold on;


% Plot 2 (right): Faraday rotation vs wavelength (nm) bulk
axes(ha(2))
plot(lambda_plot_bulk,theta_prime_bulk/(leff),"Color",'blue', 'LineWidth',1.5,'DisplayName','Bulk')
xlim([450 800])
set(gca,'FontSize',Ftsz_tic,'TickDir','out')
xlabel('Wavelength (nm)','FontSize', fnsz_lab)
hold on;



%% faraday rotation for surface
trans_amp_down = readmatrix('TDM_surface.xlsx','Sheet','down','Range',"B2:G5");
trans_amp_up = readmatrix('TDM_surface.xlsx','Sheet','up','Range',"B2:J9");
ediff_down = readmatrix('TDM_surface.xlsx','Sheet','E_down','Range',"B2:G5");
ediff_up = readmatrix('TDM_surface.xlsx','Sheet','E_up','Range',"B2:J9");

% Formula for faraday rotation
% input = transition amplitude, e_final, e_initial and w and linewidth

theta = [];
lambda_plot_surface = [];
linewidth = 4.7*10^(-9) - 4.7*10^(-9)*0.3;   % 30 % reduction in linewidth
E_p = [];
E_probe_surface = linspace(0.05,6.05,1500);

for i = 1:length(E_probe_surface)
    lambda = 1239.84193/E_probe_surface(i) ;         % in nm
    if 450 <lambda < 4000
        theta_x = (multi_fac)*pi*(ri_polar(trans_amp_up, ediff_up, E_probe_surface(i),linewidth) ...
            -ri_polar(trans_amp_down, ediff_down, E_probe_surface(i),linewidth))/(lambda);
        %theta_x = pi*(ri_polar(trans_amp_up, ediff_up, E_probe_surface(i),linewidth) ...
        %    -ri_polar(trans_amp_down, ediff_down, E_probe_surface(i),linewidth))/(lambda);
        theta = [theta, theta_x];
        lambda_plot_surface = [lambda_plot_surface, lambda] ;
        E_p = [E_p, E_probe_surface(i)];
    end
end

%% Removing outliers from theta
movmean_window=100;
theta_wo_outliers=nan(size(theta));
theta_wo_outliers(theta>-(20000E05*multi_fac) & theta<(500E0*multi_fac))=theta(theta<(500E0*multi_fac) & theta >-(20000E05*multi_fac));
theta_prime_surface =  movmean(fillgaps(theta_wo_outliers),movmean_window);


%% PLotting

% Plot 3 (left): Faraday rotation vs E(ev)
axes(ha(1))
plot(E_p,(-theta_prime_surface/(leff)),"Color",'red', 'LineWidth',1.5);
set(gca,'FontSize',Ftsz_tic,'TickDir','out')
hold on;

%xlim([1 2.5])
xt=xticks;
xticks(xt);
xticklabels(xt);


%ylim([])
yt=yticks;
yticks(yt);
yticklabels(yt);
ytickformat('%.1f')

xlabel('Probe Energy (eV)','FontSize', fnsz_lab)
ylabel(strcat("Specific Faraday Rotation (rad per nm)"),'FontSize', fnsz_lab)
%title(strcat("Temp = -273.15",char(176),"C"),'FontWeight','bold')
% for deg , char(176),"
%yticks=

% Plot 4 (right): Faraday rotation vs wavelength (nm)
axes(ha(2))
plot(lambda_plot_surface,(-theta_prime_surface/(leff)),"Color",'red', 'LineWidth',1.5,'DisplayName','Surface');
xlim([500 950])
%ylim([0 2000])
set(gca,'FontSize',Ftsz_tic,'TickDir','out')
xlabel('Wavelength (nm)','FontSize', fnsz_lab)
legend()

%%
%plot at temp_27C
%theta_27 =  exp(-300*ln(abs(theta_prime_bulk/10^6)))
% Energy
% axes(ha(2))
% plot(E_probe,exp(-(27/273.15)*log(theta_prime_bulk/leff)),"Color",'blue', 'LineWidth',1)
% hold on;
% axes(ha(2))
% plot(E_p,exp(-(27/273.15)*log(-theta_prime_surface/leff)),"Color",'red', 'LineWidth',1)
% xlabel('Probe Energy (eV)')
% %ylabel('Specific Faraday Rotation (deg/um)')
% title(strcat("Temp = 27",char(176),"C"),'FontWeight','bold')
% hold on;
% 
% %wavelength
% axes(ha(4))
% plot(lambda_plot_bulk,exp(-(27/273.15)*log(theta_prime_bulk/leff)),"Color",'blue', 'LineWidth',1)
% hold on;
% axes(ha(4))
% plot(lambda_plot_surface,exp(-(27/273.15)*log(-theta_prime_surface/leff)),"Color",'red', 'LineWidth',1)
% xlim([500 950])
% xlabel('Wavelength (nm)')


print("FR_with_TDM",'-dpng','-r300')

