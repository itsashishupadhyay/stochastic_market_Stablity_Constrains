*Set OutPut Location of gdx File generated
$setglobal location G:\PSOC\Project\Smart Grid Project\Smart Grid Project\

*Naming of file and parameters to be written
*$set matout "'TEst.gdx', cost,P_W,P, returnStat ";
$set matout  "fin.gdx"
$set DMULT 0.5

*Defination of Parameters
sets
i      conventional generators /i1*i2/
d      inelastic loads /d1*d2/
n      buses /n1*n3/
s      scenarios /s1*s5/
k      Renewable power generators /k1*k2/

slack(n)         /n1/
Mapi (i,n)      /i1.n1 , i2.n2/
Mapd(d,n)      /d1.n1 , d2.n3/
Mapnm(n,n)    /n1.n2 , n2.n1, n2.n3, n1.n3, n3.n1, n3.n2/
Mapk(k,n)    /k1.n1 , k2.n3/
alias (n,m);

parameters
W_max(k) Renewable's installed capacity
                         /k1 = 400, k2 = 400/;

parameters
Prob(s)                   probability of scenarios /
s1  0.20
s2  0.20
s3  0.20
s4  0.20
s5  0.20
*s6  0.1
*s7  0.1
*s8  0.1
*s9  0.1
*s10 0.1
 /

L(d) Load level /d1 400
                 d2 600/

V(d) value of lost load /d1 80
                         d2 80  /

TABLE Cost_Excess(k,s)   value associated with spillage
        s1       s2      s3      s4      s5
 k1     5        5       5       5       5
 k2     5        5       5       5       5    ;



*In Case of Spot market uncomment this and Comment out above table

$ontext
TABLE Cost_Excess(k,s)   value associated with spillage
        s1       s2      s3      s4      s5
 k1     -5       -5      -5      -5      -5
 k2     -5       -5      -5      -5      -5    ;

$offtext



TABLE Generation_Para (i,*)  generators' input data
        Pmax      C       Rmax
i1      600      25       0
i2      400      36       80;
Table Renewable_Para(k,s)  Renewable realization under different scenarios
         s1      s2     s3    s4     s5
k1       250     225    200   150    125
k2       250     225    200   150    125       ;
Table Line_Limit(n,n)  Transmission lines capacity
         n1      n2     n3
n1       0       200    200
n2       200     0      200
n3       200     200    0                 ;
Table Susceptance(n,n)    Tranmission lines susceptance
         n1      n2     n3
n1       0       500   500
n2       500     0     500
n3       500     500    0                   ;

variables
cost                Total expected system cost including Day Ahead and Real Time
theta_DA(n)         Voltage angles in DA
Pflow_DA(n,m)       Power flows in DA
Pflow_RT(n,m,s)     Power flows in RT
theta_RT(n,s)       Voltage angles in RT
PowerAdj(i,s)       Power adjustment of generator i in RT under scenario s;

positive variables
Load_shed(d,s)     Curtailed load
Pgen_DA(i)         DA dispatch of generators
Rnew_DA(k)         Renewable dispatch in DA
Power_spill(k,s)   Wind Spillage ;



*Equations Of Optimization

equations
ObjectiveFunction,nodalEq_DA,Pmax,Rmax,flow_DA,flow_max_DA,node_RT,UpperLmt,LowerLmt,generation_min,
generation_max,flow_RT,flow_max_RT,shedding,spillage,slack_RT,slack_DA;

ObjectiveFunction..                      cost=e=sum(s,Prob(s)*{[sum(i,Generation_Para(i,'C')*PowerAdj(i,s))]+
                                                 [sum(d,V(d)*Load_shed(d,s))]})+[sum(i,Generation_Para(i,'C')*Pgen_DA(i))];

*Day Ahead Constrains (subjected to)

