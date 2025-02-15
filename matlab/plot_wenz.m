function plot_wenz(fig)

figure(fig);
hold on;

wenz_freq = [100 200 300 500 700 1000 2000 5000 10000 20000 50000];
%wenz_noise_ss0 = [39.0 44.0 56.0 56.0 54.0 52.0 47.0 41.0 36.0 31.0 24.0];
wenz_noise_ss1 = [50.5 54.0 56.0 56.0 54.0 52.0 47.0 41.0 36.0 31.0 24.0];
wenz_noise_ss0 = wenz_noise_ss1 - 10;
wenz_noise_ss2 = [63.0 66.0 67.0 66.0 65.0 63.0 57.5 50.5 45.5 40.0 33.5];
wenz_noise_ss6 = [71.0 72.5 73.7 73.0 71.5 68.5 64.0 57.0 52.0 47.0 40.0];

ship_freq = [10.0 20.0 50.0 100.0 200.0 500.0];
ship_noise_lite = [64.0 67.0 66.0 58.0 46.0 30.0];
ship_noise_moderate = [72.5 76.0 75.0 69.0 58.0 42.0];
ship_noise_heavy = [81.5 85.0 85.0 79.0 69.0 53.5];

semilogx(wenz_freq/1000, wenz_noise_ss0, 'b-', 'LineWidth', 2);
%semilogx(wenz_freq/1000, wenz_noise_ss1, 'g-', 'LineWidth', 2);
semilogx(wenz_freq/1000, wenz_noise_ss6, 'r-', 'LineWidth', 2);

semilogx(ship_freq/1000, ship_noise_lite, 'b-', 'LineWidth', 2);
%semilogx(ship_freq/1000, ship_noise_moderate, 'g-', 'LineWidth', 2);
semilogx(ship_freq/1000, ship_noise_heavy, 'r-', 'LineWidth', 2);

%semilogx(wenz_freq/1000, wenz_noise_ss0, ship_freq/1000, ship_noise_lite, 'LineWidth', 2);

%plot(frqW/1000, SeaSt0_Wenz, 'b-', 'LineWidth', 2);
%plot(frqShip/1000, NL_lightShip, 'b-', 'LineWidth', 2);

%legend('SS-0, Light Ship', 'SS-1', 'SS-66, Heavy Ship');

text(1,30,'SS 0','FontSize',14, 'Color', 'b');
%text(1,,'SS 1','FontSize',14);
text(1,60,'SS 6','FontSize',14, 'Color', 'r');
%%text(1000,70,'SS 6','FontSize',14);
text(.020,60,'Light','FontSize',14, 'Color', 'b');
%text(20,77,'Moderate','FontSize',14);
text(.020,90, 'Heavy','FontSize',14, 'Color', 'r');

%hold off;
