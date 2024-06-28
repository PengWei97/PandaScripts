% createdStatistics.m
%
% Purpose:
% This function calculates the grain size distribution statistics, including the edges of the bins,
% the number of bins, and the distribution table containing grain sizes, number fraction, and area fraction.
%
% Inputs:
% - numBins: The number of bins for the grain size distribution
% - maxGrainSize: The maximum grain size to be considered
%
% Outputs:
% - grainSizeDistribution: A table containing grain sizes, number fraction, and area fraction
% - edges: The edges of the bins
% - numBins: The number of bins

function [grainSizeDistribution, edges] = createdStatistics(numBins, maxGrainSize)
  fprintf('Running createdStatistics\n');

  % Calculate the edges of the bins
  edges = linspace(0, maxGrainSize, numBins + 1);
  
  % Calculate the width of each bin
  binWidth = edges(2) - edges(1);

  % Initialize the grain size distribution table with three columns: grainSize, numFraction, and areaFraction
  grainSizeDistribution = table('Size', [numBins, 3], ...
                                'VariableTypes', {'double', 'double', 'double'}, ...
                                'VariableNames', {'grainSize', 'numFraction', 'areaFraction'});

  % Calculate the center of each bin
  grainSizeDistribution.grainSize = edges(1:end-1)' + binWidth / 2;

  % Initialize number fraction and area fraction with zeros
  grainSizeDistribution.numFraction = zeros(numBins, 1);
  grainSizeDistribution.areaFraction = zeros(numBins, 1);
end
