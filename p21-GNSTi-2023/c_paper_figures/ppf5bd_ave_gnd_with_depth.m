% ppf3ac_ipf_maps.m
%
% Purpose:
% This script processes and visualizes dislocation density data over depth for different temperatures.
% It creates line plots for each temperature and time point.
%
% Usage:
% Simply run this script to generate the dislocation density plots for each temperature and time point.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Add the functions directory to the MATLAB path
fullScriptPath = mfilename('fullpath');
functionsPath = fullfile(fileparts(fullScriptPath), '../functions');
addpath(functionsPath);

% Define temperatures and visualization parameters
temperatures = [550, 700];
colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
lineStyles = {'-', '-', '--', ':', '-.', '-', '-', '--', ':', '-.', '-'};
markers = {'o','>','s','h','p','*','^','v','d','<'};
fontSizeXY = 14; % Font size for axes
fontSizeLegend = 16; % Font size for legend
fontSizeLabelTitle = 20;
lineWidth = 2; % Line width
markerSize = 80;

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints] = setDirectoriesAndTimes(iTemperature);

    figure(iTemperature)
    % Main loop to process each time point
    for iTimePoint = 1:length(fileTimes)
        % Construct input file name
        inputFile = constructInputFileName(inputDir, fileTimes{iTimePoint}, temperatures(iTemperature));
        inputData = readtable(inputFile);

        interval = 2;
        x = inputData.deep(1:interval:end);
        y = inputData.rho_ave_deep(1:interval:end) / 10^13;

        lengthName = sprintf('%d min', timePoints(iTimePoint));
        plot(y, x, ...
            'Color', colors{iTimePoint}, ...
            'LineWidth', lineWidth - 0.5, ...
            'DisplayName', lengthName);
    end

    % Add legend and set axes properties
    lgd = legend('FontSize', fontSizeLegend, 'TextColor', ...
        'black', 'Location', 'best', 'NumColumns', 1);
    if iTemperature == 1
        set(gca, 'YDir', 'reverse');
        set(gca, 'XAxisLocation', 'top');
        set(gca, 'YAxisLocation', 'right');
        figWidth = 10.8;
        figHeight = 13.10;
    else
        set(gca, 'YDir', 'reverse');
        set(gca, 'XAxisLocation', 'bottom');
        set(gca, 'YAxisLocation', 'right');
        figWidth = 10.8;
        figHeight = 10.15;
    end

    % Set labels and figure properties
    xlabel('\rho \times 10^{13} (1/m^2)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');
    ylabel('Depth (\mum)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');

    ylim([min(x), max(x)]);

    set(gca, 'FontSize', fontSizeXY, ...
        'LineWidth', lineWidth, ...
        'FontName', 'Times New Roman'); % Set x y axes

    set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight]);
    set(gcf, 'Color', 'None'); % Set figure window color to transparent
    set(gca, 'Color', 'None'); % Set axes background color to transparent
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\csv_ave_rho_with_depth\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv2\csv_ave_rho_with_depth\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to construct input file name
function inputFile = constructInputFileName(inputDir, fileTime, temperature)
    inputFile = fullfile(inputDir, sprintf('GNDTi_rho_deep_%s_%ddu.csv', fileTime, temperature));
end
