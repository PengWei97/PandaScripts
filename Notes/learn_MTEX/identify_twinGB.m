% load some example data
mtexdata twins

% segment grains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);

% remove two pixel grains
ebsd(grains(grains.grainSize<=2)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',5*degree);

% smooth them
grains = grains.smooth(5);

% visualize the grains
figure(1)
plot(grains,grains.meanOrientation)

% store crystal symmetry of Magnesium
CS = grains.CS;

gB = grains.boundary;
gB_MgMg = gB('Magnesium','Magnesium');

twinning = orientation.map(Miller(0,1,-1,-1,CS),Miller(-1,1,0,-1,CS),...
  Miller(1,0,-1,1,CS,'uvw'),Miller(1,0,-1,-1,CS,'uvw'))
  
% restrict to twinnings with threshold 5 degree
isTwinning = angle(gB_MgMg.misorientation,twinning) < 5*degree;
twinBoundary = gB_MgMg(isTwinning)

% plot the twinning boundaries
figure(2)
plot(grains,grains.meanOrientation)
%plot(ebsd('indexed'),ebsd('indexed').orientations)
hold on
%plot(gB_MgMg,angle(gB_MgMg.misorientation,twinning),'linewidth',4)
plot(twinBoundary,'linecolor','w','linewidth',4,'displayName','twin boundary')
hold off


% select CSL(3) grain boundaries
gB3 = gB_FeFe(angle(gB_FeFe.misorientation,CSL(3,ebsd('Iron fcc').CS)) < 8.66*degree);
% gb direction in crystal coordinates
gbdirc = inv(grains(gB3.grainId).meanOrientation).*gB3.direction;
% angle between gbdirc and {1,1,1}
MAngle = angle(gbdirc,Miller(1,1,1,ebsd('Iron fcc').CS));
% select only boundaries which have a trend very close to {1,1,1}
GBcoherent = gB3(any(MAngle < 5*degree,2));
% overlay grain boundaries with the existing plot
hold on
plot(gB3,'lineColor','r','linewidth',1.0,'DisplayName','CSL 3');
hold on
plot(GBcoherent,'lineColor','g','linewidth',1.5,'DisplayName','Coherent');
hold off


% D:\Github\PandaScripts\Notes\learn_MTEX\twinning.m