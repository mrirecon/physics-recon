#!/usr/bin/python3
# Variance
#!/bin/bash
# 
# Copyright 2020-2021. Uecker Lab, University Medical Center Göttingen.
#
# Author: xiaoqing.wang@med.uni-goettingen.de
#

import numpy as np
import cfl
from numpy import linalg as LA

# reference
T1_ref = np.squeeze(cfl.readcfl(str("./phan_ref_T1s")))
T1_ref = abs(T1_ref)
T1_ref[np.isnan(T1_ref)] = 0

# errors for linear subspace (number of subspace coefficients)
for k in range(4):
    k = k + 2
    data = "./subspace_T1map_C" + str(k)
    T1 =  abs(np.squeeze(cfl.readcfl(data)))
    T1[np.isnan(T1)] = 0
    T1_diff = T1 - T1_ref
    rela_diff = np.divide(T1_diff, T1_ref, out=np.zeros_like(T1_diff), where=T1_ref!=0)
    rela_diff[np.isnan(rela_diff)] = 0
    error = LA.norm(rela_diff)/LA.norm(abs(T1_ref))
    print(error)

# errors for linear subspace (regularization parameters)
for k in range(4):
    data = "./subspace_T1map_R" + str(k)
    T1 =  abs(np.squeeze(cfl.readcfl(data)))
    T1[np.isnan(T1)] = 0
    T1_diff = T1 - T1_ref
    rela_diff = np.divide(T1_diff, T1_ref, out=np.zeros_like(T1_diff), where=T1_ref!=0)
    rela_diff[np.isnan(rela_diff)] = 0
    error = LA.norm(rela_diff)/LA.norm(abs(T1_ref))
    print(error)
    
# errors for nonlinear moba (regularization parameters)
for k in range(4):
    data = "./moba_T1_masked_" + str(k)
    T1 =  abs(np.squeeze(cfl.readcfl(data)))
    T1[np.isnan(T1)] = 0
    T1_diff = T1 - T1_ref
    rela_diff = np.divide(T1_diff, T1_ref, out=np.zeros_like(T1_diff), where=T1_ref!=0)
    rela_diff[np.isnan(rela_diff)] = 0
    error = LA.norm(rela_diff)/LA.norm(abs(T1_ref))
    print(error)
