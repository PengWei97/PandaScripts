% 1 - 输出 ipf map
% 2 - 输出 ang file
% 3 - 输出 ctf + rho files

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
out_dir = 'D:\0同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_ang\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

num_type_figures = 2;
for i_time = 1:1 % length(time_points)
    % path to files
    input_file = fullfile(pname, sprintf('Ni_%dmin_%s.ctf', time_points(i_time), local_names{3}));
    %% Import the Data
    ebsd = EBSD.load(input_file,CS,'interface','ctf',...
      'convertEuler2SpatialReferenceFrame');
    
    [xmin, xmax, ymin, ymax] = ebsd.extent;
    ebsd = ebsd(inpolygon(ebsd, [xmin, ymin, 100, 100]));

    % ebsdInterp(inpolygon(ebsdInterp, [xMin, yMax - 640, xMax-xMin, 640]));
    % [grains, ebsd] = IdentifyAndSmoothGrains(ebsd, 2.0 * degree, 10, 3.0);

    % figure(3*i_time - 2)
    % plot(ebsd, ebsd.orientations, 'coordinates', 'on', 'micronbar', 'on');
    % hold on;
    % plot(grains.boundary, 'linewidth', 0.8);

    % output ang
    output_file = fullfile(out_dir, sprintf('Ni_%dmin_%s_local.ang', time_points(i_time), local_names{3}));
    export_ang(ebsd, output_file);

    % % calculated GND density
    % ebsdGrid = ebsd('indexed').gridify;
    % rho = calculateGNDs(ebsdGrid);

    % % Visualize GNDs map
    % figure(3*i_time - 1)
    % plot(ebsdGrid, rho, 'micronbar', 'on', 'coordinates', 'off');
    % mtexColorMap('jet');
    % set(gca, 'ColorScale', 'log');
    % set(gca, 'CLim', [2.0e10 2.5e15]);
    % mtexColorbar('title', 'Dislocation Density (1/m^2)');
    % hold on;
    % plot(grains.boundary, 'linewidth', 0.8);
    % hold off;

    % % 采用 export_ctfa 修改版本，添加输出 rho
    % output_file = fullfile(pname, sprintf('Ni_%dmin_%s_rho.ctf', time_points(i_time), local_names{3}));
    % export_ctf(ebsdGrid, rho, output_file) 
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

% Function to calculate dislocation density
function rho = calculateGNDs(ebsdInterp)

  kappa = ebsdInterp.curvature;
  alpha = kappa.dislocationDensity; % the incomplete dislocation density tensor
  dS = dislocationSystem.fcc(ebsdInterp.CS); % Crystallographic Dislocations
  dSRot = ebsdInterp.orientations * dS; % to rotate the dislocation tensors into the specimen reference frame as well
  [rho_single,factor] = fitDislocationSystems(kappa,dSRot); % fitting Dislocations to the incomplete dislocation density tensor
  alpha = sum(dSRot.tensor .* rho_single,2); % the restored dislocation density tensors
  alpha.opt.unit = '1/um'; % we have to set the unit manualy since it is not stored in rho
  kappa = alpha.curvature; % we may also restore the complete curvature tensor with
  rho = factor*sum(abs(rho_single),2); % calculate dislocation density
end

% D:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp2_draw_ipf_level1a2.m

