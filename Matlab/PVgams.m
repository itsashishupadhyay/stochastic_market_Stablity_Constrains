phi = [20 10 0 -10 -15];

s.name='Susceptance'
s.form='full'
s.compress=true

x =rgdx('fin',s)
Sus=x.val
Suels=x.uels

s.name='Pflow_RT'
x =rgdx('fin',s)
Pow=x.val
puels=x.uels

Z=1./Sus

E=Pow./Z
E = sqrt(E(:,:,5))

fig=1;
for i = 1:3
for j=1:3
if Pow(i,j,5)>0 
figure (fig)
fig=fig+1;
PlotPV(Z(i,j),E(i,j),phi)
title(['Between Node ',num2str(i),' and ',num2str(j)]);
grid on

end
end
end