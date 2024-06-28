% This script processes EBSD (Electron Backscatter Diffraction) data for
% specific temperature and time points, fills the missing grain data, 
% visualizes the results, and calculates GNDs (Geometrically Necessary Dislocations).
% The script is designed to handle EBSD data from Ti-Hex crystals.

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
for tempIndex = 1:1 % length(temperatures)

    % Set input directory and time points
    [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(tempIndex);

    % Initialize the region density array
    rhoRegion = zeros(length(fileTimes), 2);

    % Main loop to process each time point
    for timeIndex = 1:length(fileTimes)
        % Construct input file name
        inputFile = fullfile(inputDir, sprintf('Ti_%ddu_%s.crc', temperatures(tempIndex), fileTimes{timeIndex}));

        % Set MTEX preferences
        setMTEXPreferences(timeIndex, tempIndex);

        % Load EBSD data
        ebsd = EBSD.load(inputFile, crystalSymmetries, 'interface', 'crc', 'convertEuler2SpatialReferenceFrame');

        % Visualize IPF map
        figure(5 * timeIndex - 4);
        plot(ebsd, ebsd.orientations, 'coordinates', 'off', 'micronbar', 'on');

        % Define box sizes for region manipulation
        boxSizes = getBoxSizes(tempIndex, timeIndex);

        % Fill missing data in EBSD
        ebsdInterp = fillData(ebsd, boxSizes);

        % Visualize the interpolated EBSD data
        figure(5 * timeIndex - 3);
        plot(ebsdInterp, ebsdInterp.orientations, 'coordinates', 'on', 'micronbar', 'on');

        % Fine-tune the grid
        [xMin, xMax, yMin, yMax] = ebsdInterp.extend;
        if (tempIndex == 1) && (timeIndex == 1)
            ebsdInterp = ebsdInterp(inpolygon(ebsdInterp, [xMin, yMax - 640, xMax-xMin, 640]));
        elseif (tempIndex == 1) && (timeIndex == 2)
            ebsdInterp = ebsdInterp(inpolygon(ebsdInterp, [59.0, 34.0, 400, 640]));
        elseif (tempIndex == 1) && (timeIndex == 3)
            ebsdInterp = ebsdInterp(inpolygon(ebsdInterp, [59.0, 34.0, 400, 640]));
        elseif (tempIndex == 1) && (timeIndex == 4)
            ebsdInterp = ebsdInterp(inpolygon(ebsdInterp, [xMin, 72, 400, 640]));
        end

        % Create a mesh grid for interpolation
        [xMin, xMax, yMin, yMax] = ebsdInterp.extend;
        xy = createMeshGrid(xMin, xMax, yMin, yMax, 2.0);
        ebsdFilled = interp(ebsdInterp, xy(1, :), xy(2, :));

        % Smooth and fill the grains
        alphaValues = [0.0, 2.5];
        for fillIndex = 1:2
            if fillIndex == 1
                [grainsFilled, ebsdFilled] = identifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
            end
            F = halfQuadraticFilter;
            F.alpha = alphaValues(fillIndex);
            ebsdFilled = smooth(ebsdFilled, F, 'fill', grainsFilled);
            ebsdFilled = ebsdFilled('indexed');

            [grainsFilled, ebsdFilled] = identifyAndSmoothGrains(ebsdFilled, 2.0 * degree, 60, 3.0);
        end

        % Visualize the filled EBSD data
        figure(5 * timeIndex - 2);
        plot(ebsdFilled, ebsdFilled.orientations, 'coordinates', 'off', 'micronbar', 'on');
        hold on;
        plot(grainsFilled.boundary, 'linewidth', 0.8);
        hold off;

        % Output the processed data
        outputFileName = fullfile(outputDir, 'ctf_filling\', sprintf('Ti%ddu_%s_filled.ctf', temperatures(tempIndex), fileTimes{timeIndex}));
        export_ctf(ebsdFilled, outputFileName);

        % Output grain boundary map
        figure(5 * timeIndex - 1);
        plot(grainsFilled.boundary, 'linewidth', 0.1, 'micronbar', 'off');

        outputBmpName = fullfile(outputDir, 'bmp\', sprintf('Ti%ddu_%s_filled.bmp', temperatures(tempIndex), fileTimes{timeIndex}));
        print(outputBmpName, '-dbmp', '-r600');

        % Calculate GNDs
        ebsdFilledGrid = ebsdFilled('indexed').gridify;
        rho = calculateGNDs(ebsdFilledGrid);

        % Visualize GNDs map
        figure(5 * timeIndex);
        plot(ebsdFilledGrid, rho, 'micronbar', 'on', 'coordinates', 'off');
        mtexColorMap('jet');
        set(gca, 'ColorScale', 'log');
        set(gca, 'CLim', [2.0e10 2.5e15]);
        mtexColorbar('title', 'Dislocation Density (1/m^2)');
        hold on;
        plot(grainsFilled.boundary, 'linewidth', 0.8);
        hold off;
    end
end

% Function to set input directories and time points
function [inputDir, fileTimes, timePoints, outputDir] = setDirectoriesAndTimes(tempIndex)
    disp('Setting directories and times')
    if tempIndex == 1
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\crc\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti550du\';
        fileTimes = {'30min', '120min', '240min', '480min'};
        timePoints = [30.0, 120.0, 240.0, 480.0];
    else
        inputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_refine\';
        outputDir = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\ctf_filling\';
        outputDirBmp = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\exp_Ti700du\bmp\';
        fileTimes = {'10min', '30min', '60min', '120min'};
        timePoints = [10.0, 30.0, 60.0, 120.0];
    end
end

% Function to set MTEX preferences
function setMTEXPreferences(index, tempIndex)
    setMTEXpref('zAxisDirection', 'outOfPlane');
    if tempIndex == 1
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
    sS_basal_sym  = slipSystem.basal(cs).symmetrise('antipodal'); % Basal slip
    sS_prism_sym  = slipSystem.prismaticA(cs).symmetrise('antipodal'); % Prismatic slip
    sS_pyrIA_sym  = slipSystem.pyramidalA(cs).symmetrise('antipodal'); % First order pyramidal slip
    sS_pyrIAC_sym = slipSystem.pyramidalCA(cs).symmetrise('antipodal');
    sS_pyrIIAC_sym = slipSystem.pyramidalCA2(cs).symmetrise('antipodal'); % Second order pyramidal slip

    slipSystems_all = {sS_basal_sym, sS_prism_sym, sS_pirIA_sym, sS_pirIAC_sym, sS_pirIIAC_sym};
    slipSystems_all_sym = [];
    for i_numSlip = 1:length(slipSystems_all)
        for j = 1:length(slipSystems_all{i_numSlip})
            slipSystems_all_sym = [slipSystems_all_sym; slipSystems_all{i_numSlip}(j)];
        end
    end

    % Dislocation density tensor
    dS = dislocationSystem(slipSystems_all_sym);.
    dS_rot = ebsd_interp.orientations * dS;
    kappa = ebsdInterp.curvature;
    [rho_single, factor] = fitDislocationSystems(kappa, dS_rot);
    alpha = sum(dS_rot.tensor .* rho_single, 2);
    alpha.opt.unit = '1/um';

    rho = sqrt(0.5 * sum(rho_single.^2));
end

% Function to fill missing data in EBSD
function ebsdInterp = fillData(ebsdInterp, boxSize)
    if length(boxSize) == 0
        ebsdInterp = ebsdInterp;
        return;
    end

    for i_box_num = 1:size(boxSize, 1)
        disp(['Box number: ', num2str(i_box_num)]);
        clear ebsd_temp;
        ebsd_temp = ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 5), boxSize(i_box_num, 6), boxSize(i_box_num, 3), boxSize(i_box_num, 4)]));
        ebsd_temp2 = ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 1), boxSize(i_box_num, 2), boxSize(i_box_num, 3), boxSize(i_box_num, 4)]));

        if length(ebsd_temp) > length(ebsd_temp2)
            ebsd_a = ebsd_temp(1:length(ebsd_temp2));
            ebsd_temp = ebsd_a;
        elseif length(ebsd_temp) < length(ebsd_temp2)
            ebsd_a = ebsd_temp2;
            ebsd_a(1:length(ebsd_temp)) = ebsd_temp(1:length(ebsd_temp));
            ebsd_a(length(ebsd_temp) + 1:length(ebsd_temp2)) = ebsd_temp2(length(ebsd_temp) + 1:length(ebsd_temp2));
            ebsd_temp = ebsd_a;
        end
        
        % Assign values to ebsd_temp
        ebsd_temp.id = ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 1), boxSize(i_box_num, 2), boxSize(i_box_num, 3), boxSize(i_box_num, 4)])).id;
        ebsd_temp.x = ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 1), boxSize(i_box_num, 2), boxSize(i_box_num, 3), boxSize(i_box_num, 4)])).x;
        ebsd_temp.y = ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 1), boxSize(i_box_num, 2), boxSize(i_box_num, 3), boxSize(i_box_num, 4)])).y;
        
        % Copy ebsd_temp to ebsdInterp
        ebsdInterp(inpolygon(ebsdInterp, [boxSize(i_box_num, 1), boxSize(i_box_num, 2), boxSize(i_box_num, 3), boxSize(i_box_num, 4)])) = ebsd_temp;
    end
