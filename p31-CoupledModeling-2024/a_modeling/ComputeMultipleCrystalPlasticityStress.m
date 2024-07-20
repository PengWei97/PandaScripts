classdef ComputeMultipleCrystalPlasticityStress < handle
  properties
      numModels
      models
      numEigenstrains
      eigenstrains
      baseName
      elasticityTensor
      rtol
      absTol
      residualTensor
      jacobian
      maxIter
      maxIterG
      tanModType
      maxSubstepIter
      substepDt
      useLineSearch
      minLineSearchStepSize
      lineSearchTolerance
      lineSearchMaxIterations
      lineSearchMethod
      plasticDeformationGradient
      plasticDeformationGradientOld
      eigenstrainDeformationGradient
      eigenstrainDeformationGradientOld
      deformationGradient
      deformationGradientOld
      pk2
      pk2Old
      totalLagrangianStrain
      updatedRotation
      crysrot
      temporaryDeformationGradient
      elasticDeformationGradient
      inversePlasticDeformationGrad
      inversePlasticDeformationGradOld
      inverseEigenstrainDeformationGrad
      printConvergenceMessage
      convergenceFailed
      deltaDeformationGradient
      temporaryDeformationGradientOld
      dfgrdScaleFactor
      qp
  end
  
  methods
      function obj = ComputeMultipleCrystalPlasticityStress(parameters)
          % Constructor
          obj.numModels = length(parameters.crystalPlasticityModels);
          obj.numEigenstrains = 0; %length(parameters.eigenstrainNames);
          obj.baseName = parameters.baseName;
          obj.elasticityTensor = parameters.elasticityTensor;
          obj.rtol = parameters.rtol;
          obj.absTol = parameters.absTol;
          obj.maxIter = parameters.maxIter;
          obj.maxIterG = parameters.maxIterG;
          obj.tanModType = parameters.tanModType;
          obj.maxSubstepIter = parameters.maxSubstepIter;
          obj.useLineSearch = parameters.useLineSearch;
          obj.minLineSearchStepSize = parameters.minLineSearchStepSize;
          obj.lineSearchTolerance = parameters.lineSearchTolerance;
          obj.lineSearchMaxIterations = parameters.lineSearchMaxIterations;
          obj.lineSearchMethod = parameters.lineSearchMethod;
          obj.plasticDeformationGradient = zeros(3);
          obj.plasticDeformationGradientOld = zeros(3);
          obj.eigenstrainDeformationGradient = zeros(3);
          obj.eigenstrainDeformationGradientOld = zeros(3);
          obj.deformationGradient = zeros(3);
          obj.deformationGradientOld = zeros(3);
          obj.pk2 = zeros(3);
          obj.pk2Old = zeros(3);
          obj.totalLagrangianStrain = zeros(3);
          obj.updatedRotation = zeros(3);
          obj.crysrot = zeros(3);
          obj.temporaryDeformationGradient = zeros(3);
          obj.elasticDeformationGradient = zeros(3);
          obj.inversePlasticDeformationGrad = zeros(3);
          obj.inversePlasticDeformationGradOld = zeros(3);
          obj.inverseEigenstrainDeformationGrad = zeros(3);
          obj.printConvergenceMessage = parameters.printConvergenceMessage;
          obj.convergenceFailed = false;
          obj.deltaDeformationGradient = zeros(3);
          obj.temporaryDeformationGradientOld = zeros(3);
          obj.dfgrdScaleFactor = 1;
          obj.qp = 1;
          
          obj.models = cell(1, obj.numModels);
          obj.eigenstrains = cell(1, obj.numEigenstrains);

          for i = 1:obj.numModels
            obj.models{i} = parameters.crystalPlasticityModels{i};
          end

      end
      
      function initialSetup(obj)
          % Initialize crystal plasticity models
          for i = 1:obj.numModels
              model = obj.models{i};
              if isa(model, 'CrystalPlasticityStressUpdateBase')
                  obj.models{i} = model;
              else
                  error('Model %s is not compatible with ComputeMultipleCrystalPlasticityStress', obj.models{i});
              end
          end
          
          % Initialize crystal plasticity eigenstrains
          for i = 1:obj.numEigenstrains
              eigenstrain = obj.eigenstrains{i};
              if isa(eigenstrain, 'ComputeCrystalPlasticityEigenstrainBase')
                  obj.eigenstrains{i} = eigenstrain;
              else
                  error('Eigenstrain %s is not compatible with ComputeMultipleCrystalPlasticityStress', obj.eigenstrains{i});
              end
          end
      end
      
      function computeQpStress(obj)
          for i = 1:obj.numModels
              obj.models{i}.setQp(obj.qp);
              obj.models{i}.setMaterialVectorSize();
          end
          
          for i = 1:obj.numEigenstrains
              obj.eigenstrains{i}.setQp(obj.qp);
          end
          
          obj.updateStress();
      end
      
      function updateStress(obj)
          % Placeholder for the actual stress update implementation
      end
  end
end
