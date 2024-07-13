% set up the plotting convention
plotx2north

% import the EBSD data
ebsd = EBSD.load([mtexDataPath filesep 'EBSD' filesep 'DC06_2uniax.ang']);
%ebsd = EBSD.load('DC06_2biax.ang');

% define the color key
ipfKey = ipfHSVKey(ebsd);
ipfKey.inversePoleFigureDirection = yvector;

% and plot the orientation data
plot(ebsd,ipfKey.orientation2color(ebsd.orientations),'micronBar','off','figSize','medium')

ebsd = ebsd('indexed').gridify;

kappa = ebsd.curvature;
% alpha = kappa.dislocationDensity;
dS = dislocationSystem.fcc(ebsd.CS);
nu = 0.3;
dS(dS.isEdge).u = 1;
dS(dS.isScrew).u = 1 - 0.3;

dSRot = ebsd.orientations * dS;
[rho,factor] = fitDislocationSystems(kappa,dSRot);
alpha = sum(dSRot.tensor .* rho,2);
alpha.opt.unit = '1/um';
% kappa = alpha.curvature

close all
plot(ebsd,factor*sum(abs(rho .* dSRot.u),2),'micronbar','off')
mtexColorMap('hot')
mtexColorbar

set(gca,'ColorScale','log'); % this works only starting with Matlab 2018a
set(gca,'CLim',[1e11 5e14]);
