% exp3_draw_gb_distribution.m
%
% Purpose:
% This script processes EBSD data for different time points and visualizes the grain boundary maps.
% It identifies and smooths grains, then plots the grain boundaries.
%
% Usage:
% Simply run this script to generate the grain boundary maps and save them as BMP files.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define input and output directories
inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf';
outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\bmp';

% Define file times
fileTimes = {'30min', '120min', '240min', '480min'};

% Define crystal symmetry
crystalSymmetries = {... 
  'notIndexed',...
  crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

% Main loop to process each time point
for i = 1:length(fileTimes)
    inputFileName = fullfile(inputDir, sprintf('Ti550du_%s_excerpt2.ctf', fileTimes{i}));

    % Set MTEX preferences
    setMTEXpref('zAxisDirection', 'outOfPlane'); 
    setMTEXpref('xAxisDirection', 'west'); 

    if ismember(i, [2, 3])
        setMTEXpref('xAxisDirection', 'east'); 
    end

    % Load EBSD data
    ebsd = EBSD.load(inputFileName, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

    % Identify and smooth grains
    [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', 2 * degree);
    grains = smooth(grains, 50);
    ebsd(grains(grains.grainSize < 3)) = [];
    [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', 2 * degree); 
    grains = smooth(grains, 50);

    % Visualize grain boundary map
    figure(i);
    plot(grains.boundary, 'linewidth', 0.1, 'micronbar', 'off');

    % Save the plot as a BMP file
    outputFileName = fullfile(outputDir, sprintf('Ti550du_%s_excerpt_gb', fileTimes{i}));
    print(outputFileName, '-dbmp', '-r600');
end
