% sim11_get_kinetic_statistic_from_csv.m
%
% Purpose:
% This script processes kinetic data from CSV files and generates statistics for grain volumes.
% It creates tables for the weighted average grain radius, grain number, and weighted standard deviation.
%
% Usage:
% Simply run this script to generate the kinetic and statistical data tables from the CSV files.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Add the functions directory to the MATLAB path
fullScriptPath = mfilename('fullpath');
functionsPath = fullfile(fileparts(fullScriptPath), '../functions');
addpath(functionsPath);

% Define temperatures and local regions
temperatures = [550, 700];
localRegion = {'level23'};

% Main loop to process each temperature point
for iTemperature = 2:length(temperatures)
    % Set input directory and time points
    [inputDir, fileTimes, timePoints, outputDir, addTimePoints, simCase] = setDirectoriesAndTimes(iTemperature);

    % Load total data
    inputFileTotal = fullfile(inputDir, sprintf('out_%s.csv', simCase));
    totalData = readtable(inputFileTotal);
    time = totalData.time / 60;

    % Flag to determine if kinetics should be calculated
    isGetKinetic = false;
    if isGetKinetic
        % Create table for storing kinetic data
        csvFilename = dir([inputDir, '*.csv']);
        kineticsTable = table('Size', [length(time), 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', {'Time', 'WeightedAverageGrainRadius', 'GrainNumber', 'WeightedStd'});
        kineticsTable.Time = time;
        for iTimePoint = 2:length(time)
            disp(iTimePoint);
            csvData = readtable(fullfile(inputDir, sprintf('out_%s_grain_volumes_%04d.csv', simCase, iTimePoint - 1)));
            grainVolumes = csvData.feature_volumes(csvData.feature_volumes > 0.0);

            % Calculate and store kinetic data
            boxArea = sum(grainVolumes);
            if boxArea == 0
                continue;
            end

            [kineticsTable.WeightedAverageGrainRadius(iTimePoint), kineticsTable.GrainNumber(iTimePoint), kineticsTable.WeightedStd(iTimePoint)] = calculateKinetics(grainVolumes, boxArea);
        end

        % Save kinetic data table
        outputFileKinetic = fullfile(outputDir, 'csv_kinetics', sprintf('Ti%ddu_kinetics_%s.csv', temperatures(iTemperature), localRegion{1}));
        if ~exist(fileparts(outputFileKinetic), 'dir')
            mkdir(fileparts(outputFileKinetic));
        end
        writetable(kineticsTable, outputFileKinetic);
    end

    % Find closest time points
    [~, closeIndex] = min(abs(time - timePoints + addTimePoints));
    for iTimePoints = 1:length(closeIndex)
        inputFileCsv = fullfile(inputDir, sprintf('out_%s_grain_volumes_%04d.csv', simCase, closeIndex(iTimePoints)));

        % Read CSV file
        data = readtable(inputFileCsv);
        grainVolumes = data.feature_volumes(data.feature_volumes > 0.0);
        boxArea = sum(grainVolumes);

        % Create statistical tables for number and area fractions
        [grainSizeDistribution, edges, ~] = createGrainSizeDistribution(29, 2.5);
        grainSizeDistribution.numFraction = getGrainSizeDistribution(grainVolumes, boxArea, edges, 'numFraction');
        grainSizeDistribution.areaFraction = getGrainSizeDistribution(grainVolumes, boxArea, edges, 'areaFraction');

        % Save statistical tables
        outputFileGsd = fullfile(outputDir, 'csv_Statistics', sprintf('Ti%ddu_statistics_%s_%s.csv', temperatures(iTemperature), localRegion{1}, fileTimes{iTimePoints}));
        if ~exist(fileparts(outputFileGsd), 'dir')
            mkdir(fileparts(outputFileGsd));
        end
        disp(outputFileGsd);
        writetable(grainSizeDistribution, outputFileGsd);
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, outputDir, addTimePoints, simCase] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti550du\csv_case4_recovery_v2\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti550du\csv2\';
        fileTimes = {'120min', '240min', '360min', '480min'};
        timePoints = [120.0, 240.0, 360.0, 480.0];
        addTimePoints = 120.0;
        simCase = 'case4_recovery_v2';
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti700du\csv_case4_recovery_v9\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti700du\csv2\';
        fileTimes = {'30min', '60min', '90min', '120min'};
        timePoints = [30.0, 60.0, 90.0, 120.0];
        addTimePoints = 30.0;
        simCase = 'case4_recovery_v9';
    end
end
