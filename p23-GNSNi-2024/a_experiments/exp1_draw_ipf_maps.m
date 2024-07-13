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
pname = 'E:\Github\PandaData\p23_GMSNi_AGG_2024\exp_data\ebsd_ctf\'; % E:\同步\p23_GNS-Ni_Ti_AGG_2024\exp_data
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

num_type_figures = 2;
for i_time = 2:2 % 1:length(time_points)
    % path to files
    input_file = fullfile(pname, sprintf('Ni_%dmin_%s_local1.ctf', time_points(i_time), local_names{3}));
    %% Import the Data
    ebsd = EBSD.load(input_file,CS,'interface','ctf',...
      'convertEuler2SpatialReferenceFrame');

    [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', 2.0 * degree);
    grains = smooth(grains, 10);
    ebsd(grains(grains.grainSize < 5)) = [];
    [grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd, 'threshold', 2.0 * degree);
    grains = smooth(grains, 10);

    figure(num_type_figures*i_time)
    plot(ebsd,ebsd.orientations,'micronbar','off', 'coordinates', 'off')
    hold on;
    plot(grains.boundary, 'linewidth', 0.8);
    hold off;
end

% E:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp1_draw_ipf_maps.m

