% 输入 data_inl:  删除 title 的 inl files from dream 3d % 文件不要#号
% 输入 ctf_rho: 包含 rho 的 ctf 文件，基于 exp2_draw_ipf_level1a2.m 获取

% D:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp22_add_rho_into_INL.m
clear all
close all
clc

%% Specify File Names
input_path_inl = 'D:\0同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_inl\' % 只能是英文路径，考虑到dream3D不能识别中文路径
input_path_ctf = 'D:\0同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_ctf\';
out_dir = 'E:\同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_inl\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

for i_time = 1:1 % length(time_points)
  input_filename_inl = sprintf('Ni_%dmin_%s.txt', time_points(i_time), local_names{3}); % inl source file from dream3D
  data_inl = readtable([input_path_inl, input_filename_inl]); % inl file

  input_filename_ctf = sprintf('Ni_%dmin_%s_rho.txt', time_points(i_time), local_names{3});
  data_ctf = readtable([input_path_ctf, input_filename_ctf]); % inl file
  
  data_inl.Rho = data_ctf.Rho;
  data_inl.Rho(isnan(data_inl.Rho)) = 0.0;

  % % scatter(data_inl.x, data_inl.y, 20, log(data_temp.rho), 'filled')
  % % caxis(log([2.0e10, 2.5e15]));

  min_critical_rho = min(data_inl.Rho(data_inl.Rho>100));

  for i_grain = 1:max(data_inl.FeatureId)+1 % 遍历所有识别的晶粒 data_inl.phi(data_inl.FeatureId == 0)
    id_grain = i_grain - 1;
    id_grain
    rho_get_grain1 = data_inl.Rho(data_inl.FeatureId == id_grain); % 提取grain i的rho 序列
    rho_get_grain2 = rho_get_grain1(rho_get_grain1 > min_critical_rho); %筛选序列
    
    % 计算平均位错密度
    rho_average_grain = sum(rho_get_grain2)/length(rho_get_grain2);

    % 计算平均位错密度
    if isempty(rho_get_grain2)
      rho_average_grain = min_critical_rho;
    else
      rho_average_grain = mean(rho_get_grain2);
    end

    % 确保平均位错密度不小于min_critical_rho
    rho_average_grain = max(rho_average_grain, min_critical_rho);
    
    % 获取当前晶粒的索引
    grain_indices = find(data_inl.FeatureId == i_grain);
    
    % 替换小于min_critical_rho或NaN的数据点
    replace_logical = (data_inl.Rho(grain_indices) < min_critical_rho) | isnan(data_inl.Rho(grain_indices));
    data_inl.Rho(grain_indices(replace_logical)) = rho_average_grain;
  end
  % scatter(data_inl.x, data_inl.y, 20, log(data_inl.Rho), 'filled')
  % caxis(log([2.0e10, 2.5e15]));

  %% output
  data_output = data_inl;
  % 设置输出格式
  data_output.phi1 = strtrim(cellstr(num2str(data_inl.phi1,'%.6f')));
  data_output.PHI = strtrim(cellstr(num2str(data_inl.PHI,'%.6f')));
  data_output.phi2 = strtrim(cellstr(num2str(data_inl.phi2,'%.6f')));
  data_output.x = strtrim(cellstr(num2str(data_inl.x,'%.6f')));
  data_output.y = strtrim(cellstr(num2str(data_inl.y,'%.6f')));
  data_output.z = strtrim(cellstr(num2str(data_inl.z,'%.2f')));
  data_output.Rho = strtrim(cellstr(num2str(data_inl.Rho,'%.6e')));
  output_path = input_path_inl;
  output_filename = sprintf('Ni_%dmin_%s_rho_inl.txt', time_points(i_time), local_names{3});
  output_path_filename = fullfile(output_path, output_filename);
  writetable(data_output, output_path_filename, 'Delimiter', ' ')
end

% D:\Github\PandaScripts\p23-GNSNi-2024\a_experiments\exp22_add_rho_into_INL.m