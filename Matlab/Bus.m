close all,
clear all,
%addpath 'C:\GAMS\win64\23.9'
clc,
tic,
gamso.output = 'Std';
define_constants;
mpopt = mpoption('VERBOSE',0,'OUT_ALL', 0);
%%% loading case to be considered and changing parameters as required
mpc = loadcase('mybus');
line_lim=mpc.branch(:,RATE_A)/mpc.baseMVA;
%%% calculating system size
nb = size(mpc.bus, 1); % number of buses
ng = size(mpc.gen, 1); % number of generators
nl = size(mpc.branch, 1); % number of lines
n_wind = size(mpc.wind, 1); % number of wind farms
slack=find(mpc.bus(:,BUS_TYPE)==3); % define slack bus

HH = makePTDF(mpc.baseMVA, mpc.bus, mpc.branch, slack); % make PTDF
Pmaxx=zeros(nb,1);
ramp=zeros(nb,1);
cost_a = zeros(nb,1);
cost_b = zeros(nb,1);
cost_c = zeros(nb,1);
windd = zeros(nb,1);
for i=1:ng
Pmaxx(mpc.gen(i,GEN_BUS))=mpc.gen(i,PMAX);
ramp(mpc.gen(i,GEN_BUS))=mpc.gen(i,PC1);
cost_a(mpc.gen(i,GEN_BUS))=mpc.gencost(i,5);
cost_b(mpc.gen(i,GEN_BUS))=mpc.gencost(i,5);
cost_c(mpc.gen(i,GEN_BUS))=mpc.gencost(i,5);
end
for j=1:n_wind
windd(mpc.wind(j,1))=mpc.wind(j,2);
end
Pmaxx=Pmaxx/mpc.baseMVA; % convert Pmax to per unit
windd=windd/mpc.baseMVA; % convert winds to per unit
ramp=ramp/mpc.baseMVA; % convert ramp rate capability to per unit
cost_c=cost_c*mpc.baseMVA*mpc.baseMVA; % convert cost coefficient c to per unit
cost_b=cost_b*mpc.baseMVA; % convert cost coefficient b to per unit
real_load = mpc.bus(:,PD)/mpc.baseMVA; % define loads and convert it to per unit
gen_costs = [cost_a cost_b cost_c]; % generation costs
M_HH = 4887/mpc.baseMVA; % define system inertia
f_dbb = 0.05; % define dead band frequency
P_LL = 550/mpc.baseMVA; % define power loss
N=struct('name','i','type','set','val',[linspace(1,nb,nb)]');
M=struct('name','l','type','set','val',[linspace(1,nl,nl)]');
r_l=struct('name','r_l','type','parameter','val',real_load,'form','full');
lin_li=struct('name','lin_li','type','parameter','val',line_lim,'form','full');
H=struct('name','H','type','parameter','val',HH,'form','full');
Pmax=struct('name','Pmax','type','parameter','val',Pmaxx,'form','full');
ramp_rate=struct('name','ramp_rate','type','parameter','val',ramp,'form','full');
gen_cost=struct('name','gen_cost','type','parameter','val',gen_costs,'form','full');
M_H=struct('name','M_H','type','parameter','val',M_HH,'form','full');
f_db=struct('name','f_db','type','parameter','val',f_dbb,'form','full');
P_L=struct('name','P_L','type','parameter','val',P_LL,'form','full');
wind=struct('name','wind','type','parameter','val',windd,'form','full');
wgdx('opt_mod_wgdxcall_data',N,M,r_l,lin_li,H,Pmax,ramp_rate,gen_cost, M_H,f_db,P_L,wind);