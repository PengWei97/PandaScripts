% exp36_draw_gsd_distribution.m
%
% Purpose:
% This script visualizes the grain size distribution (GSD) from CSV files. It plots the area fraction
% against normalized grain size for different temperature levels and regions.
%
% Usage:
% Simply run this script to generate the GSD plots.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define temperatures and crystal symmetries
temperatures = [550, 700];

% Visualization parameters
figWidth = 16; 
figHeight = 18 * 0.618;
fontSizeLabelTitle = 18;
barWidths = linspace(1.0, 0.5, 4);
colors = {'#0085c3', '#14d4f4', '#f2af00', '#b7295a', '#00205b', '#009f4d', '#84bd00', '#efdf00', '#e4002b', '#a51890'};

% Main loop to process each temperature point
for iTemperature = 2:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, localRegions] = setDirectoriesAndTimes(iTemperature);

    for iBoxNum = 4:4 %1:length(localRegions)
        figure(iBoxNum)
        hold on
        box on
        for iTimePoint = 1:length(fileTimes)
            % Construct input file name for statistics
            inputFileGsd = fullfile(inputDir, 'csv_Statistics', sprintf('Ti%ddu_statistics_%s_%s.csv', temperatures(iTemperature), localRegions{iBoxNum}, fileTimes{iTimePoint}));
            statisticsTable = readtable(inputFileGsd);
            
            x = statisticsTable.grainSize;
            y = statisticsTable.areaFraction;

            timeLabel = strcat(num2str(timePoints(iTimePoint)), ' min');
            % Plot the data
            bar(x, y, ...
                'FaceColor', colors{iTimePoint}, ...
                'EdgeColor', 'k', ...
                'LineWidth', 0.5, ... 
                'BarWidth', barWidths(iTimePoint), ...
                'FaceAlpha', 1.0, ...
                'DisplayName', timeLabel);
        end
        xlim([0, 2.5]);
        ylim([0, 0.2]);
        xlabel('R/<R>', ...
                'FontSize', fontSizeLabelTitle, ...
                'FontWeight', 'bold', ...
                'Color', 'k', ...
                'FontName', 'Times New Roman');
        ylabel('Area Fraction', ...
              'FontSize', fontSizeLabelTitle, ...
              'FontWeight', 'bold', ...
              'Color', 'k', ...
              'FontName', 'Times New Roman');
        set(gca, 'FontSize', 16, ...
                'LineWidth', 2.0, ...
                'FontName', 'Times New Roman'); % Set x and y axes
        
        set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight])
        legend('FontSize', 18, 'TextColor', 'black', 'Location', 'northeast', 'NumColumns', 2);
        set(gcf, 'Color', 'None'); % Set figure window color to transparent
        set(gca, 'Color', 'None'); % Set axes background color to transparent
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, localRegions] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')

    localRegions = {'global', 'level1', 'level2', 'level3', 'level4', 'level23'};
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv2\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end
end
