%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Caroline Van Neste
%% Low Pass Filter vs Experimental Data
%% Date: 11/6/2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear;clc;
T = readtable('test6_oscilloscope_data.csv', ReadRowNames=true);
varNames = readtable('test6_oscilloscope_data.csv', Range= "A1:E2");
Tstart = varNames.Start;
Tstep = varNames.Increment;
numPoints = size(T, 1);

% parameters
RS = 17.82;
RL = 160.4;
CL = 105.6 * 10^-9; %change to measured capacitancee
frequency  = 10*10^3;     % frequency
Vdc = 3;
Vp = 2;

t = Tstart:Tstep:(numPoints-1)*Tstep+Tstart;

% state-space matrices
A = [-1/(CL*(RS+RL))];
B = [1/(CL*(RS+RL))];
C = [1];
D = [0];

% initial condition
x0 = [T.Var2(1)];

% input signal
u = @(t) sin(t * 2 * pi * frequency) * Vp + Vdc;

% state-space representation of the system
G = ss(A,B,C,D);
[y,t] = lsim(G, u(t), t, x0);
fs = 500000000; %500MHz

PhDiff = phdiffmeasure(y, T.Var2, fs, 'dft') %calculate phase difference

u = @(t) sin(t * 2 * pi * frequency + PhDiff) * Vp + Vdc;
[y,t] = lsim(G, u(t), t, x0);

% plot the results
figure;
plot(t,y, 'LineWidth', 4); hold on;
plot(t,T.Var2);
legend('Simulation voltage (v_s)','Experimental voltage (v_e)');
title('Numerical simulation of a series RC circuit vs experimental values')
xlabel('Time');

RMSE = sqrt(mean((T.Var2 - y).^2)) % Root Mean Squared Error
