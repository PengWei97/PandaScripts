% ppf5ac_gnd_maps.m
%
% Purpose:
% This script processes EBSD data to visualize dislocation density maps for different temperatures.
% It generates maps of dislocation density for specified time points.
%
% Usage:
% Simply run this script to generate the dislocation density maps for each temperature and time point.

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
crystalSymmetries = {...
    'notIndexed', ...
    crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

% Main loop to process each temperature point
for iTemperature = 1:length(temperatures)

    % Set input directory and time points
    [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(iTemperature);

    % Main loop to process each time point
    for iTimePoint = 1:length(fileTimes)
        % Construct input file name
        inputFile = constructInputFileName(inputDir, fileTimes{iTimePoint}, temperatures(iTemperature));

        % Set MTEX preferences
        setMTEXPreferences(iTimePoint, iTemperature);

        % Load EBSD data
        ebsd = EBSD.load(inputFile, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

        % Calculate GNDs
        ebsdGrid = ebsd('indexed').gridify;
        rho = calculateGNDs(ebsdGrid);

        % Visualize GNDs map
        figure(length(temperatures) * (iTimePoint - 1) + iTimePoint);
        plot(ebsdGrid, rho, 'micronbar', 'on', 'coordinates', 'off');
        mtexColorMap('jet');
        set(gca, 'ColorScale', 'log');
        set(gca, 'CLim', [2.0e10 2.5e15]); % Adjust the color limits as needed
        mtexColorbar('title', 'Dislocation Density (1/m^2)');
        hold on;
        plot(grains.boundary, 'linewidth', 0.8);
        hold off;
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(iTemperature)
    disp('Setting directories and times')
    if iTemperature == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_refine\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to construct input file name
function inputFile = constructInputFileName(inputDir, fileTime, temperature)
    inputFile = fullfile(inputDir, sprintf('Ti%ddu_%s_excerpt.ctf', temperature, fileTime));
end

% Function to set MTEX preferences
function setMTEXPreferences(index, iTemperature)
    setMTEXpref('zAxisDirection', 'outOfPlane');
    if iTemperature == 1
        setMTEXpref('xAxisDirection', 'west');
        if ismember(index, [2])
            setMTEXpref('xAxisDirection', 'east');
            disp('east');
        end
    else
        setMTEXpref('xAxisDirection', 'east');
        if ismember(index, [3, 4])
            setMTEXpref('xAxisDirection', 'west');
        end
    end
end

% Function to calculate dislocation density
function rho = calculateGNDs(ebsdInterp)
    cs = ebsdInterp.CS;

    % Define crystal slip systems
    sSBasalSym  = slipSystem.basal(cs).symmetrise('antipodal'); % Basal slip
    sSPrismSym  = slipSystem.prismaticA(cs).symmetrise('antipodal'); % Prismatic slip
    sSPyrIASym  = slipSystem.pyramidalA(cs).symmetrise('antipodal'); % First order pyramidal slip
    sSPyrIACSym = slipSystem.pyramidalCA(cs).symmetrise('antipodal');
    sSPyrIIACSym = slipSystem.pyramidalCA2(cs).symmetrise('antipodal'); % Second order pyramidal slip

    slipSystemsAll = {sSBasalSym, sSPrismSym, sSPyrIASym, sSPyrIACSym, sSPyrIIACSym};
    slipSystemsAllSym = [];
    for iNumSlip = 1:length(slipSystemsAll)
        for j = 1:length(slipSystemsAll{iNumSlip})
            slipSystemsAllSym = [slipSystemsAllSym; slipSystemsAll{iNumSlip}(j)];
        end
    end

    % Dislocation density tensor
    dS = dislocationSystem(slipSystemsAllSym);
    dSRot = ebsdInterp.orientations * dS;
    kappa = ebsdInterp.curvature;
    [rhoSingle, factor] = fitDislocationSystems(kappa, dSRot);
    alpha = sum(dSRot.tensor .* rhoSingle, 2);
    alpha.opt.unit = '1/um';

    rho = sqrt(0.5 * sum(rhoSingle.^2, 2));
end
