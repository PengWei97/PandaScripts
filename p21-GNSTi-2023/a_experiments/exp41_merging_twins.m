% exp41_merging_twins.m
%
% Purpose:
% This script processes EBSD data at different temperatures and time points. It identifies and
% smooths grains, identifies grain boundaries, and merges grains along twin boundaries.
%
% Usage:
% Simply run this script to process the data and generate the results.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define temperatures and regions
temperatures = [550, 700];
localRegions = {'global', 'level1', 'level2', 'level3', 'level4', 'level23'};

for iTemperature = 2:2
    if iTemperature == 1
        % Define directories and filenames for 550°C
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf_refine\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf_levels\';
        outputDirCsvStatistic = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\csv_areaFraction\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        % Define directories and filenames for 700°C
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_refine\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_levels\';
        outputDirCsvStatistic = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\csv_areaFraction\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end

    % Define crystal symmetry
    crystalSymmetries = {
        'notIndexed',...
        crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

    % Main loop to process each time point
    for i = 1:length(fileTimes)
        % Construct input filename
        if iTemperature == 1
            inputFile = fullfile(inputDir, sprintf('Ti550du_%s_excerpt_refined2.ctf', fileTimes{i}));
        else
            inputFile = fullfile(inputDir, sprintf('Ti700du_%s_excerpt_refined.ctf', fileTimes{i}));
        end
        
        % Set MTEX preferences
        setMTEXPreferences(i, iTemperature);

        % Load EBSD data
        ebsd = EBSD.load(inputFile, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');
        [grains, ebsd] = identifyAndSmoothGrains(ebsd, 1.0 * degree, 30, 3);        

        % Identify twin boundaries
        [twinBoundary1, twinBoundary2, ~, ~] = identifyGrainBoundaries(grains, ebsd);
        twinBoundary = [twinBoundary1 twinBoundary2];

        % Merge grains along twin boundaries
        [mergedGrains, parentId] = merge(grains, twinBoundary);
    end
end

% Function to set MTEX preferences
function setMTEXPreferences(index, iTemperature)
    if iTemperature == 1
        setMTEXpref('zAxisDirection', 'outOfPlane'); 
        setMTEXpref('xAxisDirection', 'west'); 
        if ismember(index, [2, 3])
            setMTEXpref('xAxisDirection', 'east'); 
        end
    else
        setMTEXpref('zAxisDirection', 'outOfPlane'); 
        setMTEXpref('xAxisDirection', 'east'); 
        if ismember(index, [3, 4])
            setMTEXpref('xAxisDirection', 'west'); 
        end
    end
end


