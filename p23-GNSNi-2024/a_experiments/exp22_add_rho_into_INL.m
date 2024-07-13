% 输入 data_inl:  删除 title 的 inl files from dream 3d % 文件不要#号
% 输入 ctf_rho: 包含 rho 的 ctf 文件，基于 exp2_draw_ipf_level1a2.m 获取

clear all
close all
clc

%% Specify File Names
input_path_inl = 'E:\temp\' % 只能是英文路径，考虑到dream3D不能识别中文路径
input_path_ctf = 'E:\同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_ctf\';
out_dir = 'E:\同步\p23_GNS-Ni_Ti_AGG_2024\exp_data\ebsd_inl\';
time_points = [5.0, 10.0, 20.0, 30.0];
local_names = {'level1', 'level2', 'level1a2','excerpt'};

for i_time = 1:1 % length(time_points)
  input_filename_inl = 'test.txt'; % inl source file from dream3D
  data_inl = readtable([input_path_inl, input_filename_inl]); % inl file

  input_filename_ctf = sprintf('Ni_%dmin_%s_rho.txt', time_points(i_time), local_names{3});
  data_ctf = readtable([input_path_ctf, input_filename_ctf]); % inl file
  
  data_temp.rho = data_ctf.Rho;

  % min_critical_rho = min(data_temp.rho(data_temp.rho>100))-1e3;
end

% mim_critical_rho = min(data2.Rho(data2.Rho>100))-1e3;

% figure(5) %log(rho1.rho)
% scatter(data1.x, data1.y,20,log(data2.Rho),'filled')

% figure(6) %log(rho1.rho)
% scatter(data3.X, data3.Y,20,log(data2.Rho),'filled')

% for i = 1:max(data1.FeatureId)
%     clear rho_get_grain1 rho_get_grain2 rho_average_grain
%     rho_get_grain1 = data2.Rho(data1.FeatureId == i); %提取grain i的rho 序列
%     rho_get_grain2 = rho_get_grain1(find(rho_get_grain1 > mim_critical_rho)); %筛选 序列
%     rho_average_grain = sum(rho_get_grain2)/length(rho_get_grain2); % 计算平均位错密度
%     if (rho_average_grain < mim_critical_rho)
%         rho_average_grain = mim_critical_rho;
%     end

%     %% 1 - 对整个晶粒进行平均化
%     data2.Rho_avg(data1.FeatureId == i) = rho_average_grain;
%     data2.Rho_avg(isnan(data2.Rho_avg)) = mean(data2.Rho_avg(~isnan(data2.Rho_avg)));
    
%     %% 2- 只替换小于 mim_critical_rho 的数据点
%     clear m v
%     [m,v] = find(data1.FeatureId == i); %返回非零元素的行和列索引
%     for j = 1:length(m)
%       if ((data2.Rho(m(j)) <  mim_critical_rho) || isnan(data2.Rho(m(j))))
%           data2.Rho(m(j)) = rho_average_grain;
%       end
%     end
% end

% figure(7) %log(rho1.rho)
% scatter(data1.x, data1.y,20,log(data2.Rho_avg),'filled')
% colorbar

% data2.Rho(isnan(data2.Rho)) = min(data2.Rho);

% %% output
% data_output = data1;
% data_output_avg = data1;
% % % 设置输出格式
% % data_output.phi1 = strtrim(cellstr(num2str(data2.phi1,'%.6f')));
% % data_output.PHI = strtrim(cellstr(num2str(data2.PHI,'%.6f')));
% % data_output.phi2 = strtrim(cellstr(num2str(data2.phi2,'%.6f')));
% % data_output.x = strtrim(cellstr(num2str(data2.x,'%.6f')));
% % data_output.y = strtrim(cellstr(num2str(data2.y,'%.6f')));
% % data_output.z = strtrim(cellstr(num2str(data2.z,'%.2f')));
% data_output.Rho = strtrim(cellstr(num2str(data2.Rho,'%.6e')));
% data_output_avg.Rho_avg = strtrim(cellstr(num2str(data2.Rho_avg,'%.6e')));

% % 输出
% output_path = input_path;
% output_filename = 'local_Ti700du_5minFill_refine_1_rho_inl.txt';
% output_path_filename = strcat(output_path,output_filename);
% writetable(data_output,output_path_filename,'Delimiter',' ')

% % 2 - avg
% output_filename2 = 'local_Ti700du_5minFill_refine_1_rho_avg_inl.txt';
% output_path_filename2 = strcat(output_path,output_filename2);
% writetable(data_output_avg,output_path_filename2,'Delimiter',' ')
% % figure(7) %log(rho1.rho)
% % scatter(data2.x, data2.y,20,log(data2.Rho),'filled')