% 这个脚本用于处理位于给定目录下的一系列 CSV 文件，并计算每个文件中的晶粒数
% 和平均晶粒尺寸，然后将结果保存为一个 CSV 文件。

clear all
close all
clc

input_dir1 = 'E:/Github/PandaData/p21_GMSTi_AGG_2023/sim_Ti550du/';
input_dir2 = {'./csv_Ti550_cs5_v1'};

output_dir = 'E:/Github/PandaData/p21_GMSTi_AGG_2023/paper_figure_data/';
output_FileName = {'case5_GMSTi_550du_v1'};

for i = 1:1 % 不同的case1~5
  input_dir_end = strcat(input_dir1, char(input_dir2(i)), '\');

  csv_filename = dir([input_dir_end, '*.csv']);
  csv_files_num = length(csv_filename);

  disp('*************');
  disp(csv_filename(1).name);
  total_csv_data = readtable([input_dir_end, csv_filename(1).name]);  
  
  % 创建输出数据的类别
  output_data = table;
  output_data.time = total_csv_data.time;
  output_data.avg_grain_radius = zeros(length(output_data.time), 1);
  output_data.grain_num = zeros(length(output_data.time), 1); 

  for j = 2:csv_files_num % 0000 ~ 0616
    j
    csv_data = readtable([input_dir_end, csv_filename(j).name]);    

    grain_size = csv_data.feature_volumes(csv_data.feature_volumes > 0.0);
    total_grain_size_now = sum(grain_size); % 整个域的面积
    grain_num_now = length(grain_size); % 当前晶粒数目
    output_data.grain_num(j-1, 1) = grain_num_now;

    % 计算平均晶粒尺寸 <R> = sum_{i=1}{Num}R_i*A_i/A_total
    grain_radius = sqrt(grain_size ./ pi);
    output_data.avg_grain_radius(j-1, 1) = sum(grain_radius .* grain_size ./ total_grain_size_now); % output for kinetics
  end

  % 输出数据
  output_path_filename_kinetic = strcat(output_dir, char(output_FileName(i)), '_kinetic.csv');
  writetable(output_data, output_path_filename_kinetic); 
end

% E:\Github\PandaScripts\p21-GMSTi-2023\sim_results_extraction_scripts\sim1_get_kinetic_data.m
