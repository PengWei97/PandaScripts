% ppf4bd_gb_distro_maps.m
%
% Purpose:
% This script visualizes the grain boundary (GB) distribution from EBSD data files. It identifies
% and smooths grains, plots the IPF maps, and identifies various types of grain boundaries.
%
% Usage:
% Simply run this script to generate the grain boundary distribution plots.

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
localRegions = {'global', 'level1', 'level2', 'level3', 'level4', 'level23'};
crystalSymmetries = {
    'notIndexed', ...
    crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(iTemperature);

    for iTimePoint = 1:length(timePoints)
        % Construct input file name
        inputFileCtf = fullfile(inputDir, sprintf('Ti%ddu_%s_global.ctf', temperatures(iTemperature), fileTimes{iTimePoint}));
        
        % Set MTEX preferences
        setMTEXPreferences(iTimePoint, iTemperature);
        
        % Load EBSD data
        ebsd = EBSD.load(inputFileCtf, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

        % Identify and smooth grains
        [grains, ebsd] = identifyAndSmoothGrains(ebsd, 1.0 * degree, 50, 10.0);

        % Visualize IPF map
        figure(2 * length(timePoints) * (iTemperature - 1) + iTimePoint);
        plot(ebsd, ebsd.orientations, 'coordinates', 'off', 'micronbar', 'on');
        hold on;
        plot(grains.boundary, 'linewidth', 0.8);
        hold off;

        % Identify grain boundaries
        [twinBoundary1, twinBoundary2, lowAngleGB, highAngleGB] = identifyGBs(grains, ebsd);

        % Plot and export grain boundary maps
        figureIndex = length(timePoints) * (iTemperature - 1) + iTimePoint;
        plotGrainBoundaryMaps(lowAngleGB, highAngleGB, twinBoundary1, twinBoundary2, figureIndex);
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf2\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv2\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf2\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv2\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to set MTEX preferences
function setMTEXPreferences(index, iTemperature)
    setMTEXpref('zAxisDirection', 'outOfPlane');
    if iTemperature == 1
        setMTEXpref('xAxisDirection', 'west');
        if ismember(index, [2, 3])
            setMTEXpref('xAxisDirection', 'east');
        end
    else
        setMTEXpref('xAxisDirection', 'east');
        if ismember(index, [3, 4])
            setMTEXpref('xAxisDirection', 'west');
        end
    end
end

% Function to plot grain boundary maps
function plotGrainBoundaryMaps(lowAngleGB, highAngleGB, twinBoundary1, twinBoundary2, figureIndex)
    figure(figureIndex);
    plot(highAngleGB, 'linecolor', 'Black', 'linewidth', 1, 'displayName', 'High angle grain boundary');
    hold on;
    plot(lowAngleGB, 'linecolor', 'Indigo', 'linewidth', 1.5, 'displayName', 'Low angle grain boundary');
    plot(twinBoundary1, 'linecolor', 'Blue', 'linewidth', 3, 'displayName', 'Compression twin boundary');
    plot(twinBoundary2, 'linecolor', 'Red', 'linewidth', 3, 'displayName', 'Tensile twin boundary');
    hold off;

    lgd = legend('FontSize', 18, 'TextColor', 'black', 'Location', 'southeast', 'NumColumns', 1, 'FontName', 'Times New Roman');
    set(lgd, 'Visible', 'off');
end
