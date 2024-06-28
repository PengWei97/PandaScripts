% exp34_draw_kinetics.m
%
% Purpose:
% This script visualizes the kinetics data from CSV files. It plots the average grain diameter
% against time for different temperature levels and regions, including error bars.
%
% Usage:
% Simply run this script to generate the kinetics plots.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Add the functions directory to the MATLAB path
fullScriptPath = mfilename('fullpath');
functionsPath = fullfile(fileparts(fullScriptPath), '../functions');
addpath(functionsPath);

% Define temperatures and crystal symmetries
temperatures = [550, 700];
localRegions = {'global', 'level1', 'level2', 'level3', 'level4'};
legendNames = {'Global', 'Layer 1', 'Layer 2', 'Layer 3', 'Layer 4'};

% Visualization parameters
colors = {'#0085c3', '#14d4f4', '#f2af00', '#b7295a', '#00205b'};
lineStyles = {'-', '-', '--', ':', '-.'};
markers = {'o', '>', 's', 'h', 'p'};
fontSizeXY = 20;
fontSizeLegend = 20;
fontSizeLabelTitle = 18;
lineWidth = 2;
markerSize = 80;

figureHeights = linspace(11.0, 13.0, 5);

for iTest = 1:length(figureHeights)
    % Main loop to process each temperature point
    for iTemperature = 1:length(temperatures)

        % Set input directory and time points
        [inputDir, fileTimes, timePoints, figWidth, figHeight, yMax] = setDirectoriesAndTimes(iTemperature);

        figure(iTemperature)
        box on
        hold on
        for iBoxNum = 1:length(localRegions)

            % Set input file name
            inputFileCsv = fullfile(inputDir, 'csv_kinetics', sprintf('Ti%ddu_kinetics_%s.csv', temperatures(iTemperature), localRegions{iBoxNum}));
            kineticsTable = readtable(inputFileCsv);

            x = kineticsTable.Time / 60;
            y = kineticsTable.WeightedAverageGrainRadius * 2;
            yStd = kineticsTable.WeightedStd / 4;

            % Plot the data
            plot(x, y, ...
                'Color', colors{iBoxNum}, ...
                'LineWidth', lineWidth + 1, ...
                'LineStyle', lineStyles{iBoxNum}, ...
                'HandleVisibility', 'off');

            errorbar(x, y, yStd, ...
                'Color', colors{iBoxNum}, ...
                'LineWidth', lineWidth, ...
                'LineStyle', 'none', ...
                'Marker', markers{iBoxNum}, ...
                'MarkerEdgeColor', colors{iBoxNum}, ...
                'MarkerFaceColor', colors{iBoxNum}, ...
                'MarkerSize', 5, ...
                'DisplayName', legendNames{iBoxNum});
        end

        if iTemperature == 1
            set(gca, 'XAxisLocation', 'top');
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
        ylim([0 yMax])
        xlim([0 500])

        set(gca, 'FontSize', fontSizeXY, ...
            'LineWidth', lineWidth, ...
            'FontName', 'Times New Roman');

        set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight])
        set(gcf, 'Color', 'None'); % Set figure window color to transparent
        set(gca, 'Color', 'None'); % Set axes background color to transparent
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, figWidth, figHeight, yMax] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
        figWidth = 17.8;
        figHeight = 13.55;
        yMax = 60;
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv2\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
        figWidth = 17.8;
        figHeight = 10.5778;
        yMax = 82;
    end
end
