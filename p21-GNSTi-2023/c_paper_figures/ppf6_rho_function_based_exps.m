% ppf6_rho_function_based_exps.m
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

% Define temperatures and visualization parameters
temperatures = [550, 700];
colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
lineStyles = {'-', '-', '--', ':', '-.', '-', '-', '--', ':', '-.', '-'};
markers = {'o','>','s','h','p','*','^','v','d','<'};
fontSizeXY = 16; % Font size for axes
fontSizeLegend = 18; % Font size for legend
fontSizeLabelTitle = 18;
lineWidth = 2; % Line width
markerSize = 80;

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, legendNames] = setDirectoriesAndTimes(iTemperature);

    figure(iTemperature)
    hold on;
    box on;
    % Main loop to process each time point
    for iTimePoint = 1:length(fileTimes)
        % Construct input file name
        inputFile = constructInputFileName(inputDir, fileTimes{iTimePoint}, temperatures(iTemperature), iTimePoint);
        inputData = readtable(inputFile);

        % Extract and process data
        x = inputData.time;
        y = inputData.GND_ave;
        sigma = inputData.error_bar;

        % Plot error bars
        errorbar(x, y./10^13, sigma./10^13, ...
            'Color', colors{iTimePoint}, ...
            'LineWidth', lineWidth, ...
            'LineStyle', 'none', ... % Set to no line style
            'Marker', markers{iTimePoint}, ...
            'MarkerEdgeColor', colors{iTimePoint}, ...
            'MarkerFaceColor', colors{iTimePoint}, ...
            'MarkerSize', markerSize, ...
            'DisplayName', legendNames{iTimePoint});

        % Fit exponential decay model
        xBegin = x(1) * 60;
        rhoBegin = y(1);

        if iTemperature == 1
            if iTimePoint == 3
                rhoEnd = 23.0e12; 
                xFit = linspace(10, 500) * 60;
                yFit = (rhoBegin - rhoEnd) .* exp(-0.00010 * (xFit - xBegin)) + rhoEnd;
                legendNameFit = 'Fit-Level 2';
            else
                rhoEnd = 8.5e13;
                xFit = linspace(10, 500) * 60;
                yFit = (rhoBegin - rhoEnd) .* exp(-0.00010 * (xFit - xBegin)) + rhoEnd;  
                legendNameFit = 'Fit-Level 3'; 
            end
        else
            if iTimePoint == 3
                rhoEnd = 2.0912e12;
                xFit = linspace(4, 165) * 60;
                yFit = (rhoBegin - rhoEnd) .* exp(-0.00046 * (xFit - xBegin)) + rhoEnd;
                legendNameFit = 'Fit-Level 2';
            else
                rhoEnd = 3.9e13;
                xFit = linspace(4, 165) * 60;
                yFit = (rhoBegin - rhoEnd) .* exp(-0.0006 * (xFit - xBegin)) + rhoEnd;
                legendNameFit = 'Fit-Level 3'; 
            end
        end

        % Plot fitted curve
        plot(xFit./60, yFit./10^13, ...
            'Color', colors{iTimePoint}, ...
            'LineWidth', lineWidth, ...
            'LineStyle', lineStyles{iTimePoint}, ...
            'DisplayName', legendNameFit);
    end

    set(gca, 'FontSize', fontSizeXY, ...
        'LineWidth', lineWidth, ...
        'FontName', 'Times New Roman'); % Set x and y axes

    xlabel('Time (min)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');
    ylabel('\rho \times 10^{13} (1/m^2)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');

    legend('FontSize', fontSizeLegend, 'TextColor', ...
        'black', 'Location', 'northeast', 'NumColumns', 2);

    figWidth = 14.8; 
    figHeight = 13.02; 
    ylim([0.2 13.5]);
    xlim([0 500]);

    set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight])
    set(gcf, 'Color', 'None'); % Set figure window color to transparent
    set(gca, 'Color', 'None'); % Set axes background color to transparent
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, legendNames] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\csv_ave_rho_levels\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
        legendNames = {'Global', 'Layer 1', 'Exp-Layer 2', 'Exp-Layer 3', 'Layer 4'};
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv2\csv_ave_rho_levels\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
        legendNames = {'Global', 'Layer 1', 'Exp-Layer 2', 'Exp-Layer 3', 'Layer 4'};
    end
end

% Function to construct input file name
function inputFile = constructInputFileName(inputDir, fileTime, temperature, iTimePoint)
    inputFile = fullfile(inputDir, sprintf('GNSTi_%ddu_Level%d.csv', temperature, iTimePoint - 1));
end

