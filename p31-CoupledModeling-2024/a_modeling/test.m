%%%%%%%%%%%%%%%%%%%%%%%%%%%% elasticity tensor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define paramters for ComputeElasticityTensorCP
cpElasticityParams = struct( ...
    'EulerAnglesMatProp', [30, 45, 60], ... %  Example Euler angles (in degrees)
    'C_ijkl', [1.684e5, 1.214e5, 1.214e5, 1.684e5, 1.214e5, 1.684e5, ...
        0.754e5, 0.754e5, 0.754e5] ... % C_ijkl values (for testing)
);

% Create an instance of CrystalPlasticityStressUpdateBase
cpElasticity = ComputeElasticityTensorCP(cpElasticityParams);
cpElasticity.computeQpElasticityTensor(); % Update the elasticity tensor with the rotation matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%% crystal plasticity model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define parameters for CrystalPlasticityStressUpdateBase
cpStressParams = struct( ...
    'baseName', 'CrystalPlasticityModel', ...
    'crystalLatticeType', 'FCC', ...
    'unitCellDimension', 1.0, ...
    'numberSlipSystems', 12, ...
    'slipSysFileName', 'slip_systems.csv', ...
    'numberCrossSlipDirections', 2, ...
    'numberCrossSlipPlanes', 3, ...
    'relStateVarTol', 1e-6, ...
    'slipIncrTol', 1e-6, ...
    'resistanceTol', 1e-6, ...
    'zeroTol', 1e-12, ...
    'printConvergenceMessage', true ...
);

% Create an instance of CrystalPlasticityStressUpdateBase
cpStressUpdate = CrystalPlasticityStressUpdateBase(cpStressParams);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% multiple crystal plasticity kinetics %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define parameters for ComputeStressParams class
cmpStressParams = ComputeStressParams( ...
    'crystalPlasticityModels', {cpStressUpdate}, ...  % Placeholder for models
    'eigenstrainNames', {'Eigenstrain1', 'Eigenstrain2'}, ...  % Example eigenstrain names
    'baseName', 'ComputeStress', ...
    'elasticityTensor', cpElasticity.ElasticityTensor, ...
    'crysRot', cpElasticity.CrysRot, ...
    'rtol', 1e-6, ...
    'absTol', 1e-6, ...
    'maxIter', 100, ...
    'maxIterG', 50, ...
    'tanModType', 'default', ...
    'maxSubstepIter', 10, ...
    'useLineSearch', true, ...
    'minLineSearchStepSize', 1e-4, ...
    'lineSearchTolerance', 1e-5, ...
    'lineSearchMaxIterations', 20, ...
    'lineSearchMethod', 'backtracking', ...
    'printConvergenceMessage', true ...
);

% Create an instance of ComputeMultipleCrystalPlasticityStress
cmpStress = ComputeMultipleCrystalPlasticityStress(cmpStressParams);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% initiallization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the crystal plasticity models and eigenstrains
cmpStress.initialSetup();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the stress update for the models
cmpStress.computeQpStress();


% % Display information or results
% disp('Crystal Plasticity Stress Update and Computation Complete.');

% % You can also call other methods or access properties as needed
% % For example, display some properties
% disp('Slip System Directions:');
% disp(cpStressUpdate.slipDirection);

% disp('Flow Direction:');
% disp(cpStressUpdate.flowDirection);

% disp('Elasticity Tensor:');
% disp(cmpStress.elasticityTensor);

% disp('Plastic Deformation Gradient:');
% disp(cmpStress.plasticDeformationGradient);
