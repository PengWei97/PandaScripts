% calculatedGrainSizeDistribution.m
%
% Purpose:
% This function calculates the grain size distribution in terms of both number fraction
% and area fraction. The grain sizes are normalized to the sample region.
%
% Inputs:
% - grainSize: An array of grain sizes
% - boxArea: The total area of the sample region
% - edges: The edges of the bins for the grain size distribution
% - grainSizeDistribution: A table to store the grain size distribution results
%
% Output:
% - grainSizeDistribution: Updated table containing number fraction and area fraction

function grainSizeDistribution = calculatedGrainSizeDistribution(grainSize, boxArea, edges, grainSizeDistribution)
    % Calculate grain area and radius
    grainArea = grainSize ./ sum(grainSize) .* boxArea;  % Normalize grain areas to the sample region
    grainRadius = sqrt(grainArea ./ pi);  % Calculate radius of each grain
    weightedGrainRadius = sum(grainRadius .* grainArea) / sum(grainArea);  % Calculate weighted average radius
    normalizedGrainRadius = grainRadius ./ weightedGrainRadius;  % Normalize grain radii

    % Calculate number fraction & area fraction
    numCounts = zeros(length(edges) - 1, 1);
    binAreas = zeros(length(edges) - 1, 1);
    for i = 1:(length(edges) - 1)
        % Find grains within each bin
        inBin = (normalizedGrainRadius >= edges(i)) & (normalizedGrainRadius < edges(i + 1));
        numCounts(i) = sum(inBin);
        binAreas(i) = sum(grainArea(inBin));
    end
    grainSizeDistribution.numFraction = numCounts ./ sum(numCounts);  % Calculate number fraction
    grainSizeDistribution.areaFraction = binAreas ./ sum(grainArea);  % Calculate area fraction
end
