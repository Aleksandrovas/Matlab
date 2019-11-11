clear all;close all;clc;fclose('all');

% add path to local Matlab library
addpath('Z:\Research\matlab\SE_Matlab_Learning\MatlabLib\');

% Data path
DataPath='Z:\Research\matlab\SE_Matlab_Learning\Task3\expData\exp2013_05_30\Scan\';
RefPath='Z:\Research\matlab\SE_Matlab_Learning\Task3\expData\exp2013_05_30\Ref\';

ChNr = 1;
SigNr = 4;


%% Load Ref signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stdVarRef=LoadstdVar(RefPath); 
Ref = LoadCycleData(RefPath,stdVarRef,ChNr,SigNr);


%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stdVar=LoadstdVar(DataPath);        
Fs = stdVar.SamplingFrequencyMHz*1e6;

X=(0:stdVar.Xsteps)*stdVar.Xstep;   % mm
Y=(0:stdVar.Ysteps)*stdVar.Ystep;   % mm    
xx=1:(stdVar.Xsteps)+1;
yy=1:(stdVar.Ysteps)+1;

[DataXY,DataFormat] = LoadScanData(DataPath,stdVar,ChNr,SigNr);
[~,N,~] = size(DataXY);

n = 0:N-1;
t = n/Fs;
t_us = t*1e6;


%% Csan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



