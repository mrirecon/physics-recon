
import os
import os.path
import sys
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))

from cfl import readcfl
from cfl import writecfl
import numpy as np

import scipy.misc
from scipy import ndimage
#import sys

import importlib

import matplotlib as mpl
mpl.use('Agg')

import matplotlib.pyplot as plt
import numpy as np
import math
from random import randrange


def array_plot1(arr, rows=4, cols=4):
    plt.rcParams.update({'font.size': 25})
    idx = 0
    fig = plt.figure(figsize = [6.4*2, 4.8*2])
    xticks = 20.3e-3*np.arange(0, len(arr[:,idx]), 1)
    for idx in range(rows*cols):
        plt.plot(xticks, (arr[:,idx]),linewidth=3, markersize=15,label="Comp. {}".format(idx+1))
        plt.legend()
        idx += 1 
    plt.xlabel('Time / s')
    plt.ylabel('Signal')
    plt.title('Temporal Subspace Curves')

    plt.savefig('Figure5A_IR-Subspace.eps');

 
def array_plot2(arr, rows=4, cols=4):
    plt.rcParams.update({'font.size': 25})
    idx = 0
    fig = plt.figure(figsize = [6.4*2, 4.8*2], num=1)
    xticks = 20.3e-3*np.arange(0, len(arr[:,idx]), 1)
    for idx in range(rows*cols):
        plt.plot(xticks, np.real(arr[:,idx]),linewidth=3, label=str(idx))
        idx += 1 
    plt.xlabel('Time / s')
    #plt.legend()
    plt.ylabel('Signal')
    plt.title('Simulated Dictionary (subset)')

    plt.savefig('Figure5A_IR-Dictionary.eps');

#---------------------------------------------------------------#
Signal = readcfl("./T1_dict")

if False:
    random_index = list(np.random.choice(100000, 7, replace=False))
else:
    random_index = [18921, 47522, 45034, 14515, 90331, 7023, 74182]
Signal1 = Signal[:,random_index]
array_plot2(Signal1, rows=7, cols=1)


S = readcfl("./T1_S")

U = readcfl("./T1_U")


U_truc = U[:,0:5]

array_plot1(U_truc, rows=5, cols=1)


S1 = S/np.max(abs(S))

S2 = np.cumsum(S1,axis=0)

xticks = np.arange(1, 31, 1)
fig = plt.figure(figsize = [6.4*2, 4.8*2])
plt.rcParams.update({'font.size': 25})
plt.plot(xticks, abs(S2[0:30])/S2[-1],'b^-',linewidth=3, markersize=15)
plt.xlabel('Principal Component')
plt.ylabel('Percentage [100%]')
plt.title('Accumulated PCA Coefficients')

plt.savefig('Figure5A_IR-Coefficients.eps');


