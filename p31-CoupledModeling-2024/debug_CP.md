
# CP 本构失效

```bash
*** Warning ***
/home/pengwei/projects/panda/simulation/prm3/step01_elastic_energy/s2_bicrystal_cp_elastic3.i:313.3:
The following warning occurred in the MaterialBase 'trial_xtalpl' of type CPKalidindiFullyCoupledUpdate.

Maximum allowable slip increment exceeded 0.0253082

ComputeMultiCPStressFullyCoupled: Constitutive failure
To recover, the solution will fail and then be re-attempted with a reduced time step.


A MooseException was raised during FEProblemBase::computeResidualTags
ComputeMultiCPStressFullyCoupled: Constitutive failure
To recover, the solution will fail and then be re-attempted with a reduced time step.

Nonlinear solve did not converge due to DIVERGED_FUNCTION_DOMAIN iterations 0
 Solve Did NOT Converge!
Aborting as solve did not converge
```

```bash
_active_op_index: 1
~~~~~~~~~

Maximum allowable slip increment exceeded 0.0219279
Slip increment: 2.87882e+06
_substep_dt: 7.617e-09
_slip_incr_tol: 0.02
i: 0
_tau[_qp][i]: 29.714
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 10
```
- 问题出现在第一个滑移系中，针对新激活的序参数，给定形变梯度和上一步的形变梯度，获取了非常大的滑移增量
- 所以，是否是由于突然获取由于大的形变梯度，使得造成塑性模型无法很好的收敛
  - 创建一个新的只考虑晶体塑性本构的算例，突然加载一个02*BC的应力
- 解决方案是否需要开始时就对该element处的形变梯度进行分配处理？其物理意义如何？


- CPKalidindiFullyCoupledUpdate::CPStressFullyCoupledUpdateBase
- CPKalidindiFullyCoupledUpdate::calculateSlipRate()
- _slip_increment: 2.87882e+06 数值太大，上一步 _slip_increment 的平均值只有 0.15473999968531 时只有 0.000689038
- _tau[_qp][i]: 29.714 ~ applied_shear_stress ~ 
- (*_slip_resistance_gr[_active_op_index])[_qp][i]: 10 ~ slip_resistance_grX
- _active_op_index: 1 ~ 在激活新序参数时，本构计算失效


```bash
Time Step 27, time = 0.150255, dt = 0.0198742

Grain Tracker Status:
Grains active index 0: 1 -> 1
Grains active index 1: 1 -> 1

Finished inside of GrainTracker

ComputeMultiCPStressFullyCoupled::preSolveQp()
[_qp]: 3
_activate_op_index: 0
(*_vals[op_index])[_qp]: 0.96552
(*_pk2_gr[_active_op_index])[_qp]: (xx,xy,xz)=( 159.308, 2.61477e-07, 1.23963e-16)
(yx,yy,yz)=(2.61477e-07,  215.492, -4.67202e-16)
(zx,zy,zz)=(1.23963e-16, -4.67202e-16,  186.888)

_slip_increment[_qp][i]: 0.00400351
_substep_dt: 0.0198742
_tau[_qp][i]: 11.6775
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 10.895
_slip_increment[_qp][i]: 0.00406101
_substep_dt: 0.0198742
_tau[_qp][i]: 11.6858
```

