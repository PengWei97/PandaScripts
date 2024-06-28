% exp33_get_csv_data_from_levels.m
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

    for iBoxNum = 1:length(localRegions)
        % Create table to store kinetics data
        kineticsTable = table('Size', [length(timePoints), 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', {'Time', 'WeightedAverageGrainRadius', 'GrainNumber', 'WeightedStd'});

        for iTimePoint = 1:length(fileTimes)
            % Construct input file name
            inputFileCtf = fullfile(inputDir, sprintf('Ti%ddu_%s_%s.ctf', temperatures(iTemperature), fileTimes{iTimePoint}, localRegions{iBoxNum}));

            % Set MTEX preferences
            setMTEXPreferences(iTimePoint, iTemperature);

            % Load EBSD data
            ebsd = EBSD.load(inputFileCtf, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

            % Identify and smooth grains
            [grains, ebsd] = identifyAndSmoothGrains(ebsd, 1.0 * degree, 50, 10.0);

            % Visualize IPF map
            figure(length(localRegions) * (iBoxNum - 1) + 2 * iTimePoint - 1);
            plot(ebsd, ebsd.orientations, 'coordinates', 'off', 'micronbar', 'on');
            hold on;
            plot(grains.boundary, 'linewidth', 0.8);

            % Get kinetics and output
            [xMin, xMax, yMin, yMax] = ebsd.extend;
            boxArea = (xMax - xMin) * (yMax - yMin);
            [kineticsTable.WeightedAverageGrainRadius(iTimePoint), kineticsTable.GrainNumber(iTimePoint), kineticsTable.WeightedStd(iTimePoint)] = calculateKinetics(grains.grainSize, boxArea);
            kineticsTable.Time(iTimePoint) = timePoints(iTimePoint) * 60;

            % Create statistics table - number fraction
            [grainSizeDistribution, edges] = createdStatistics(29, 2.5);
            grainSizeDistribution = calculatedGrainSizeDistribution(grains.grainSize, boxArea, edges, grainSizeDistribution);

            % Output statistics table
            outputFileGsd = fullfile(outputDir, 'csv_Statistics', sprintf('Ti%ddu_statistics_%s_%s.csv', temperatures(iTemperature), localRegions{iBoxNum}, fileTimes{iTimePoint}));
            if ~exist(fileparts(outputFileGsd), 'dir')
                mkdir(fileparts(outputFileGsd));
            end
            writetable(grainSizeDistribution, outputFileGsd);
        end
        
        outputFileKinetic = fullfile(outputDir, 'csv_kinetics', sprintf('Ti%ddu_kinetics_%s.csv', temperatures(iTemperature), localRegions{iBoxNum}));
        if ~exist(fileparts(outputFileKinetic), 'dir')
            mkdir(fileparts(outputFileKinetic));
        end
        writetable(kineticsTable, outputFileKinetic);
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