end

% Function to get box sizes
function boxSizes = getBoxSizes(iTemperature, iTimePoint)
  if (iTemperature == 1) && (iTimePoint == 1)
      boxSizes = [
          25.8300 117.3400 16.6700 12.4800 225.8300 117.3400;
          58.3300 121.5000 25.0000 14.9800 259.1700 121.5000;
          50.8300 138.1400 50.0000 24.1300 250.8300 138.1400;
          60.8300 162.2800 40.0000 15.8100 261.6700 162.2800;
          83.3300 113.1800 25.0000 24.1300 284.1700 113.1800;
          108.3300 117.3400 27.5000 20.8000 309.1700 117.3400;
          101.6700 138.1400 26.6700 15.8100 301.6700 138.1400;
          128.3300 138.1400 27.5000 33.2900 329.1700 138.1400;
      ];
  elseif (iTemperature == 1) && (iTimePoint == 4)
      boxSizes = [
          339.1900   29.8800   26.5500   12.8000  514.7800   29.8800;
          318.6300   42.6800   35.9700   20.4900  494.2200   42.6800;
          278.3700   63.1700   76.2300   12.8000  454.8200   63.1700;
          274.9500   49.5100   17.9900   12.8000  451.3900   49.5100;
          298.0700   75.9800   35.9700   22.2000  474.5200   75.9800;
          259.5300   75.9800   38.5400   16.2200  435.9700   75.9800;
          250.1100   81.9500    9.4200   16.2200  426.5500   81.9500; % local 1

          240.000  127.000    7.00   19.000  390.0000  127.000;
          208.1400  124.6300   24.8400   21.3400  494.2200   42.6800;
          208.1400  145.9800   48.8200   21.3400  358.8900  145.9800; % error - 10
          215.8500  167.3200   18.8400   15.3700  365.7400  167.3200;
          215.8500  167.3200   18.8400   15.3700  365.7400  167.3200;
          204.7100  182.6800   19.7000   13.6600  355.4600  182.6800;
          166.1700  133.1700   19.7000   16.2200  316.9200  133.1700;
          155.8900  149.3900   52.2500   15.3700  306.6400  149.3900;
          160.1700  165.6100   41.9700   13.6600  310.9200  165.6100;
          160.1700  179.2700   25.7000    7.6800  310.9200  179.2700; % local 2

          454.8200  234.7600   15.4200   13.6600  238.9700  234.7600; 
          439.4000  220.2400   15.4200   30.7300  223.5600  220.2400; 
          418   198    21    50   175   198; % local 3 error - 20

          103.4200  149.3900   18.8000   14.5100  370.9400  149.3900; 
          78   188    26    18   346   188; % error - 22
          82.9100  205.7300   17.9500   14.5100  350.4300  205.7300; 
          32.4800  167.3200   30.7700   20.4900  300.8600  167.3200; 
          24.7900  194.6300   16.2400   17.9300  293.1600  194.6300; 
          27.3500  216.8300   16.2400   18.7800  294.8700  216.8300; 
          147.8600  205.7300   16.2400   14.5100  236.7500  205.7300; % local 4

          411.1100  228.2600  27.3500   22.1400  200.8500  228.4800; 
          419.6600  267.5100  10.2600   17.9000  317.0900  267.7300; 
          389.7400  253.0600  29.9100   41.7700  286.3300  253.2800; 
          378.6300  276.1300  10.2600   12.7800  276.0700  276.3500; % local 5

          285.4700  396.7000   24.7900   28.9700  442.7400  397.2100; 
          252.1400  432.6200   43.5900   17.8300  409.4000  432.2900; 
          247.0100  450.5600   21.3700   36.6600  405.1300  451.0800; % local 6
      ];
  else
      boxSizes = [];
  end
end

% Function to create a mesh grid
function xy = createMeshGrid(xMin, xMax, yMin, yMax, stepSize)
    [X, Y] = meshgrid(xMin:stepSize:xMax, yMin:stepSize:yMax);
    xy = [X(:) Y(:)];
end
