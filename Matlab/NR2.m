% Newton Raphson Method to find the Recieving End Voltage
%P= E*B*Sin(Theta)
%Q= -E*B*Cos(Theta)
%Assuming Initial Condition of 1 and Angle 0
%Jacobian Matrix is
%
%J = [ V*B*Cos(theta)   B*sin(Theta);
%       V*B*sin(Theta)  -B*Cos(Theta);]
%Data imported from GAMS Optimized soluton
%   Created by ASHISH UPADHYAY with Help from AYUSH AND YASH for Final Project in PSOC
clear all
format short

s.name='Susceptance';
s.form='full';
s.compress=true;

x =rgdx('fin',s);
Sus=x.val;
Suels=x.uels;

s.name='Pflow_RT';
x =rgdx('fin',s);
Pow=x.val;
puels=x.uels;
for a = 1:5
    
disp(['Calculation for Probablistic Senario # ',num2str(a)]);
for i = 1:length(Pow(:,:,a))
    for j = 1:length(Pow(:,:,a))
        if Pow(i,j,a)>0 
B=5;
x=[0;1];
P=Pow(i,j,a)/100;

Q=0; %Enter Value of P and Q
% The Newton-Rapshson iterations starts here
del=1;
indx=0;
while del>1e-6
f=[(B*x(2)*sin(x(1)))-P; (B*x(2)*cos(x(1)))-Q];
J=[B*x(2)*cos(x(1)),B*sin(x(1)); -1*B*x(2)*sin(x(1)),cos(x(1))];
delx=-pinv(J)*f;
x=x+delx;
del=max(abs(f));
indx=indx+1;
end
disp(['Between Node ',num2str(i),' and ',num2str(j)]);
x
%figure(a);
%stem(a,x(2));
%disp(['P.F. Between Node ',num2str(i),' and ',num2str(j)]);
%cos(x(2))
%disp(['Recieving End Volt Between Node ',num2str(i),' and ',num2str(j)]);
%x(1)
        end
        end
    end
end
