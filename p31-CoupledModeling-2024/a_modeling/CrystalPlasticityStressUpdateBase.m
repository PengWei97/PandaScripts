classdef CrystalPlasticityStressUpdateBase < handle
  properties
      baseName
      crystalLatticeType
      unitCellDimension
      numberSlipSystems
      slipSysFileName
      numberCrossSlipDirections
      numberCrossSlipPlanes
      relStateVarTol
      slipIncrTol
      resistanceTol
      zeroTol
      slipResistance
      slipResistanceOld
      slipIncrement
      slipDirection
      slipPlaneNormal
      flowDirection
      tau
      printConvergenceMessage
      substepDt
      crossSlipFamilies
      calculateCrossSlip
      qp
  end
  
  methods
      function obj = CrystalPlasticityStressUpdateBase(parameters)
          % Constructor
          obj.baseName = parameters.baseName;
          obj.crystalLatticeType = parameters.crystalLatticeType;
          obj.unitCellDimension = parameters.unitCellDimension;
          obj.numberSlipSystems = parameters.numberSlipSystems;
          obj.slipSysFileName = parameters.slipSysFileName;
          obj.numberCrossSlipDirections = parameters.numberCrossSlipDirections;
          obj.numberCrossSlipPlanes = parameters.numberCrossSlipPlanes;
          obj.relStateVarTol = parameters.relStateVarTol;
          obj.slipIncrTol = parameters.slipIncrTol;
          obj.resistanceTol = parameters.resistanceTol;
          obj.zeroTol = parameters.zeroTol;
          obj.slipResistance = zeros(1, obj.numberSlipSystems);
          obj.slipResistanceOld = zeros(1, obj.numberSlipSystems);
          obj.slipIncrement = zeros(1, obj.numberSlipSystems);
          obj.slipDirection = zeros(3, obj.numberSlipSystems);
          obj.slipPlaneNormal = zeros(3, obj.numberSlipSystems);
          obj.flowDirection = cell(1, obj.numberSlipSystems);
          for i = 1:obj.numberSlipSystems
              obj.flowDirection{i} = zeros(3);
          end
          obj.tau = zeros(1, obj.numberSlipSystems);
          obj.printConvergenceMessage = parameters.printConvergenceMessage;
          obj.substepDt = 0;
          obj.crossSlipFamilies = [];
          obj.calculateCrossSlip = false;
          
          obj.getSlipSystems();
          obj.sortCrossSlipFamilies();
      end
      
      function setQp(obj, qp)
          obj.qp = qp;
      end
      
      function setSubstepDt(obj, substepDt)
          obj.substepDt = substepDt;
      end
      
      function initQpStatefulProperties(obj)
          obj.setMaterialVectorSize();
      end
      
      function setMaterialVectorSize(obj)
          obj.tau(obj.qp) = 0;
          obj.flowDirection{obj.qp} = zeros(3);
          obj.slipResistance(obj.qp) = 0;
          obj.slipIncrement(obj.qp) = 0;
      end
      
      function getSlipSystems(obj)
          % Read slip systems from file
          data = readmatrix(obj.slipSysFileName);
          if size(data, 1) ~= obj.numberSlipSystems
              error('The number of rows in the slip system file should match the number of slip systems.');
          end
          
          for i = 1:obj.numberSlipSystems
              obj.slipDirection(:, i) = data(i, 4:6)';
              obj.slipPlaneNormal(:, i) = data(i, 1:3)';
          end
          
          for i = 1:obj.numberSlipSystems
              obj.slipPlaneNormal(:, i) = obj.slipPlaneNormal(:, i) / norm(obj.slipPlaneNormal(:, i));
              obj.slipDirection(:, i) = obj.slipDirection(:, i) / norm(obj.slipDirection(:, i));
          end
      end
      
      function sortCrossSlipFamilies(obj)
          if obj.numberCrossSlipDirections == 0
              obj.crossSlipFamilies = [];
              return;
          end
          
          obj.crossSlipFamilies = cell(obj.numberCrossSlipDirections, 1);
          familyCounter = 1;
          obj.crossSlipFamilies{1} = 1;
          
          for i = 2:obj.numberSlipSystems
              foundFamily = false;
              for j = 1:familyCounter
                  dotProduct = abs(obj.slipDirection(:, obj.crossSlipFamilies{j}(1))' * obj.slipDirection(:, i));
                  if dotProduct == 1
                      obj.crossSlipFamilies{j} = [obj.crossSlipFamilies{j}, i];
                      foundFamily = true;
                      break;
                  end
              end
              
              if ~foundFamily
                  familyCounter = familyCounter + 1;
                  obj.crossSlipFamilies{familyCounter} = i;
              end
          end
      end
      
      function calculateFlowDirection(obj, crysrot)
          obj.calculateSchmidTensor(obj.slipPlaneNormal, obj.slipDirection, crysrot);
      end
      
      function calculateSchmidTensor(obj, planeNormalVector, directionVector, crysrot)
          localDirectionVector = zeros(size(directionVector));
          localPlaneNormal = zeros(size(planeNormalVector));
          
          for i = 1:obj.numberSlipSystems
              localDirectionVector(:, i) = crysrot * directionVector(:, i);
              localPlaneNormal(:, i) = crysrot * planeNormalVector(:, i);
              obj.flowDirection{obj.qp} = localDirectionVector(:, i) * localPlaneNormal(:, i)';
          end
      end
      
      function calculateShearStress(obj, pk2, inverseEigenstrainDeformationGrad, numEigenstrains)
          if numEigenstrains == 0
              for i = 1:obj.numberSlipSystems
                  obj.tau(obj.qp) = pk2(:)' * obj.flowDirection{obj.qp}(:);
              end
          else
              eigenstrainDeformationGrad = inv(inverseEigenstrainDeformationGrad);
              for i = 1:obj.numberSlipSystems
                  pk2_hat = det(eigenstrainDeformationGrad) * eigenstrainDeformationGrad' * pk2 * inverseEigenstrainDeformationGrad';
                  obj.tau(obj.qp) = pk2_hat(:)' * obj.flowDirection{obj.qp}(:);
              end
          end
      end
      
      function calculateTotalPlasticDeformationGradientDerivative(obj, dfpinvdpk2, inversePlasticDeformationGradOld, inverseEigenstrainDeformationGradOld, numEigenstrains)
          dslip_dtau = zeros(1, obj.numberSlipSystems);
          dtaudpk2 = cell(1, obj.numberSlipSystems);
          dfpinvdslip = cell(1, obj.numberSlipSystems);
          
          obj.calculateConstitutiveSlipDerivative(dslip_dtau);
          
          for j = 1:obj.numberSlipSystems
              if numEigenstrains > 0
                  eigenstrainDeformationGradOld = inv(inverseEigenstrainDeformationGradOld);
                  dtaudpk2{j} = det(eigenstrainDeformationGradOld) * eigenstrainDeformationGradOld * obj.flowDirection{obj.qp} * inverseEigenstrainDeformationGradOld;
              else
                  dtaudpk2{j} = obj.flowDirection{obj.qp};
              end
              dfpinvdslip{j} = -inversePlasticDeformationGradOld * obj.flowDirection{obj.qp};
              dfpinvdpk2 = dfpinvdpk2 + dfpinvdslip{j} * dslip_dtau(j) * obj.substepDt * dtaudpk2{j};
          end
      end
      
      function calculateEquivalentSlipIncrement(obj, equivalentSlipIncrement)
          for i = 1:obj.numberSlipSystems
              equivalentSlipIncrement = equivalentSlipIncrement + obj.flowDirection{obj.qp} * obj.slipIncrement(obj.qp) * obj.substepDt;
          end
      end
      
      function isConverged = isConstitutiveStateVariableConverged(obj, currentVar, varBeforeUpdate, previousSubstepVar, tolerance)
          isConverged = true;
          sz = length(currentVar);
          for i = 1:sz
              diffVal = abs(varBeforeUpdate(i) - currentVar(i));
              absPrevSubstepVal = abs(previousSubstepVar(i));
              
              if absPrevSubstepVal < obj.zeroTol && diffVal > obj.zeroTol
                  isConverged = false;
              elseif absPrevSubstepVal > obj.zeroTol && diffVal > tolerance * absPrevSubstepVal
                  isConverged = false;
              end
          end
      end
  end
end
