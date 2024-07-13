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
pname = 'E:\同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_ctf\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'excerpt'};

num_type_figures = 2;
for i_time = 1:1 %length(time_points)
    % path to files
    input_file = fullfile(pname, sprintf('Ni_%dmin_%s.ctf', time_points(i_time), local_names{3}));
    %% Import the Data
    ebsd = EBSD.load(input_file,CS,'interface','ctf',...
      'convertEuler2SpatialReferenceFrame');

    [grains, ebsd] = IdentifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);

    % figure(num_type_figures*i_time)
    % plot(ebsd,ebsd.orientations,'micronbar','off', 'coordinates', 'off')
    % hold on;
    % plot(grains.boundary, 'linewidth', 0.8);
    % hold off;

    % % get GOS
    % mis2mean = calcGROD(ebsd, grains);
    % GOS = ebsd.grainMean(mis2mean.angle);

    % % draw GOS distribution
    % figure(num_type_figures*i_time - 1)
    % plot(grains, GOS./degree, 'micronbar', 'on', 'coordinates', 'off')
    % mtexColorbar('title','GOS in degree')
    % % set(gca, 'CLim', [0 5]);
    % hold on;
    % plot(grains.boundary, 'linewidth', 0.8);
    % hold off;

    % draw GOS distribution v2
    % grains_

    %% 3 - interp mesh 细化
    [xmin, xmax, ymin, ymax] = ebsd.extend; %所选区域的最下角坐标 [xmin, xmax, ymin, ymax] = ebsd.extent;
    refine_factor_x = (xmax - xmin)*1.0;
    refine_factor_y = (ymax - ymin)*1.0;
    x = linspace(xmin, xmax, refine_factor_x);
    y = linspace(ymin, ymax, refine_factor_y);
    [x,y] = meshgrid(x,y);
    xy = [x(:),y(:)].';
    ebsdFilled = interp(ebsd,xy(1,:),xy(2,:));

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

    figure(2*i_time)
    plot(ebsdFilled, ebsdFilled.orientations, 'coordinates', 'off', 'micronbar', 'on');
    hold on;
    plot(grainsFilled.boundary, 'linewidth', 0.8);
    hold off;
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

% D:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp1_draw_ipf.m

