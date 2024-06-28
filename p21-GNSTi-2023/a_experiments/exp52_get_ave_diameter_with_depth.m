% exp52_get_ave_diameter_with_depth.m
%
% Purpose:
% This script processes BMP images to extract and visualize the grain diameter at different depths.
% It reads grayscale images, calculates the grain diameter along the depth, and plots the results.
%
% Usage:
% Simply run this script to generate the depth vs. grain diameter plots and save them as BMP files.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define visualization parameters
colors = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
lineStyles = {'-','--',':','-.','-'};
markers = {'o','>','s','h','p','*','^','v','d','<'};
legendLocations = {'north','northeast','north','north','northeast'};
fontSizeXY = 16; % Font size for axes
fontSizeLegend = 18; % Font size for legend
fontSizeLabelTitle = 18;
markerWidth = 5; % Marker size
lineWidth = 1.0; % Line width

% Define input and output directories
outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\bmp';
fileTimes = {'30min', '120min', '240min', '480min'};
legendTimes = {'30 min', '120 min', '240 min', '480 min'};

% Define other parameters
jIndex1 = [4, 4, 4, 5];
ebsdX = 400;
ebsdY = 640;

% Loop over each time point to process images
figure;
hold on;
box on;

for iTp = 1:length(fileTimes) % Four time points
    inputFileBmp = fullfile(outputDir, sprintf('Ti550du_%s_excerpt_gb.bmp', fileTimes{iTp}));

    img = imread(char(inputFileBmp)); % Input the figure
    A = rgb2gray(img);

    % Initialize arrays to store grain diameters and depths
    xDeep = zeros(length(A(:,1)),1); % Pixel count in x direction
    grainDiameterDeep = zeros(length(A(:,1)),1); % Grain diameter in y direction
    boxSizeY = 62;

    for j = 1:length(A(:,1)) % Loop over depth
        numGrains = 0; % Reset grain count
        for i = 1:length(A(j,:))-1 % Loop over horizontal axis
            if (A(j,i) == 255 &&  A(j,i+1) ~= 255) % Detect grain boundaries
                numGrains = numGrains + 1;
            end
        end

        if (numGrains >= 1)
            numGrains = numGrains - 1; % Adjust grain count
            grainDiameterDeep(j) = ebsdX / numGrains; % Calculate grain diameter
        end

        xDeep(j) = (j - boxSizeY) / length(A(:,1)) * ebsdY; % Assign depth values
    end

    % Extract data at intervals
    jIndex = 1:jIndex1(iTp):length(xDeep);
    xDeep3 = zeros(length(jIndex), 1); % Depths
    grainDiameterDeep3 = zeros(length(jIndex), 1); % Grain diameters
    for k = 1:length(jIndex)
        xDeep3(k) = xDeep(jIndex(k));
        grainDiameterDeep3(k) = grainDiameterDeep(jIndex(k));
    end

    x = xDeep3(grainDiameterDeep3 > 0);
    y = grainDiameterDeep3(grainDiameterDeep3 > 0);

    if (iTp == 3)
        y(x < 6.77) = 5.65;
    end

    % Plot the data
    plot(y, x, ...
        'Color', colors{iTp}, ...
        'LineWidth', lineWidth + 0.5, ...
        'DisplayName', legendTimes{iTp});
end

set(gca, 'YAxisLocation', 'right');
set(gca, 'YDir', 'reverse');
set(gca, 'FontSize', fontSizeXY, ...
    'LineWidth', lineWidth + 1, ...
    'FontName', 'Times New Roman'); % Set x and y axes

xlabel('Grain diameter (\mum)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
ylabel('Depth (\mum)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');

lgd = legend('FontSize', fontSizeLegend, 'TextColor', 'black', ...
    'Location', 'northeast', ...
    'FontWeight', 'bold', ...
    'FontName', 'Times New Roman', 'NumColumns', 1); 

xlim([0, 60]);
ylim([0, 640]);

figWidth = 11.10;
figHeight = 16.00;
set(gcf, 'Unit', 'centimeters', 'Position', [10, 5, figWidth, figHeight]);
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent
