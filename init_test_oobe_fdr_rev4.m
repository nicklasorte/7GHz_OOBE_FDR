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


%%%%%%%%%%%%%%%%Example Code with OOBE and FDR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Inputs
rev=1
band_mhz=100; %%%%%%%% carrier bandwidth [MHz] [B]
center_freq=7350; %%%%%%%MHz % carrier center [MHz]
edge1=center_freq+band_mhz/2;
oobeSeg = [edge1  edge1+20   -13  ;     % band edge to 7420
           edge1+20    Inf   -30  ];    % above 7420
cond_pwr_dBm=37.5;  % conducted power per transceiver [dBm], which is different than the 38.6dBm/1MHz or 58.6dBm/100MHz
%%%%%%%Example Rx IF Selectivity
rx_freq_mhz=7475; %%%%%%%MHz [placeholder]
array_rx_if=fliplr(horzcat(0,25,26,28,40,50)); %%%%Frequency MHz Half Bandwidth  [placeholder]
array_rx_loss=fliplr(horzcat(0,0.1,3,6,40,60)); %%%%%%%dB Loss [placeholder]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the OOBE
[table_oobe]=calc_oobe_7ghz_rev1(app,rev,oobeSeg,band_mhz,center_freq,cond_pwr_dBm)
data_header_oobe=table_oobe.Properties.VariableNames;
cell_oobe_data=table2cell(table_oobe);
col_freq_offset_idx=find(matches(data_header_oobe,'offset_from_center_MHz'));
col_eirp_idx=find(matches(data_header_oobe,'EIRP_PSD_dBm_per_MHz'));
array_mask=cell2mat(cell_oobe_data(:,[col_freq_offset_idx,col_eirp_idx]));

%%%%%%%Normalize mask for FDR
norm_array_mask=array_mask;
norm_array_mask(:,2)=abs(array_mask(:,2)-max(array_mask(:,2)));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Inputs
array_tx_rf=fliplr(norm_array_mask(:,1)'); %%%%Frequency MHz (Base Station) [Half Bandwidth]
array_tx_mask=fliplr(norm_array_mask(:,2)'); %%%%%%%dB Loss
tx_extrap_loss=-60; %%%%%%%%%TX Extrapolation Slope dB/Decade -60dB (Past the last point)
rx_extrap_loss=-60; %%%%%%%%%RX Extrapolation Slope dB/Decade 60dB (Past the last point)
tx_freq_mhz=center_freq;
fdr_freq_separation=abs(tx_freq_mhz-rx_freq_mhz)
fdr_calc_mhz=ceil(fdr_freq_separation*1.25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate FDR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Delta_Freq_Step=1
tic;
[FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = FDR_ModelII_vector_rev2(app,fdr_calc_mhz,array_tx_rf,array_rx_if,array_tx_mask,array_rx_loss,tx_extrap_loss,rx_extrap_loss,Delta_Freq_Step);
toc;

zero_idx=nearestpoint_app(app,0,DeltaFreq);
array_fdr=horzcat(DeltaFreq(zero_idx:end)',FDR_dB(zero_idx:end));
fdr_idx=nearestpoint_app(app,fdr_freq_separation,array_fdr(:,1));
fdr_dB=array_fdr(fdr_idx,:);  %%%%%%Frequency, FDR Loss

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FDR Plot
% figure;
% plot(FDR_dB)


figure;
hold on;
plot(array_fdr(:,1),array_fdr(:,2),'-b','LineWidth',2,'DisplayName','FDR Loss')
legend('Location','northwest')
title({strcat('FDR: Example Rx and Base Station')})
grid on;
xlabel('Frequency Offset [MHz]')
ylabel('FDR [dB]')
filename1=strcat('FDR_',num2str(rev),'.png');
saveas(gcf,char(filename1))

