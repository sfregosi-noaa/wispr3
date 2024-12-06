function plot_wenz(fig)

figure(fig);
hold on;

frqW = [ 100 200 300 500 700 1000 2000 5000 10000 20000 50000];
%SeaSt0_Wenz = [ 39.0 44.0 56.  56.  54. 52.   47.   41.   36.    31.    24.];
SeaSt1_Wenz = [ 50.5 54.  56.  56.  54. 52.   47.   41.   36.    31.    24.];
SeaSt0_Wenz = SeaSt1_Wenz - 10;
SeaSt2_Wenz=[ 63.  66.  67.  66.  65. 63.   57.5  50.5  45.5    40.    33.5];
SeaSt6_Wenz = [71.   72.5 73.7  73.0 71.5 68.5  64.   57.   52.    47.    40.];

frqShip = [10.  20. 50. 100. 200. 500.];
NL_lightShip = [64.  67. 66. 58.  46.  30. ];
NL_moderate = [72.5 76. 75. 69.  58.  42.];
NL_heavy = [81.5 85. 85. 79.  69.  53.5];

semilogx(frqW/1000, SeaSt0_Wenz, 'b-', 'LineWidth', 2);
semilogx(frqW/1000, SeaSt1_Wenz, 'g-', 'LineWidth', 2);
semilogx(frqW/1000, SeaSt6_Wenz, 'r-', 'LineWidth', 2);
%semilogx(frqW, SeaSt6_Wenz, '--', 'LineWidth', 2);
%semilogx(frqShip/1000, NL_lightShip, 'b-', 'LineWidth', 2);
%semilogx(frqShip/1000, NL_moderate, 'g-', 'LineWidth', 2);
%semilogx(frqShip/1000, NL_heavy, 'r-', 'LineWidth', 2);

%legend('SS-0, Light Ship', 'SS-1', 'SS-66, Heavy Ship');

%text(1,30,'SS 0','FontSize',14, 'Color', 'b');
%text(1,,'SS 1','FontSize',14);
%text(1,60,'SS 6','FontSize',14, 'Color', 'r');
%%text(1000,70,'SS 6','FontSize',14);
%text(.020,60,'Light','FontSize',14, 'Color', 'b');
%text(20,77,'Moderate','FontSize',14);
%text(.020,90, 'Heavy','FontSize',14, 'Color', 'r');

hold off;
