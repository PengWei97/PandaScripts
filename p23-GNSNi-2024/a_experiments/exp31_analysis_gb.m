clear all
close all
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
for i_time = 2:4 % 1:length(time_points)
  % path to files
  input_file = fullfile(pname, sprintf('Ni_%dmin_%s_local1.ctf', time_points(i_time), local_names{1}));
  %% Import the Data
  ebsd = EBSD.load(input_file,CS,'interface','ctf',...
    'convertEuler2SpatialReferenceFrame');

  [grains, ebsd.grainId] = calcGrains(ebsd('indexed'));
  grains = smooth(grains, 5);

  % figure(1)
  % plot(grains, grains.meanOrientation, 'linewidth', 0.5, 'micronbar', 'off'); % 'FaceAlpha', 0.3,

  delta = 3*degree;
  gB = grains.boundary('Ni-superalloy', 'Ni-superalloy');
  gB3 = gB(angle(gB.misorientation,CSL(3,ebsd.CS)) < delta);
  % gB5 = gB(gB.isTwinning(CSL(5,ebsd.CS),delta));
  % gB7 = gB(gB.isTwinning(CSL(7,ebsd.CS),delta));
  % gB9 = gB(gB.isTwinning(CSL(9,ebsd.CS),delta));
  % gB11 = gB(gB.isTwinning(CSL(11,ebsd.CS),delta));

  % figure(2)
  % plot(grains.boundary, 'lineColor', 'black', 'linewidth', 0.5, 'micronbar', 'off')
  % hold on
  % plot(gB3, 'lineColor', 'gold', 'linewidth', 2, 'DisplayName', 'CSL 3', 'micronbar', 'off');
  % hold on
  % plot(gB5, 'lineColor', 'b', 'linewidth', 2, 'DisplayName', 'CSL 5');
  % hold on
  % plot(gB7, 'lineColor', 'g', 'linewidth', 2, 'DisplayName', 'CSL 7');
  % hold on
  % plot(gB9, 'lineColor', 'm', 'linewidth', 2, 'DisplayName', 'CSL 9');
  % hold on
  % plot(gB11, 'lineColor', 'c', 'linewidth', 2, 'DisplayName', 'CSL 11');

  % % logical list of CSL boundaries
  % isCSL3 = grains.boundary.isTwinning(CSL(3,ebsd.CS),3*degree);
  % % logical list of triple points with at least 2 CSL boundaries
  % tPid = sum(isCSL3(grains.triplePoints.boundaryId),2)>=2;

  % % % plot these triple points
  % % hold on
  % % plot(grains.triplePoints(tPid),'color','red','linewidth',1,'MarkerSize',8)
  % % hold off

  % % this merges the grains
  % [mergedGrains,parentIds] = merge(grains,gB3);

  % % overlay the boundaries of the merged grains with the previous plot
  % hold on
  % plot(mergedGrains.boundary,'linecolor','black','linewidth',2)
  % hold off

  % gb direction in crystal coordinates
  gbdirc = inv(grains(gB3.grainId).meanOrientation).*gB3.direction;
  % angle between gbdirc and {1,1,1}
  MAngle = angle(gbdirc,Miller(1,1,1,ebsd('Ni-superalloy').CS));
  % select only boundaries which have a trend very close to {1,1,1}
  GBcoherent = gB3(any(MAngle < delta, 2));
  % overlay grain boundaries with the existing plot
  figure(i_time)
  plot(grains.boundary, 'lineColor', 'black', 'linewidth', 0.5, 'micronbar', 'off')
  hold on
  plot(gB3, 'lineColor', 'gold', 'linewidth', 2, 'micronbar', 'off'); %  'DisplayName', 'CSL 3',
  plot(GBcoherent,'lineColor', 'r', 'linewidth', 2); % 'DisplayName', 'Coherent'
end

% E:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp31_analysis_gb.m
