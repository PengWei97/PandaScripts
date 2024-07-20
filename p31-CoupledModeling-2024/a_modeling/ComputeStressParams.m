classdef ComputeStressParams
  properties
      crystalPlasticityModels
      eigenstrainNames
      baseName
      elasticityTensor
      rtol
      absTol
      maxIter
      maxIterG
      tanModType
      maxSubstepIter
      useLineSearch
      minLineSearchStepSize
      lineSearchTolerance
      lineSearchMaxIterations
      lineSearchMethod
      printConvergenceMessage
  end
  
  methods
      function obj = ComputeStressParams(varargin)
          % Default values for parameters
          p = inputParser;
          addParameter(p, 'crystalPlasticityModels', {});
          addParameter(p, 'eigenstrainNames', {});
          addParameter(p, 'baseName', '');
          addParameter(p, 'elasticityTensor', eye(3));
          addParameter(p, 'rtol', 1e-6);
          addParameter(p, 'absTol', 1e-6);
          addParameter(p, 'maxIter', 100);
          addParameter(p, 'maxIterG', 50);
          addParameter(p, 'tanModType', 'default');
          addParameter(p, 'maxSubstepIter', 10);
          addParameter(p, 'useLineSearch', true);
          addParameter(p, 'minLineSearchStepSize', 1e-4);
          addParameter(p, 'lineSearchTolerance', 1e-5);
          addParameter(p, 'lineSearchMaxIterations', 20);
          addParameter(p, 'lineSearchMethod', 'backtracking');
          addParameter(p, 'printConvergenceMessage', true);

          parse(p, varargin{:});

          % Assign values to properties
          obj.crystalPlasticityModels = p.Results.crystalPlasticityModels;
          obj.eigenstrainNames = p.Results.eigenstrainNames;
          obj.baseName = p.Results.baseName;
          obj.elasticityTensor = p.Results.elasticityTensor;
          obj.rtol = p.Results.rtol;
          obj.absTol = p.Results.absTol;
          obj.maxIter = p.Results.maxIter;
          obj.maxIterG = p.Results.maxIterG;
          obj.tanModType = p.Results.tanModType;
          obj.maxSubstepIter = p.Results.maxSubstepIter;
          obj.useLineSearch = p.Results.useLineSearch;
          obj.minLineSearchStepSize = p.Results.minLineSearchStepSize;
          obj.lineSearchTolerance = p.Results.lineSearchTolerance;
          obj.lineSearchMaxIterations = p.Results.lineSearchMaxIterations;
          obj.lineSearchMethod = p.Results.lineSearchMethod;
          obj.printConvergenceMessage = p.Results.printConvergenceMessage;
      end
  end
end
