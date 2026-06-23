clear;
clc;
close all force;
close all;
app=NaN(1);  %%%%%%%%%This is to allow for Matlab Application integration.
format shortG
top_start_clock=clock;
folder1='C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\7GHz MetSat Adjacent';
cd(folder1)
addpath(folder1)
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Basic_Functions')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Inputs
rev=1
band_mhz=100; %%%%%%%% carrier bandwidth [MHz] [B]
center_freq=7350; %%%%%%%MHz % carrier center [MHz]
edge1=center_freq+band_mhz/2;
oobeSeg = [edge1  edge1+20   -13  ;     % band edge to 7420
           edge1+20    Inf   -30  ];    % above 7420
cond_pwr_dBm=37.5;  % conducted power per transceiver [dBm], which is different than the 38.6dBm/1MHz or 58.6dBm/100MHz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[table_oobe]=calc_oobe_7ghz_rev1(app,rev,oobeSeg,band_mhz,center_freq,cond_pwr_dBm)

