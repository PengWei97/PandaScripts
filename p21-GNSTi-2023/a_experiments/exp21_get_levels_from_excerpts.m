% This script processes EBSD (Electron Backscatter Diffraction) data, 
% identifies and smoothens grains, and exports the processed data at 
% different levels.

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
localRegions = {'global', 'level1', 'level2', 'level3', 'level4', 'level23'};

% Define crystal symmetries
crystalSymmetries = {...
    'notIndexed', ...
    crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', ...
    'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

% Main loop to process each temperature point
for i_temperature = 1:length(temperatures)
    % Set input directory and time points
    [input_dir, file_times, time_points, output_dir] = SetDirectoriesAndTimes(i_temperature);

    % Loop to process each time point
    for i_time_point = 1:length(file_times)
        fprintf('Processing time point %d at temperature %d\n', i_time_point, temperatures(i_temperature));
        
        % Construct input file name
        input_file = ConstructInputFileName(input_dir, file_times{i_time_point}, temperatures(i_temperature));
        
        % Set MTEX preferences
        SetMTEXPreferences(i_time_point, i_temperature);
        
        % Load EBSD data
        ebsd = EBSD.load(input_file, crystalSymmetries, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');
        
        % Fill and smooth grains
        ebsd_filled = ebsd;
        [grains_filled, ebsd_filled] = identifyAndSmoothGrains(ebsd, 2.0 * degree, 60, 3.0);
        
        % Visualize IPF map
        figure(i_time_point);
        plot(ebsd_filled, ebsd_filled.orientations, 'coordinates', 'off', 'micronbar', 'on');
        hold on;
        plot(grains_filled.boundary, 'linewidth', 0.8);
        hold off;
        
        % Define size boxes for different levels
        [xmin, xmax, ymin, ymax] = ebsd_filled.extend;
        size_boxes = defineSizeBoxes(i_time_point, xmin, xmax, ymin, ymax, i_temperature);
        
        % Loop to process each level
        for i_box_num = 1:length(size_boxes)
            if i_box_num == 1
                ebsd_level = ebsd_filled;
            else
                ebsd_level = ebsd_filled(inpolygon(ebsd_filled, size_boxes(i_box_num - 1, :)));
            end
            
            % Visualize IPF map for the level
            figure(length(file_times) * length(size_boxes) + i_box_num);
            plot(ebsd_level, ebsd_level.orientations, 'coordinates', 'off', 'micronbar', 'on');
            hold on;
            
            % Export level EBSD data
            output_file = fullfile(output_dir, 'ctf2/' ,sprintf('Ti%ddu_%s_%s.ctf', temperatures(i_temperature), file_times{i_time_point}, localRegion{i_box_num}));
            
            % Create directory if it does not exist
            if ~exist(fileparts(output_file), 'dir')
                mkdir(fileparts(output_file));
            end
            
            export_ctf(ebsd_level, output_file);
        end
    end
end

% Function to set input directories and time points
function [input_dir, file_times, time_points, output_dir] = SetDirectoriesAndTimes(i_temperature)
    disp('Setting directories and times')
    if i_temperature == 1
        input_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\ctf_filling\';
        output_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\';
        file_times = {'30min', '120min', '240min', '480min'};
        time_points = [30.0, 120.0, 240.0, 480.0];
    else
        input_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf\';
        output_dir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\';
        file_times = {'10min', '30min', '60min', '120min'};
        time_points = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to construct input file name
function input_file = ConstructInputFileName(input_dir, file_time, temperature)
    if temperature == 550
        input_file = fullfile(input_dir, sprintf('Ti%ddu_%s_filled.ctf', temperature, file_time));
    else
        input_file = fullfile(input_dir, sprintf('Ti%ddu_%s_excerpt.ctf', temperature, file_time));
    end
end

% Function to set MTEX preferences
function SetMTEXPreferences(index, i_temperature)
    setMTEXpref('zAxisDirection', 'outOfPlane');
    if i_temperature == 1
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

% Function to define size boxes based on iteration index
function size_boxes = defineSizeBoxes(i_time_point, x_min, x_max, y_min, y_max, i_temperature)
    if i_temperature == 1 % 550
        if ismember(i_time_point, [2, 3])
            size_boxes = [
                x_min, 574.42, x_max - x_min, y_max - 574.42;
                x_min, 423.38, x_max - x_min, 574.42 - 423.38;
                x_min, 212.93, x_max - x_min, 423.38 - 212.93;
                x_min, y_min, x_max - x_min, 212.93 - y_min;
                x_min, 212.93, x_max - x_min, 574.42 - 212.93];
        else
            size_boxes = [
                x_min, y_min, x_max - x_min, 66.21;
                x_min, 66.21, x_max - x_min, 215.80 - 66.21;
                x_min, 215.80, x_max - x_min, 424.25 - 215.80;
                x_min, 424.25, x_max - x_min, y_max - 424.25;
                x_min, 66.21, x_max - x_min, 424.25 - 66.21];
        end
    else % 700
        if ismember(i_time_point, [1, 2])
            size_boxes = [
                x_min, 411.05, x_max - x_min, y_max - 411.05;
                x_min, 278.09, x_max - x_min, 411.05 - 278.09;
                x_min, 94.57, x_max - x_min, 278.09 - 94.57;
                x_min, y_min, x_max - x_min, 94.57 - y_min;
                x_min, 94.57, x_max - x_min, 411.05 - 94.57];
        else
            size_boxes = [
                x_min, y_min, x_max - x_min, 149.25;
                x_min, 149.25, x_max - x_min, 281.72 - 149.25;
                x_min, 281.72, x_max - x_min, 464.55 - 281.72;
                x_min, 464.55, x_max - x_min, y_max - 464.55;
                x_min, 149.25, x_max - x_min, 464.55 - 149.25];
        end
    end
end