nodalEq_DA(n)..                          sum(i$Mapi(i,n),Pgen_DA(i))+sum(k$Mapk(k,n),Rnew_DA(k))-sum(d$Mapd(d,n),L(d))
                                          -sum(m$Mapnm(n,m),Pflow_DA(n,m))=e=0;

Pmax(i)..                                Pgen_DA(i)=l=Generation_Para(i,'Pmax');
*Rmax(k)..                               Rnew_DA(k)=l=Renewable_Para(k);
Rmax(k)..                                Rnew_DA(k)=e=Sum(s,Prob(s)*Renewable_Para(k,s));

flow_DA(n,m)$Mapnm(n,m)..                Pflow_DA(n,m)=e=Susceptance(n,m)*(theta_DA(n)-theta_DA(m));

flow_max_DA(n,m)$Mapnm(n,m)..            Pflow_DA(n,m)=l=Line_Limit(n,m);

slack_DA..                               theta_DA('n1')=e=0;

* Real Time Constrains
node_RT(n,s) ..                          sum(i$Mapi(i,n),PowerAdj(i,s))+sum(k$Mapk(k,n),Renewable_Para(k,s)-Rnew_DA(k)-Power_spill(k,s))
                                          +sum(d$Mapd(d,n),Load_shed(d,s))-sum(m$Mapnm(n,m),Pflow_RT(n,m,s)-Pflow_DA(n,m))=e=0;

UpperLmt(i,s)..                          PowerAdj(i,s)=l=+Generation_Para(i,'Rmax');

LowerLmt(i,s)..                          PowerAdj(i,s)=g=-Generation_Para(i,'Rmax');

generation_min(i,s) ..                   [Pgen_DA(i)+PowerAdj(i,s)]=g=0;

generation_max(i,s) ..                   [Pgen_DA(i)+PowerAdj(i,s)]=l=Generation_Para(i,'Pmax');

flow_RT(n,m,s)$Mapnm(n,m) ..             Pflow_RT(n,m,s)=e=Susceptance(n,m)*(theta_RT(n,s)-theta_RT(m,s));

flow_max_RT(n,m,s)$Mapnm(n,m) ..         Pflow_RT(n,m,s)=l=Line_Limit(n,m);

shedding(d,s)..                          Load_shed(d,s)=l=L(d);

spillage(k,s)..                          Power_spill(k,s)=l=Renewable_Para(k,s);

slack_RT(s)..                            theta_RT('n1',s)=e=0;


model Stochastic_clearing /all/  ;

$if exist matout.gms $include matout.gms


solve Stochastic_clearing using mip minimizing cost ;
*time.l = Stochastic_clearing.resusd;

parameters

weightedcostspill                  Weighted cost spill
costspill                          Cost of spillage
LambdaN_DA(n)
spill_T(k,s)
costnew                            Cost After considering spillage cost
LambdaN_RT(n,s)        ;
LambdaN_DA(n)=nodalEq_DA.m(n)   ;
LambdaN_RT(n,s)=node_RT.m(n,s)/Prob(s);
Spill_T(k,s)=Power_spill.l(k,s);
*costnew = cost.l+sum((k,s),Spill_T(k,s)*sp(k,s));
costspill =  sum((k,s),Spill_T(k,s)*Cost_Excess(k,s));
weightedcostspill  =sum((k,s),Spill_T(k,s)*Cost_Excess(k,s)* Prob(s));
costnew = cost.l+weightedcostspill;


display
cost.l,weightedcostspill, costnew, LambdaN_DA, LambdaN_RT, Rnew_DA.l, Pgen_DA.l, PowerAdj.l, Power_spill.l, Load_shed.l,Spill_T;


*$libinclude matout cost.l
*$libinclude matout P_W.l
*set stat /cost, P_W,P/;
*parameter returnStat(stat);

*returnStat('cost') = Stochastic_clearing.modelstat;
*returnStat('P_W') = Stochastic_clearing.modelstat;
*returnStat('P') = Stochastic_clearing.modelstat;

execute_unload "%location%%matout%";
