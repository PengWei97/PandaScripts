% exp34_draw_misori_angle_distro.m
%
% Purpose:
% This script visualizes the misorientation angle distribution from CSV files. It plots the frequency
% of misorientation angles for different time points and regions.
%
% Usage:
% Simply run this script to generate the misorientation angle distribution plots.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define input path and filenames for 700°C experiment
inputPath = 'D:\C工作\prm2_ThermalGNS_AGG2023\p21_GNS-Ti_AGG_2023\data_and_scripts\misorientation_angle_distribution\exp_700du\';
filePathNames = {'global', 'level1', 'level2', 'level3', 'level4'};
fileCSVNames = {'10min', '30min', '60min', '120min'};
typeLegendNames = {'10 min', '30 min', '60 min', '120 min'};
yLimitMax = [12, 12, 12, 24, 15];

% Visualization parameters
colors = {'#0085c3', '#14d4f4', '#f2af00', '#b7295a', '#00205b', '#009f4d', '#84bd00', '#efdf00', '#e4002b', '#a51890'};
lineStyles = {'-', '--', ':', '-.', '-'};
markers = {'o', '>', 's', 'h', 'p', '*', '^', 'v', 'd', '<'};
legendLocations = {'north', 'northeast', 'north', 'north', 'northeast'};
fontSizeXY = 18;
fontSizeLegend = 18;
fontSizeLabelTitle = 21;
markerWidth = 8;
lineWidth = 2;
lineWidthInterp = 0.5;

% Loop over each region (global and level 1-4)
for i = 1:length(filePathNames)
    disp('*************');
    disp(filePathNames{i});
    figure(i);
    box on;
    hold on;
    for j = 1:length(fileCSVNames)
        inputFilePath = fullfile(inputPath, filePathNames{i});
        inputFileName = sprintf('%s_%s.csv', fileCSVNames{j}, filePathNames{i});
        csvData = readtable(fullfile(inputFilePath, inputFileName));

        x = csvData.x_misorientation;
        y = csvData.y_frequency;

        scatter(x, y, 80, ...
            'MarkerEdgeColor', colors{j}, ...
            'MarkerFaceColor', colors{j}, ...
            'Marker', markers{j}, ...
            'DisplayName', typeLegendNames{j});

        % Spline fitting
        fitObj = fit(x, y, 'smoothingspline', 'SmoothingParam', 0.15);

        % Interpolated curve
        xInterp = linspace(min(x), max(x), 1000);
        yInterp = feval(fitObj, xInterp);

        plot(xInterp, yInterp, ...
            'Color', colors{j}, ...
            'LineWidth', lineWidth, ...
            'LineStyle', lineStyles{j}, ...
            'HandleVisibility', 'off');
    end

    xlim([0, 95]);
    ylim([0, yLimitMax(i)]);
    set(gca, 'FontSize', fontSizeXY, ...
        'LineWidth', lineWidth, ...
        'FontName', 'Times New Roman');
    xlabel('Misorientation angle (\circ)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');
    ylabel('Frequency (%)', ...
        'FontSize', fontSizeLabelTitle, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'FontName', 'Times New Roman');

    % Set figure and axes properties
    figWidth = 17.5 * 0.9;
    figHeight = 13.0 * 0.9;
    set(gcf, 'Unit', 'centimeters', 'Position', [5, 5, figWidth, figHeight]);
    set(gcf, 'Color', 'None'); % Set figure window color to transparent
    set(gca, 'Color', 'None'); % Set axes background color to transparent
end
