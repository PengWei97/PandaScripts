% sim21_draw_kinetic.m
%
% Purpose:
% This script processes kinetic data from CSV files and visualizes the average grain diameter
% over time for different temperatures. It creates line plots for each temperature.
%
% Usage:
% Simply run this script to generate the kinetic plots for each temperature.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define temperatures
temperatures = [550, 700];

% Visualization parameters
fontSizeXY = 20; % Font size for axes
fontSizeLegend = 20; % Font size for legend
fontSizeLabelTitle = 22;
lineWidth = 2; % Line width
markerSize = 80;
colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
lineStyles = {'-', '-', '--', ':', '-.', '-', '-', '--', ':', '-.', '-'};
markers = {'o','>','s','h','p','*','^','v','d','<'};

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, localRegion] = setDirectoriesAndTimes(iTemperature);

    figure(iTemperature)
    hold on
    box on

    for iTimePoint = 1:length(fileTimes)
        % Construct input file name for kinetics data
        inputFileKinetic = fullfile(inputDir, 'csv_kinetics', sprintf('Ti%ddu_kinetics_%s.csv', temperatures(iTemperature), localRegion{1}));
        kineticsTable = readtable(inputFileKinetic);

        x = kineticsTable.Time / 60;
        y = kineticsTable.WeightedAverageGrainRadius * 2;

        lengthName = sprintf('Sim-%d \circC', temperatures(iTemperature));
        % Plot the kinetic data
        plot(x, y, ...
            'Color', colors{iTemperature}, ...
            'LineWidth', lineWidth, ...
            'LineStyle', lineStyles{iTemperature}, ...
            'DisplayName', lengthName);
    end
    xlabel('Time (min)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');
    ylabel('Average diameter (\mum)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');
    legend('FontSize', fontSizeLegend, 'TextColor', ...
        'black', 'Location', 'northeast', 'NumColumns', 2);
    xlim([0, 500]);

    set(gca, 'FontSize', fontSizeXY, ...
        'LineWidth', lineWidth, ...
        'FontName', 'Times New Roman');

    figWidth = 14.8;
    figHeight = 13.02;
    set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight]);
    set(gcf, 'Color', 'None'); % Set figure window color to transparent
    set(gca, 'Color', 'None'); % Set axes background color to transparent
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, localRegion] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')

    localRegion = {'level23'};
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti550du\csv2\';
        fileTimes = {'120min', '240min', '360min', '480min'};
        timePoints = [120.0, 240.0, 360.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti700du\csv2\';
        fileTimes = {'30min', '60min', '90min', '120min'};
        timePoints = [30.0, 60.0, 90.0, 120.0];
    end
end
