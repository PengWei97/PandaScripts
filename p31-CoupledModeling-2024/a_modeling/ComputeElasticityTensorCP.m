classdef ComputeElasticityTensorCP < handle
  % ComputeElasticityTensorCP defines an elasticity tensor material object
  % for crystal plasticity models. This class handles rotation matrices
  % and Euler angles for defining material properties.

  properties
      % Material property storing the values of Euler Angles
      C_ijkl
      EulerAnglesMatProp
      ElasticityTensor % Elasticity tensor
      CrysRot % Crystal Rotation Matrix for rotating slip system directions
  end

  methods
      function obj = ComputeElasticityTensorCP(parameters)
          % Constructor for ComputeElasticityTensorCP class
          % Inputs:
          %   parameters - struct containing initialization parameters      

          % Initialize properties with default values
          if isfield(parameters, 'EulerAnglesMatProp')
              obj.EulerAnglesMatProp = parameters.EulerAnglesMatProp;
          else
              obj.EulerAnglesMatProp = zeros(1, 3); % Default to zero if not provided
          end

          obj.CrysRot = obj.updateRotationMatrix(obj.EulerAnglesMatProp);
          obj.CrysRot = obj.CrysRot';

          % Elasticity tensor initialization based on C_ijkl
          if isfield(parameters, 'C_ijkl')
              obj.C_ijkl = parameters.C_ijkl;
          else
              % Default values for C_ijkl
              C_ijkl = [1.684e5, 1.214e5, 1.214e5, 1.684e5, 1.214e5, 1.684e5, ...
                        0.754e5, 0.754e5, 0.754e5];
              obj.C_ijkl = C_ijkl;
          end

          % Default fill method
          fill_method = 'symmetric9';
          obj.ElasticityTensor = obj.computeElasticityTensor(obj.C_ijkl, fill_method);
      end

      function computeQpElasticityTensor(obj)
          % Update the elasticity tensor
          obj.ElasticityTensor = obj.getRotationElasticityMatrix(obj.ElasticityTensor, obj.CrysRot);
      end
  end

  methods (Static)
      function R = updateRotationMatrix(euler_angles)
          % Computes the rotation matrix given the Euler angles.
          % euler_angles: A vector of 3 angles [phi_1, Phi, phi_2] in degrees.
          
          % Convert degrees to radians
          phi_1 = euler_angles(1) * (pi / 180.0);
          Phi = euler_angles(2) * (pi / 180.0);
          phi_2 = euler_angles(3) * (pi / 180.0);

          % Compute cosines and sines of the angles
          c1 = cos(phi_1);
          c2 = cos(Phi);
          c3 = cos(phi_2);

          s1 = sin(phi_1);
          s2 = sin(Phi);
          s3 = sin(phi_2);

          % Initialize the rotation matrix
          R = zeros(3, 3);

          % Perform the Z1, X2, Z3 rotation
          R(1, 1) = c1 * c3 - c2 * s1 * s3;
          R(1, 2) = c3 * s1 + c1 * c2 * s3;
          R(1, 3) = s2 * s3;

          R(2, 1) = -c1 * s3 - c2 * c3 * s1;
          R(2, 2) = c1 * c2 * c3 - s1 * s3;
          R(2, 3) = c3 * s2;

          R(3, 1) = s1 * s2;
          R(3, 2) = -c1 * s2;
          R(3, 3) = c2;
      end

      function C = computeElasticityTensor(C_ijkl, fill_method)
          % Compute the elasticity tensor from the provided C_ijkl values
          % C_ijkl is a vector of 9 values in the order [1111, 1122, 1133, 2222, 2233, 3333, 2323, 3131, 1212]
          % fill_method specifies the method for filling the tensor (e.g., 'symmetric9')

          if strcmp(fill_method, 'symmetric9')
              % Initialize a 3x3x3x3 tensor with zeros
              C = zeros(3, 3, 3, 3);
              
              % Assign values to the tensor based on the provided C_ijkl vector
              C(1, 1, 1, 1) = C_ijkl(1); % C1111
              C(2, 2, 2, 2) = C_ijkl(4); % C2222
              C(3, 3, 3, 3) = C_ijkl(6); % C3333

              C(1, 1, 2, 2) = C_ijkl(2); % C1122
              C(2, 2, 1, 1) = C_ijkl(2);

              C(1, 1, 3, 3) = C_ijkl(3); % C1133
              C(3, 3, 1, 1) = C_ijkl(3);

              C(2, 2, 3, 3) = C_ijkl(5); % C2233
              C(3, 3, 2, 2) = C_ijkl(5);

              C(2, 3, 2, 3) = C_ijkl(7); % C2323
              C(3, 2, 2, 3) = C_ijkl(7);
              C(3, 2, 3, 2) = C_ijkl(7);
              C(2, 3, 3, 2) = C_ijkl(7);

              C(1, 3, 1, 3) = C_ijkl(8); % C1313
              C(3, 1, 1, 3) = C_ijkl(8);
              C(3, 1, 3, 1) = C_ijkl(8);
              C(1, 3, 3, 1) = C_ijkl(8);

              C(1, 2, 1, 2) = C_ijkl(9); % C1212
              C(2, 1, 2, 1) = C_ijkl(9);
              C(2, 1, 1, 2) = C_ijkl(9);
              C(1, 2, 2, 1) = C_ijkl(9);
          else
              error('Unsupported fill method: %s', fill_method);
          end
      end

      function C_rot = getRotationElasticityMatrix(C, R)
        % Rotates the elasticity tensor using the given rotation matrix.
        % C: Original elasticity tensor (4D tensor of size 3x3x3x3)
        % R: Rotation matrix (3x3 matrix)
        
        % Initialize the rotated elasticity tensor
        C_rot = zeros(3, 3, 3, 3);
    
        % Rotate the elasticity tensor
        for i = 1:3
            for j = 1:3
                for k = 1:3
                    for l = 1:3
                        C_rot(i, j, k, l) = 0;
                        for m = 1:3
                            for n = 1:3
                                for o = 1:3
                                    for p = 1:3
                                        C_rot(i, j, k, l) = C_rot(i, j, k, l) + ...
                                            R(i, m) * R(j, n) * R(k, o) * R(l, p) * C(m, n, o, p);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
      end
  end % methods (Static)
end % classdef
