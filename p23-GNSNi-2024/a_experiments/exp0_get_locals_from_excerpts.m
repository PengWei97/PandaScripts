close all
clear all
clc

% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('m-3m', [3.6 3.6 3.6], 'mineral', 'Ni-superalloy', 'color', [0.53 0.81 0.98])};

% plotting convention
setMTEXpref('xAxisDirection','west');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names
pname = 'D:\0同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_ctf\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

num_type_figures = 2;
for i_time = 2:length(time_points)
    % path to files
    input_file = fullfile(pname, sprintf('Ni_%dmin_%s.ctf', time_points(i_time), local_names{4}));
    %% Import the Data
    ebsd = EBSD.load(input_file,CS,'interface','ctf',...
      'convertEuler2SpatialReferenceFrame');
    
    continue;

    [grains, ebsd] = IdentifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);

    %% 3 - interp mesh 细化
    [xmin, xmax, ymin, ymax] = ebsd.extend; %所选区域的最下角坐标 [xmin, xmax, ymin, ymax] = ebsd.extent;
    refine_factor_x = (xmax - xmin)*1.0;
    refine_factor_y = (ymax - ymin)*1.0;
    x = linspace(xmin, xmax, refine_factor_x);
    y = linspace(ymin, ymax, refine_factor_y);
    [x,y] = meshgrid(x,y);
    xy = [x(:),y(:)].';
    ebsdMeshed = interp(ebsd,xy(1,:),xy(2,:));
    ebsdFilled = ebsdMeshed;

    figure(3*i_time - 2)
    plot(ebsdMeshed, ebsdMeshed.orientations, 'coordinates', 'off', 'micronbar', 'on');

    % Smooth and fill the grains
    alphaValues = [0.0, 1.0];
    for fillIndex = 1:2
        if fillIndex == 1
            [grainsFilled, ebsdFilled] = IdentifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
        end
        F = halfQuadraticFilter;
        F.alpha = alphaValues(fillIndex);
        ebsdFilled = smooth(ebsdFilled, F, 'fill', grainsFilled);
        ebsdFilled = ebsdFilled('indexed');

        [grainsFilled, ebsdFilled] = IdentifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
    end

    figure(3*i_time - 1)
    plot(ebsdFilled, ebsdFilled.orientations, 'coordinates', 'off', 'micronbar', 'on');
    hold on;
    plot(grainsFilled.boundary, 'linewidth', 0.8);
    hold off;

    % get local 
    [xmin, xmax, ymin, ymax] = ebsdFilled.extend();
    ebsdLocal = ebsdFilled(inpolygon(ebsdFilled, [xmin, ymin, xmax, 550]));
    [grainsLocal, ebsdLocal] = IdentifyAndSmoothGrains(ebsdLocal, 2.0 * degree, 60, 3.0);    

    figure(3*i_time)
    plot(ebsdLocal, ebsdLocal.orientations, 'coordinates', 'off', 'micronbar', 'on');
    hold on
    plot(grainsLocal.boundary, 'linewidth', 0.8);
    hold off

    % output ctf
    output_file = fullfile(pname, sprintf('Ni_%dmin_%s.ctf', time_points(i_time), local_names{3}));
    export_ctf(ebsdLocal, output_file);
end

function [grains, ebsd] = IdentifyAndSmoothGrains(ebsd, threshold, smoothFacter, minGrainSize)
  fprintf('Running IdentifyAndSmoothGrains\n');

  % Initial grain calculation
  [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', threshold);

  % Smooth the grains
  grains = smooth(grains, smoothFacter);

  % Remove grains smaller than the specified minimum size
  ebsd(grains(grains.grainSize < minGrainSize)) = [];

  % Recalculate grains after removal of small grains
  [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', threshold);

  % Smooth the grains again after recalculation
  grains = smooth(grains, smoothFacter);
end

% E:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp0_get_locals_from_excerpts.m

