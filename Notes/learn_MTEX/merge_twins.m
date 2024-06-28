
ebsd_merged = ebsd;
% extract grain area for faster access
gArea = grains.area;

% loop over mergedGrains and determine children that are not twins
isTwin = true(grains.length,1);
for i = 1:mergedGrains.length
    % get child ids
    childId = find(parentId==i);

    % cluster grains of similar orientations
    [fId,center] = calcCluster(grains.meanOrientation(childId),'maxAngle',20*degree,'method','hierarchical','silent');

    % compute area of each cluster
    clusterArea = accumarray(fId,gArea(childId));

    % label the grains of largest cluster as original grain
    [~,fParent] = max(clusterArea);

    % childID是当前母晶粒里所有的子晶粒的ID，包括生成的孪晶和未孪晶化的部分母晶
    % childId(fId==fParent)是未孪晶化的母晶粒的ID
    % 先得到所有未孪晶化母晶粒的平均晶体取向，然后将这个平均取向赋值给孪晶
    child_m=childId(fId==fParent);       % 当前大晶粒中剩余未孪晶化的母晶粒的ID
    idx = ~ismember(childId, child_m);
    child_t=childId(idx);                % 当前大晶粒中孪晶的ID

    ori_m=ebsd_merged(grains(child_m)).orientations;
    ebsd_merged(grains(child_t)).orientations=mean(ori_m);

    isTwin(child_m) = false;
end

% compute the area fraction of twins
twinfraction=sum(area(grains(isTwin)))/sum(area(grains)) * 100;

% visualize the result
h2=figure(2);
plot(grains(~isTwin),'FaceColor','darkgray','displayName','not twin')
hold on
plot(grains(isTwin),'FaceColor','red','displayName','twin')
hold off

%% 重构晶粒ID更新
ebsd_merged('indexed').grainId = parentId(grains.id2ind(ebsd('indexed').grainId));

figure(3)
plot(ebsd_merged,ebsd_merged.orientations)
hold on
plot(mergedGrains.boundary,'linewidth',1)
hold off