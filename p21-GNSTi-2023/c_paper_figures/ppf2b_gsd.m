% ppf2b_gsd.m
%
% Purpose:
% This script processes EBSD data at different temperatures and levels.
% It identifies and smooths grains, calculates grain size distribution statistics, and exports the data to CSV files.
%
% Usage:
% Simply run this script to process the data and generate CSV files for kinetics and statistics.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Add the functions directory to the MATLAB path
fullScriptPath = mfilename('fullpath');
functionsPath = fullfile(fileparts(fullScriptPath), '../functions');
addpath(functionsPath);

inputCSVFile = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\csv_initial\grain_size_TEM_surface.csv';
GrainDataTable = readtable(inputCSVFile);

GrainArea = (GrainDataTable.grain_diameter/2).^2 * pi;
[WeightedAverageGrainRadius, GrainNumber, WeightedStd] = calculatedKinetics(GrainArea, sum(GrainArea));

% Create statistics table - number fraction
[grainSizeDistribution, edges] = createdStatistics(29, 2.5);
grainSizeDistribution = calculatedGrainSizeDistribution(GrainArea, sum(GrainArea), edges, grainSizeDistribution);

% draw the grain size distribution
x = grainSizeDistribution.grainSize .* WeightedAverageGrainRadius .* 2;
y = grainSizeDistribution.areaFraction .* 100;

figure;
fontSizeLabelTitle = 14;
figWidth = 7.53; 
figHeight = 6.7;
bar(x, y, ...
  'FaceColor', '#b7295a', ...
  'EdgeColor', 'k', ...
  'LineWidth', 0.5, ... 
  'BarWidth', 0.8, ...
  'FaceAlpha', 1.0);
  hold on

% 计算数据的平均值和标准差
mu = WeightedAverageGrainRadius .* 2 * 0.9 %sum(x .* y) / sum(y);
sigma = sqrt(sum(y .* (x - mu).^2) / sum(y));

% 生成正态分布数据
x_range = linspace(0, max(x), 100); % 生成密集的晶粒尺寸范围
normal_curve = normpdf(x_range, mu, sigma); % 计算正态分布概率密度

% 归一化正态分布曲线以适配条形图高度
normal_curve = normal_curve * max(y) / max(normal_curve);

% 添加正态分布曲线到图中
plot(x_range, normal_curve, 'r', 'LineWidth', 2);

xlabel('Grain Size (nm)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
ylabel('Fraction (%)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
set(gca, 'FontSize', 12, ...
  'LineWidth', 1.0, ...
  'FontName', 'Times New Roman'); % Set x and y axes

set(gcf, 'Unit', 'centimeters', 'Position', [0, 0, figWidth, figHeight])  
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent