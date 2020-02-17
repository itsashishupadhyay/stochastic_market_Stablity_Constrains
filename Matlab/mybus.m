function mpc = mybus
%MYBUS    Power flow data for 3 bus, 2 generator and 1 Wind case.
%   Please see CASEFORMAT (MATPOWER) for details on the case file format.
%
%   Based on data from PSOC Final Project DATA.

%   MATPOWER
%   Created by ASHISH UPADHYAY with Help from AYUSH AND YASH for Final Project in PSOC

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	400	0	0	0	1	1	0		100	1	1.1	0.9;
	2	2	0   0	0	0	2	1	-2.69 	100	2	1.1	0.9;
	3	1	600	0	0	0	3	1	-2.137	100	3	1.1	0.9;	
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	600	0	0	0	1	100	1	600	0	0	0	0	0	0	0	0	3	0.3	0	1;
	1	400	0	0	0	1	100	1	400	0	0	0	0	0	0	0	0	0	0	0	1;
	2	400	0	0	0	1	100	1	400	0	0	0	0	0	0	0	0	3	0.3	0	1;	
	3	400	0	0	0	1	100	1	400	0	0	0	0	0	0	0	0	0	0	0	1;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0	0.002	0	200	 	200		200		0	0	1	-360	360;
	1	3	0	0.002	0	200		200		200		0	0	1	-360	360;
	2	3	0	0.002	0	200		200		200		0	0	1	-360	360;	
];

%%-----  OPF Data  -----%%
%% area data
%	area	refbus
mpc.areas = [
	1	5;
];

%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	100		0	2	25  25;
	2	0		0	2	0   0;
	2	100		0	2	36  36;
	2	0		0	2	0   0;
];
