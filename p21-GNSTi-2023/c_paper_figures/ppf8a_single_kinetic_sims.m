% ppf8a_single_kinetic_sims.m

% Purpose:
% This script processes and visualizes grain growth kinetics data for specific grain IDs 
% from experimental and simulation data at 700°C and 550°C.

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define input path and file names
input_path = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti700du\csv2\csv_kinetics_grainID\';
my_fileCSV_name = {'csv_case4_recovery_v8_grainID', 'csv_case3_noStored_v1_grainID'};
my_type_legendName = {'Case I: No stored energy', 'Case II: Stored energy + GND evolution'};

% Define grain IDs to extract data for
grain_id = [349, 295, 251];

% Visualization parameters
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {':','-',':','-.','-','-','--',':','-.','-'}; 
fontSizeXY = 20; % Font size for axes
fontSizeLegend = 22;  % Font size for legend
fontSizeLabelTitle = 22;
lineWidth = 2; % Line width
markerSize = 80;

% Initialize figure
figure(1)
hold on
box on

% Loop through each grain ID
for i_grainID = 1:length(grain_id)
    % Loop through each case
    for i = 1:2
        disp('*************');
        disp(['Processing case: ', my_type_legendName{i}]);

        % Construct input file name
        input_file_name_kinetic = strcat(char(my_fileCSV_name{i}), '_kinetic.csv');
        input_data_kinetic = readtable([input_path, input_file_name_kinetic]);

        % Define column names for grain sizes
        column_names = {'grain_size_3', 'grain_size_2', 'grain_size_1'};

        % Extract time and grain diameter data for the current grain ID
        x = input_data_kinetic.time(input_data_kinetic.(column_names{i_grainID}) >= 0)./60 + 30;
        y = input_data_kinetic.(column_names{i_grainID})(input_data_kinetic.(column_names{i_grainID}) >= 0).*2;

        % Plot the data
        plot(x, y, ...
            'color', char(my_color(i_grainID)), ...
            'LineWidth', lineWidth, ...
            'LineStyle', char(my_lineStyle{i}), ...
            'DisplayName', [char(my_type_legendName{i}), ' - Grain ID: ', num2str(grain_id(i_grainID))]);
    end
end

% Set labels, limits, and other plot properties
xlabel('Time (min)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
ylabel('Grain diameter (\mum)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
xlim([25 125]);

% Set axes properties
set(gca, 'FontSize', fontSizeXY, ...
    'LineWidth', lineWidth, ...
    'FontName', 'Times New Roman'); % Set x and y axis properties

% Set figure properties
figWidth = 14.8; 
figHeight = 13.02; 
set(gcf, 'unit', 'centimeters', 'position', [0, 0, figWidth, figHeight])
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent

% Add legend
legend('FontSize', fontSizeLegend, 'TextColor', ...
    'black', 'Location', 'northeast', 'NumColumns', 1);
