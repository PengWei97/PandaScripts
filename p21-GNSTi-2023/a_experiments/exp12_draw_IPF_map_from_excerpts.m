% This script processes EBSD (Electron Backscatter Diffraction) data for
% specific temperature and time points, visualizes the results, and 
% extracts a specific map for each condition.

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
for i_temperature = 1:length(temperatures)

    % Set input directory and time points
    [input_dir, file_times, time_points, output_dir] = SetDirectoriesAndTimes(i_temperature);

    % Initialize the region density array
    rho_region = zeros(length(file_times), 2);

    % Main loop to process each time point
    for i_time_point = 1:length(file_times)
        % Construct input file name
        input_file = ConstructInputFileName(input_dir, file_times{i_time_point}, temperatures(i_temperature));

        % Set MTEX preferences
        SetMTEXPreferences(i_time_point, i_temperature);

        % Load EBSD data
        ebsd = EBSD.load(input_file, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

        % Visualize IPF map
        figure(i_time_point);
        plot(ebsd, ebsd.orientations, 'coordinates', 'on', 'micronbar', 'on');
    end
end

% Function to set input directories and time points
function [input_dir, file_times, time_points, output_dir] = SetDirectoriesAndTimes(i_temperature)
    disp('Setting directories and times')
    if i_temperature == 1
        input_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf\';
        output_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\';
        file_times = {'30min', '120min', '240min', '480min'};
        time_points = [30.0, 120.0, 240.0, 480.0];
    else
        input_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_refine\';
        output_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\';
        file_times = {'10min', '30min', '60min', '120min'};
        time_points = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to construct input file name
function input_file = ConstructInputFileName(input_dir, file_time, temperature)
    input_file = fullfile(input_dir, sprintf('Ti%ddu_%s_excerpt.ctf', temperature, file_time));
end

% Function to set MTEX preferences
function SetMTEXPreferences(index, i_temperature)
    setMTEXpref('zAxisDirection', 'outOfPlane');
    if i_temperature == 1
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
