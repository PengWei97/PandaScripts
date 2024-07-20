classdef ComputeMultipleCrystalPlasticityStress < handle
    % ComputeMultipleCrystalPlasticityStress - Handles multiple crystal plasticity models and stress computations.
    
    properties
        % Basic properties
        numModels  % Number of crystal plasticity models
        models  % Cell array of crystal plasticity models
        numEigenstrains  % Number of crystal plasticity eigenstrains
        eigenstrains  % Cell array of crystal plasticity eigenstrains
        baseName  % Base name for the computations
        
        % Input Material properties
        elasticityTensor  % Elasticity tensor
        updatedRotation  % Updated rotation matrix
        crysrot  % Crystal rotation matrix
        
        % Iteration settings
        rtol  % Relative tolerance for convergence
        absTol  % Absolute tolerance for convergence
        maxIter  % Maximum number of iterations
        maxIterG  % Maximum iterations for a specific algorithm
        tanModType  % Type of tangent modulus
        maxSubstepIter  % Maximum number of substep iterations
        substepDt  % Time step size for substeps
        
        % Line search settings
        useLineSearch  % Flag for using line search
        minLineSearchStepSize  % Minimum step size for line search
        lineSearchTolerance  % Tolerance for line search
        lineSearchMaxIterations  % Maximum number of iterations for line search
        lineSearchMethod  % Method used for line search
        
        % Deformation gradients and stresses
        plasticDeformationGradient  % Plastic deformation gradient
        plasticDeformationGradientOld  % Old plastic deformation gradient
        eigenstrainDeformationGradient  % Eigenstrain deformation gradient
        eigenstrainDeformationGradientOld  % Old eigenstrain deformation gradient
        deformationGradient  % Total deformation gradient
        deformationGradientOld  % Old total deformation gradient
        pk2  % PK2 stress
        pk2Old  % Old PK2 stress
        
        % Input strain
        totalLagrangianStrain  % Total Lagrangian strain
        
        % Intermediate calculations
        temporaryDeformationGradient  % Temporary deformation gradient
        elasticDeformationGradient  % Elastic deformation gradient
        inversePlasticDeformationGrad  % Inverse of plastic deformation gradient
        inversePlasticDeformationGradOld  % Old inverse of plastic deformation gradient
        inverseEigenstrainDeformationGrad  % Inverse of eigenstrain deformation gradient
        
        % Flags and scaling
        printConvergenceMessage  % Flag to print convergence message
        convergenceFailed  % Flag indicating whether convergence has failed
        deltaDeformationGradient  % Change in deformation gradient
        temporaryDeformationGradientOld  % Old temporary deformation gradient
        dfgrdScaleFactor  % Scale factor for deformation gradient
        qp  % Quadrature point index
    end
  
  methods
      function obj = ComputeMultipleCrystalPlasticityStress(parameters)
          % Constructor for ComputeMultipleCrystalPlasticityStress class.
          % Initializes the object with provided parameters and default values.

          % Set number of models and eigenstrains
          obj.numModels = length(parameters.crystalPlasticityModels);
          obj.numEigenstrains = 0; % Could be initialized based on parameters.eigenstrainNames
          
          % Set parameters from input
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
          obj.printConvergenceMessage = parameters.printConvergenceMessage;

          % Initialize cell arrays for models and eigenstrains
          obj.models = cell(1, obj.numModels);
          obj.eigenstrains = cell(1, obj.numEigenstrains);

          % Assign the models to the cell array
          for i = 1:obj.numModels
              obj.models{i} = parameters.crystalPlasticityModels{i};
          end

          % Initialize arrays and matrices to zeros
          obj.plasticDeformationGradient = eye(3);
          obj.plasticDeformationGradientOld = eye(3);
          obj.eigenstrainDeformationGradient = eye(3);
          obj.eigenstrainDeformationGradientOld = eye(3);
          obj.deformationGradient = eye(3);
          obj.deformationGradientOld = eye(3);
          obj.pk2 = eye(3);
          obj.pk2Old = eye(3);
          obj.totalLagrangianStrain = zeros(3);
          obj.updatedRotation = eye(3);
          obj.crysrot = parameters.crysRot;
          obj.temporaryDeformationGradient = eye(3);
          obj.elasticDeformationGradient = eye(3);
          obj.inversePlasticDeformationGrad = eye(3);
          obj.inversePlasticDeformationGradOld = eye(3);
          obj.inverseEigenstrainDeformationGrad = eye(3);
          obj.convergenceFailed = false;
          obj.deltaDeformationGradient = zeros(3);
          obj.temporaryDeformationGradientOld = zeros(3);
          obj.dfgrdScaleFactor = 1;
          obj.qp = 1;
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
