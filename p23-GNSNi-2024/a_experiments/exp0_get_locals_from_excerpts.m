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
pname = 'E:\Github\PandaData\p23_GMSNi_AGG_2024\exp_data\ebsd_ctf\';
out_dir = 'E:\Github\PandaData\p23_GMSNi_AGG_2024\exp_data\ebsd_ang\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

num_type_figures = 2;
for i_time = 4:4 %length(time_points)
    % path to files
    input_file = fullfile(pname, sprintf('Ni_%dmin_%s.ctf', time_points(i_time), local_names{4}));
    %% Import the Data
    ebsd = EBSD.load(input_file,CS,'interface','ctf',...
      'convertEuler2SpatialReferenceFrame');

    [grains, ebsd] = IdentifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);

    %% 3 - interp mesh 细化
    [xmin, xmax, ymin, ymax] = ebsd.extend; %所选区域的最下角坐标 [xmin, xmax, ymin, ymax] = ebsd.extent;
    refine_factor_x = (xmax - xmin)*4.0;
    refine_factor_y = (ymax - ymin)*4.0;
    x = linspace(xmin, xmax, refine_factor_x);
    y = linspace(ymin, ymax, refine_factor_y);
    [x,y] = meshgrid(x,y);
    xy = [x(:),y(:)].';
    ebsdMeshed = interp(ebsd,xy(1,:),xy(2,:));

    % get local 
    [xmin, xmax, ymin, ~] = ebsdMeshed.extend();
    % ebsdFilled = ebsdMeshed(inpolygon(ebsdMeshed, [xmin, ymin + 9.0, xmax, 250-9.0])); % xmin, ymin+9.0, xmax, 550-9.0
    ebsdFilled = ebsdMeshed(inpolygon(ebsdMeshed, [xmin, 142.0, xmax, 250-142])); % xmin, ymin+9.0, xmax, 550-9.0

    % Smooth and fill the grains
    alphaValues = [0.0, 1.0, 1.5];
    for fillIndex = 1:2
        [grainsFilled, ebsdFilled] = IdentifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
        F = halfQuadraticFilter;
        F.alpha = alphaValues(fillIndex);
        ebsdFilled = smooth(ebsdFilled, F, 'fill', grainsFilled);
        ebsdFilled = ebsdFilled('indexed');
    end

    [grainsFilled, ebsdFilled] = IdentifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
    figure(1)
    plot(ebsdFilled, ebsdFilled.orientations, 'coordinates', 'off', 'micronbar', 'off');
    hold on;
    plot(grainsFilled.boundary, 'linewidth', 0.8);
    hold off;

    %% 3 - interp mesh 细化
    [xmin, xmax, ymin, ymax] = ebsdFilled.extend;
    refine_factor_x = (xmax - xmin)*1.0;
    refine_factor_y = (ymax - ymin)*1.0;
    x = linspace(xmin, xmax, refine_factor_x);
    y = linspace(ymin, ymax, refine_factor_y);
    [x,y] = meshgrid(x,y);
    xy = [x(:),y(:)].';
    ebsdCoarsen = interp(ebsdFilled, xy(1,:), xy(2,:));
    [grainsCoarsen, ebsdCoarsen] = IdentifyAndSmoothGrains(ebsdCoarsen, 2.0 * degree, 60, 3.0);
    % get local 
    % [xmin, xmax, ymin, ymax] = ebsdFilled.extend();
    % ebsdLocal = ebsdFilled(inpolygon(ebsdFilled, [xmin, ymin, xmax, 550]));
    % [grainsLocal, ebsdLocal] = IdentifyAndSmoothGrains(ebsdLocal, 2.0 * degree, 60, 3.0);    

    figure(2)
    plot(ebsdCoarsen, ebsdCoarsen.orientations, 'coordinates', 'off', 'micronbar', 'off');
    hold on
    plot(grainsCoarsen.boundary, 'linewidth', 0.8);
    hold off

    % % output ctf
    % output_file = fullfile(pname, sprintf('Ni_%dmin_%s_local1.ctf', time_points(i_time), local_names{1}));
    % export_ctf(ebsdCoarsen, output_file);

    % % output ang
    % output_file = fullfile(out_dir, sprintf('Ni_%dmin_%s_local1.ang', time_points(i_time), local_names{1}));
    % export_ang(ebsdCoarsen, output_file);
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

% [grainsCoarsen(654).grainSize
% grainsCoarsen(463).grainSize
% grainsCoarsen(331).grainSize
% grainsCoarsen(278).grainSize
% grainsCoarsen(173).grainSize
% grainsCoarsen(50).grainSize]

% [grainsCoarsen(298).grainSize
% grainsCoarsen(218).grainSize
% grainsCoarsen(165).grainSize
% grainsCoarsen(136).grainSize
% grainsCoarsen(87).grainSize
% grainsCoarsen(29).grainSize]

[grainsCoarsen(120).grainSize
grainsCoarsen(79).grainSize
grainsCoarsen(1).grainSize
grainsCoarsen(1).grainSize
grainsCoarsen(39).grainSize
grainsCoarsen(16).grainSize]

[xmin, xmax, ymin, ymax] = ebsdCoarsen.extend;
A1 = (xmax-xmin)*(ymax-ymin)
A2 = sum(grainsCoarsen.grainSize)
a_factor = A1/A2
% sum(grainsCoarsen.grainSize)
