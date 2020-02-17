%	Data imported from GAMS Optimized soluton
%   Created by ASHISH UPADHYAY with Help from AYUSH AND YASH for Final Project in PSOC
function PlotPV(X,E,phi)
 %clear all; clc;
%phi = [20 10 0 -10 -15];
 %X = 37.4; %Reactance of LINE
%E = 132; % Rated voltage of BUS
 pmax = @(phi) -((sind(phi)-1)*E.^2)/(2*cosd(phi)*X);
 
for k = 1:length(phi)% for each value of phi, do the following:
 % #1 - Determine maximum power, Pmax, for current value of phi.
Pmax = pmax(phi(k));

 % #2 - Generate a P vector going from zero to Pmax.
% Make the distance between points smaller at the tip...
 % on the curve, for example:
p = 0:Pmax/100:Pmax*9/10;
 p = [p,(Pmax*(9/10+1/1000):Pmax/1000:Pmax)];
% #3 - Calculate the upper and lower voltage solutions at each...
 % point in the P vector.
V_upper = sqrt(-X*tand(phi(k))*p+(E.^2)/2+sqrt...
 ((E.^4)/4-X.^2*p.^2-E.^2*X*tand(phi(k))*p));
V_lower = sqrt(-X*tand(phi(k))*p+(E.^2)/2-sqrt...
 ((E.^4)/4-X.^2*p.^2-E.^2*X*tand(phi(k))*p));
% #4 - Plot the voltage V as function of the power P
 hold on
plot(p,abs(V_upper),'b')
 plot(p,abs(V_lower),'r')
% #5 - add a label to the curve containing the current value of...
 % phi in degrees
str=sprintf('\\Phi=%.1f',phi(k));
str2=sprintf('\n\nV=%.1f kV',abs(V_upper(end)));
str3=sprintf('\n\nP=%.1f MW',max(p)/1000000);
 text(Pmax*1.01,V_upper(end),strcat(str,str2,str3),'HorizontalAlignment','left')
%stem(max(p),abs(V_upper(end)),'filled','o','MarkerSize',3)
scatter(max(p),abs(V_upper(end)),'filled');
end

 % Add axis labels and plot the locus of critical points
phi = -30:1:90;
 Pmax_vec = zeros(1,length(phi));
V_vec = zeros(1,length(phi));
 for k = 1:length(phi)
Pmax_vec(k) = pmax(phi(k));
 V_vec(k) = sqrt(-X*tand(phi(k))*Pmax_vec(k)+(E.^2)/2);
 
end
 grid on
ax = gca;
 ax.GridLineStyle = ':';
plot(Pmax_vec,abs(V_vec),'k--')
 str=sprintf('Locus of critical points');
text(Pmax_vec(end)*0.99,V_vec(end),str,'VerticalAlignment'...
 ,'middle','HorizontalAlignment','right')
%axes label
% xlim([0 350])
xlabel('Active Power P [MW]')
 ylabel('Voltage V [kV]')
print -depsc PLOTPV.eps