```bash
Time Step 28, time = 0.151255, dt = 0.001

Grain Tracker Status:
Grains active index 0: 1 -> 1
Grains active index 1: 1 -> 1

Finished inside of GrainTracker

ComputeMultiCPStressFullyCoupled::preSolveQp()
[_qp]: 0
_activate_op_index: 1
(*_vals[op_index])[_qp]: 0.00784244
(*_pk2_gr[_active_op_index])[_qp]: (xx,xy,xz)=(       0,        0,        0)
(yx,yy,yz)=(       0,        0,        0)
(zx,zy,zz)=(       0,        0,        0)

CPStressFullyCoupledUpdateBase::calculateShearStress
[_qp]: 0
pk2: (xx,xy,xz)=(       0,        0,        0)
(yx,yy,yz)=(       0,        0,        0)
(zx,zy,zz)=(       0,        0,        0)

_flow_direction: (xx,xy,xz)=(       0,        0,       -0)
(yx,yy,yz)=(0.408248, 0.408248, -0.408248)
(zx,zy,zz)=(0.408248, 0.408248, -0.408248)

_tau: 0
_slip_increment[_qp][i]: 0
_substep_dt: 0.001
_tau[_qp][i]: 0
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 10

CPStressFullyCoupledUpdateBase::calculateShearStress
[_qp]: 0
pk2: (xx,xy,xz)=( 193.258, 1.67442e-06,        0)
(yx,yy,yz)=(1.67442e-06,  260.941,        0)
(zx,zy,zz)=(       0,        0,  190.268)

_flow_direction: (xx,xy,xz)=(       0,        0,       -0)
(yx,yy,yz)=(0.408248, 0.408248, -0.408248)
(zx,zy,zz)=(0.408248, 0.408248, -0.408248)

_tau: 28.8521
_slip_increment[_qp][i]: 1.59794e+06
_substep_dt: 0.001
_tau[_qp][i]: 28.8521
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 10

*** Warning ***
/home/pengwei/projects/panda/simulation/prm3/step01_elastic_energy/s2_bicrystal_cp_elastic3.i:313.3:
The following warning occurred in the MaterialBase 'trial_xtalpl' of type CPKalidindiFullyCoupledUpdate.

Maximum allowable slip increment exceeded 1.59794e+06

ComputeMultiCPStressFullyCoupled: Constitutive failure
To recover, the solution will fail and then be re-attempted with a reduced time step.


A MooseException was raised during FEProblemBase::computeResidualTags
ComputeMultiCPStressFullyCoupled: Constitutive failure
To recover, the solution will fail and then be re-attempted with a reduced time step.

Nonlinear solve did not converge due to DIVERGED_FUNCTION_DOMAIN iterations 0
 Solve Did NOT Converge!
Aborting as solve did not converge
```

```bash
Time Step 28, time = 0.151255, dt = 0.001

Grain Tracker Status:
Grains active index 0: 1 -> 1
Grains active index 1: 1 -> 1

Finished inside of GrainTracker

ComputeMultiCPStressFullyCoupled::preSolveQp()
[_qp]: 0
_activate_op_index: 0

crysrot: (xx,xy,xz)=(0.707107, -0.707107,        0)
(yx,yy,yz)=(0.707107, 0.707107,       -0)
(zx,zy,zz)=(       0,        0,        1)

(*_vals[op_index])[_qp]: 0.992158
(*_pk2_gr[_active_op_index])[_qp]: (xx,xy,xz)=( 186.207, 1.92663e-08, -8.6068e-16)
(yx,yy,yz)=(1.92663e-08,  243.397, 8.09613e-16)
(zx,zy,zz)=(-8.6068e-16, 8.09613e-16,  214.282)

CPStressFullyCoupledUpdateBase::calculateShearStress
[_qp]: 0
pk2: (xx,xy,xz)=( 186.207, 1.92663e-08, -8.6068e-16)
(yx,yy,yz)=(1.92663e-08,  243.397, 8.09613e-16)
(zx,zy,zz)=(-8.6068e-16, 8.09613e-16,  214.282)

_flow_direction: (xx,xy,xz)=(-2.77556e-17, -0.408248, 0.288675)
(yx,yy,yz)=(2.77556e-17, 0.408248, -0.288675)
(zx,zy,zz)=(3.92523e-17,  0.57735, -0.408248)

_tau: 11.8864
_slip_increment[_qp][i]: 0.00401236
_substep_dt: 0.001
_tau[_qp][i]: 11.8864
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 11.0887
CPStressFullyCoupledUpdateBase::calculateShearStress
[_qp]: 0
pk2: (xx,xy,xz)=( 186.641, 1.75092e-08, -3.84976e-16)
(yx,yy,yz)=(1.75092e-08,  242.888, 9.34699e-16)
(zx,zy,zz)=(-3.84976e-16, 9.34699e-16,  214.355)

_flow_direction: (xx,xy,xz)=(-2.77556e-17, -0.408248, 0.288675)
(yx,yy,yz)=(2.77556e-17, 0.408248, -0.288675)
(zx,zy,zz)=(3.92523e-17,  0.57735, -0.408248)

_tau: 11.6485
_slip_increment[_qp][i]: 0.00267757
_substep_dt: 0.001
_tau[_qp][i]: 11.6485
(*_slip_resistance_gr[_active_op_index])[_qp][i]: 11.0887
```+
