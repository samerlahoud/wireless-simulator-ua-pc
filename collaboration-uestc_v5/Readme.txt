- The simulation code uses CVX package cvxr.com/cvx/ with MOSEK solver for convex optimisation.
- The main file is named sim_run.m and includes the main configuration for the simulator (iterations, sectors, RBs, Pmax, …)
- The optimisation function is included in central_ee_maxlog_sinr_power_allocation_rb_gp.m

- The input of the simulator is provided by LTE system level simulator and mainly consists of the radio conditions of the users
- The output of the simulator is saved in a mat file provided for example and contains the power vector per RB, per user, …