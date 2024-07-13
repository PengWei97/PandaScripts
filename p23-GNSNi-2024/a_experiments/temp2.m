clear all
close all
clc

input_path = 'E:\Nutstore\小论文撰写\2022GNGsAGG\前处理\mtex_total\output_10min\';
% input_filename1 = '4_Ti700du_10minFill.txt'; % inl source file 
input_filename1 = 'local_Ti700du_5minFill_refine_1.txt'; % inl source file from dream3D
% 文件不要#号
% opts.DataLines = 1;
% 需要取消25行的井号
data1 = readtable([input_path,input_filename1]); % inl file

input_filename2 = 'local_Ti700du_5minFill_refine_1_rho.txt'; % EBSD file from mtex  
data3 = readtable([input_path,input_filename2]); % inl data to moose
data2.Rho = data3.Rho;
data2.Rho_avg = data3.Rho;

mim_critical_rho = min(data2.Rho(data2.Rho>100))-1e3;

figure(5) %log(rho1.rho)
scatter(data1.x, data1.y,20,log(data2.Rho),'filled')

figure(6) %log(rho1.rho)
scatter(data3.X, data3.Y,20,log(data2.Rho),'filled')

for i = 1:max(data1.FeatureId)
    clear rho_get_grain1 rho_get_grain2 rho_average_grain
    rho_get_grain1 = data2.Rho(data1.FeatureId == i); %提取grain i的rho 序列
    rho_get_grain2 = rho_get_grain1(find(rho_get_grain1 > mim_critical_rho)); %筛选 序列
    rho_average_grain = sum(rho_get_grain2)/length(rho_get_grain2); % 计算平均位错密度
    if (rho_average_grain < mim_critical_rho)
        rho_average_grain = mim_critical_rho;
    end

    %% 1 - 对整个晶粒进行平均化
    data2.Rho_avg(data1.FeatureId == i) = rho_average_grain;
    data2.Rho_avg(isnan(data2.Rho_avg)) = mean(data2.Rho_avg(~isnan(data2.Rho_avg)));
    
    %% 2- 只替换小于 mim_critical_rho 的数据点
    clear m v
    [m,v] = find(data1.FeatureId == i); %返回非零元素的行和列索引
    for j = 1:length(m)
      if ((data2.Rho(m(j)) <  mim_critical_rho) || isnan(data2.Rho(m(j))))
          data2.Rho(m(j)) = rho_average_grain;
      end
    end
end

figure(7) %log(rho1.rho)
scatter(data1.x, data1.y,20,log(data2.Rho_avg),'filled')
colorbar

data2.Rho(isnan(data2.Rho)) = min(data2.Rho);

%% output
data_output = data1;
data_output_avg = data1;
% % 设置输出格式
% data_output.phi1 = strtrim(cellstr(num2str(data2.phi1,'%.6f')));
% data_output.PHI = strtrim(cellstr(num2str(data2.PHI,'%.6f')));
% data_output.phi2 = strtrim(cellstr(num2str(data2.phi2,'%.6f')));
% data_output.x = strtrim(cellstr(num2str(data2.x,'%.6f')));
% data_output.y = strtrim(cellstr(num2str(data2.y,'%.6f')));
% data_output.z = strtrim(cellstr(num2str(data2.z,'%.2f')));
data_output.Rho = strtrim(cellstr(num2str(data2.Rho,'%.6e')));
data_output_avg.Rho_avg = strtrim(cellstr(num2str(data2.Rho_avg,'%.6e')));

% 输出
output_path = input_path;
output_filename = 'local_Ti700du_5minFill_refine_1_rho_inl.txt';
output_path_filename = strcat(output_path,output_filename);
writetable(data_output,output_path_filename,'Delimiter',' ')

% 2 - avg
output_filename2 = 'local_Ti700du_5minFill_refine_1_rho_avg_inl.txt';
output_path_filename2 = strcat(output_path,output_filename2);
writetable(data_output_avg,output_path_filename2,'Delimiter',' ')
% figure(7) %log(rho1.rho)
% scatter(data2.x, data2.y,20,log(data2.Rho),'filled')