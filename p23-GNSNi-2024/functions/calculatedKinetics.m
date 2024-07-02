% calculateKinetics.m
%
% Purpose:
% This function calculates the kinetics data of grains, including the weighted average radius,
% the number of grains, and the weighted standard deviation.
%
% Inputs:
% - grainSize: An array containing the sizes of grains (including only values greater than zero)
% - boxArea: The total area of the sample region
%
% Outputs:
% - weightedAvgRadius: Weighted average radius
% - grainNumber: Number of grains
% - weightedStd: Weighted standard deviation

% Function to calculate kinetics data
function [weightedAvgRadius, grainNumber, weightedStd] = calculateKinetics(grainSize, boxArea)
  grainsArea = grainSize(grainSize > 0);
  grainsArea = grainsArea * boxArea / sum(grainsArea); % Normalize grain areas to the sample region
  grainsRadius = sqrt(grainsArea ./ pi); % Calculate radius
  grainNumber = length(grainsArea);
  weightedAvgRadius = sum(grainsRadius .* grainsArea) / sum(grainsArea);
  weightedStd = sqrt(sum((grainsRadius - weightedAvgRadius).^2 .* grainsArea) / sum(grainsArea)); % Weighted standard deviation
end