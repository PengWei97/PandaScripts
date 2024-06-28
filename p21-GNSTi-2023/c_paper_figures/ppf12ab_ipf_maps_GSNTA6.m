% D:\C工作\prm2_ThermalGNS_AGG2023\p21_GNS-Ti_AGG_2023\data_and_scripts\p2_draw_kinetics.m

clear all
close all
clc

% Specify Crystal and Specimen Symmetries
CS = {... 
  'notIndexed',...
  crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

my_file_time = {'TA6_700du_60min', '800DU1H'};

% Set MTEX preferences
setMTEXpref('zAxisDirection','outOfPlane'); % outOfPlane
setMTEXpref('xAxisDirection','east'); % 1-east, 2-west

% Directories
input_file_dir = 'H:\PhD_data\prm2_GNSThermalStability_2023_data\preprocess_data\exp_GNSTA6_700a800du_2019\';
output_file_dir = 'H:\PhD_data\prm2_GNSThermalStability_2023_data\preprocess_data\exp_GNSTA6_700a800du_2019\';
fig_num = 6;

for i = 1:1
    my_inputfile = strcat(char(my_file_time(i)), '.ctf');
    fname = [input_file_dir my_inputfile]; 

    % Load EBSD data
    ebsd = EBSD.load(fname, CS, 'interface', 'ctf', 'convertEuler2SpatialReferenceFrame');

    % Calculate and smooth grains
    [grains, ebsd('indexed').grainId] = calcGrains(ebsd('indexed'), 'threshold', 1.0*degree);
    grains = smooth(grains, 50);

    [xmin, xmax, ymin, ymax] = ebsd.extent;
    ebsd_1 = ebsd(inpolygon(ebsd, [xmin 96.0 xmax 276.0-96.0]));

    % Remove small grains
    [grains_1, ebsd_1('indexed').grainId] = calcGrains(ebsd_1('indexed'), 'threshold', 1.0*degree);
    ebsd_1(grains_1(grains_1.grainSize < 10)) = [];
    [grains_1, ebsd_1('indexed').grainId] = calcGrains(ebsd_1('indexed'), 'threshold', 1.0*degree);
    F = splineFilter;
    ebsd_1 = smooth(ebsd_1('indexed'), F, 'fill');
    [grains_1, ebsd_1('indexed').grainId] = calcGrains(ebsd_1('indexed'), 'threshold', 1.0*degree);

    % Visualization - EBSD map
    figure(i * fig_num - 2);
    plot(ebsd_1, ebsd_1.orientations, 'coordinates', 'off', 'micronbar', 'on');
    hold on;
    plot(grains_1.boundary, 'linewidth', 1.0);
    hold off;

    % Interpolate mesh and refine
    [xmin, xmax, ymin, ymax] = ebsd_1.extent;
    refine_factor_x = (xmax - xmin) * 1.0;
    refine_factor_y = (ymax - ymin) * 1.0;

    x = linspace(xmin, xmax, refine_factor_x);
    y = linspace(ymin, ymax, refine_factor_y);
    [x, y] = meshgrid(x, y);
    xy = [x(:), y(:)].';

    ebsd_NewGrid_1 = interp(ebsd_1, xy(1,:), xy(2,:));
    [grains_NewGrid_1, ebsd_NewGrid_1.grainId, ebsd_NewGrid_1.mis2mean] = calcGrains(ebsd_NewGrid_1, 'threshold', 1.0*degree);
    grains_NewGrid_1 = smooth(grains_NewGrid_1, 50);

    % Visualization - Refined EBSD map
    figure(i * fig_num - 3);
    plot(ebsd_NewGrid_1, ebsd_NewGrid_1.orientations, 'coordinates', 'off', 'micronbar', 'on');
    hold on;
    plot(grains_NewGrid_1.boundary);
    hold off;

    % Calculate GNDs
    ebsd_mesh = ebsd_NewGrid_1('indexed').gridify;
    kappa = ebsd_mesh.curvature;
    alpha = kappa.dislocationDensity;

    cs = ebsd_mesh.CS;
    sS_basal_sym  = slipSystem.basal(cs).symmetrise('antipodal');
    sS_prism_sym  = slipSystem.prismaticA(cs).symmetrise('antipodal');
    sS_pyrIA_sym  = slipSystem.pyramidalA(cs).symmetrise('antipodal');
    sS_pyrIAC_sym = slipSystem.pyramidalCA(cs).symmetrise('antipodal');
    sS_pyrIIAC_sym = slipSystem.pyramidal2CA(cs).symmetrise('antipodal');

    slipSystems_all = {sS_basal_sym, sS_prism_sym, sS_pyrIA_sym, sS_pyrIAC_sym, sS_pyrIIAC_sym};
    slipSystems_all_sym = [];
    for i = 1:length(slipSystems_all)
        for j = 1:length(slipSystems_all{i})
            slipSystems_all_sym = [slipSystems_all_sym; slipSystems_all{i}(j)];
        end
    end

    dS = dislocationSystem(slipSystems_all_sym);
    dSRot = ebsd_mesh.orientations * dS;
    [rho_single, factor] = fitDislocationSystems(kappa, dSRot);
    alpha = sum(dSRot.tensor .* rho_single, 2);
    alpha.opt.unit = '1/um';
    kappa = alpha.curvature;
    rho = factor * sum(abs(rho_single), 2);

    % Visualization - GNDs map
    figure(fig_num * i - 4);
    plot(ebsd_mesh, rho / 2, 'micronbar', 'on', 'coordinates', 'off');
    mtexColorMap('jet');
    set(gca, 'ColorScale', 'log');
    set(gca, 'CLim', [2.0e11 2.0e15]);
    mtexColorbar('title', 'Dislocation density (1/m^2)');
    hold on;
    plot(grains_NewGrid_1.boundary, 'linewidth', 1.0);
    hold off;

    % Export data (optional)
    % my_outputfile_ctf = strcat(output_file_dir ,char(my_file_time(i)),'.ctf');
    % export_ctf(ebsd_NewGrid_1, char(my_outputfile_ctf));
    % my_outputfile_ang = strcat(output_file_dir,'ang\',char(my_file_time(i)),'.ang');
    % export_ang(ebsd_NewGrid_1, char(my_outputfile_ang));
end
