% sim22_draw_statistic.m
%
% Purpose:
% This script processes statistical data from CSV files and visualizes the grain size distribution
% for different time points and temperatures. It creates bar plots for the area fraction of grain sizes.
%
% Usage:
% Simply run this script to generate the grain size distribution plots for each temperature and time point.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define temperatures
temperatures = [550, 700];

% Visualization parameters
figWidth = 16; 
figHeight = 18 * 0.618;
fontSizeLabelTitle = 18;
barWidths = linspace(1.0, 0.5, 4);
colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, localRegion] = setDirectoriesAndTimes(iTemperature);

    figure(iTemperature)
    hold on
    box on

    for iTimePoint = 1:length(fileTimes)
        % Construct input file name for statistics
        inputFileGsd = fullfile(inputDir, 'csv_Statistics', sprintf('Ti%ddu_statistics_%s_%s.csv', temperatures(iTemperature), localRegion{1}, fileTimes{iTimePoint}));
        statisticsTable = readtable(inputFileGsd);
        
        x = statisticsTable.grainSize;
        y = statisticsTable.areaFraction;

        lengthName = sprintf('%d min', timePoints(iTimePoint));
        % Plot the bar graph
        bar(x, y,...
            'FaceColor', colors{iTimePoint},...
            'EdgeColor', 'k',...
            'LineWidth', 0.5,... 
            'BarWidth', barWidths(iTimePoint),...
            'FaceAlpha', 1.0,...
            'DisplayName', lengthName);
    end
    xlim([0, 2.5]);
    ylim([0, 0.15]);
    xlabel('R/<R>',...
            'FontSize', fontSizeLabelTitle,...
            'FontWeight', 'bold',...
            'Color', 'k',...
            'FontName', 'Times New Roman');
    ylabel('Area Fraction',...
            'FontSize', fontSizeLabelTitle,...
            'FontWeight', 'bold',...
            'Color', 'k',...
            'FontName', 'Times New Roman');
    set(gca, 'FontSize', 16,...
            'LineWidth', 2.0,...
            'FontName', 'Times New Roman'); % Set x and y axes
    
    set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight])
    legend('FontSize', 18, 'TextColor', 'black', 'Location', 'northeast', 'NumColumns', 2);
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
