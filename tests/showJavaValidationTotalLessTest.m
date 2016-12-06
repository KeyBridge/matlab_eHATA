function showJavaValidationTotalLessTest()
% Function to show validation reslts form Matlab original model and Java
% model. Mat it is matlab original data, EHataValidationTest.dat - Java
% results from EHataValidationTest.java test file 
%clc;
clear all;
close all
% before parsing validation test data
% delete "[" and "]" symbols
fileID = fopen('EHataValidationTest.dat','r');
formatSpec = '%f, %f, %f, %f, %f, %f, %f, %f';
sizeA = [8 inf];
A = fscanf(fileID,formatSpec,sizeA);
fclose(fileID);

% Add the parent path which contains the functions
parentpath = cd(cd('..'));
addpath(parentpath);

% Load a set of elevation profiles
load('ElevProfile_MultiplePaths.mat');
numPaths = length(elevCell);
% Initialize parameters
% freq_MHz = 3500%700;
% hb_ant_m = 50;
% hm_ant_m = 3;
freq_MHz = 700;
hb_ant_m = 18;
hm_ant_m = 2;
region =  'Suburban'; % 'DenseUrban'; Suburban %'Suburban'; %

% Compute propagation loss for each path
LossEHTotal = NaN(1, numPaths);
LossEHMedian = NaN(1, numPaths);
d_Tx_Rx_km = NaN(1, numPaths);

figure
plot(A(1,:),'b--o');title('effective antennas Heights[]'); 
hold on;
plot(A(2,:),'g--*');title('effective antennas Heights[]'); grid;
figure
plot(A(3,:),'b--+');title('Isolated Ridge Terrain Correction Java'); grid;
figure
plot(A(4,:),'r--*');title('Rolling Terrain Correction Java'); grid;
figure
plot(A(5,:),'b--o');title('Sea Land Terrain Correction Java'); grid;
figure
plot(A(6,:),'r--*');title('Slope Terrain Correction Java'); 
%figure
% n = 71; % Number of path n=71

% plot( n:-1:1, A(7,:),'ro');title('Extended Hata Path Loss Model Test'); grid;
% figure
% plot(A(8,:),'r*');title('MedianBaseLoss'); grid;

legend('propagation loss'); grid;
%%

for pp = 1: numPaths
    
    % Get elevation profile
    elev = elevCell{pp};
    
    % Tx-Rx distance of each path
    numPoints = elev(1) + 1;                % number of points between Tx & Rx
    pointRes_km = elev(2)/1e3;              % distance between points (km)
    pointElev_m = elev(3:2+numPoints);      % elevation vector (m)
    d_Tx_Rx_km(pp) = (numPoints-1)*pointRes_km; % distance between Tx & Rx (km)
    
    % Compute total path loss
    LossEHTotal(pp) = ExtendedHata_PropLoss(freq_MHz, hb_ant_m, ...
        hm_ant_m, region, elev);
    
    % Compute median path loss
    [LossEHMedian(pp), ~] = ExtendedHata_MedianBasicPropLoss(freq_MHz, ...
        d_Tx_Rx_km(pp), hb_ant_m, hm_ant_m, region);
end;


% Plot path loss versus distance

% Matlab model data
figure;  subplot(1,2,1);
plot(d_Tx_Rx_km, LossEHTotal, 'bo', d_Tx_Rx_km, LossEHMedian, 'r*');
title([' ' region ' Matlab data']);
xlabel('Distance (km)');
ylabel('Path Loss (dB)');
legend('Loss_{total}', 'Loss_{median}', 'Location', 'best');
grid; axis([0 180 130 230]);


%%
% Java model data

% figure
subplot(1,2,2);
plot( d_Tx_Rx_km, A(7,:),'bo', d_Tx_Rx_km, A(8,:),'r*'); title('Java eHata Path Loss'); hold on
title([' ' region  ' Java data']);
xlabel('Distance (km)');
ylabel('Path Loss (dB)');
legend('Loss_{total}', 'Loss_{median}', 'Location', 'best');
grid; axis([0 180 130 230]);

%%
figure; subplot(2,1,1);
stem(d_Tx_Rx_km, LossEHTotal - LossEHMedian, 'filled');
title('Matlab eHata Propagation Loss Difference Due to Correction Factors');
xlabel('Distance (km)');
ylabel('Loss_{total} - Loss_{median} (dB)');
grid
subplot(2,1,2); stem(d_Tx_Rx_km, A(7,:) - A(8,:), 'filled');
title('Java eHata Propagation Loss Difference Due to Correction Factors');
xlabel('Distance (km)');
ylabel('Loss_{total} - Loss_{median} (dB)');
grid

end