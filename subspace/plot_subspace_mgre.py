#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 23 21:22:56 2020

@author: Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
"""

import matplotlib as mpl
mpl.use('Agg')

import matplotlib.pyplot as plt

import matplotlib.cm as cm

import os
import os.path
import sys
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))

import cfl

import numpy
import random


# %%
def get_signal(signal):


    use_random_entries = False

    stored_entries = [52484, 5399, 39459, 58880, 11521, 31238, 50710]

    nr_samples = signal.shape[0]
    nr_dicts   = signal.shape[1]

    random.seed()

    nr_picks = 7

    mag = numpy.zeros((nr_samples, nr_picks))
    phi = numpy.zeros((nr_samples, nr_picks))

    for n in range(nr_picks):

        if use_random_entries:
            m = random.randint(0, nr_dicts-1)
        else:
            m = stored_entries[n]

        print(m)

        mag[:,n] = numpy.absolute(signal[:,m])
        phi[:,n] = numpy.angle(signal[:,m])

    return mag, phi

# %%
def plot_signal(mag, phi, singular_value, singular_vec, TE):

    nr_samples = mag.shape[0]
    nr_dicts   = mag.shape[1]

    plt.rcParams.update({'font.size': 25})
    
    # magnitude

    fig = plt.figure(figsize=[6.4*2,4.8*2])
    
    ax1 = plt.subplot(211)

    cmap = cm.rainbow(numpy.linspace(1.0, 0.0, nr_dicts))
    
    for n in range(nr_dicts):
        ax1.plot(TE, mag[:,n], linewidth=3, color=cmap[n])

    ax1.set_ylabel('Magnitude')
    plt.title('Simulated Dictionary (subset)')


    # phase

    ax2 = plt.subplot(212, sharex=ax1)

    cmap = cm.rainbow(numpy.linspace(1.0, 0.0, nr_dicts))
    
    for n in range(nr_dicts):

        ax2.plot(TE, phi[:,n], linewidth=3, color=cmap[n])

    ax2.set_xlabel('Time / ms')
    ax2.set_ylabel('Phase')

    plt.savefig('Figure5B_MGRE-Dictionary.eps')


    # singular value
    fig = plt.figure(figsize=[6.4*2,4.8*2])

    nr_sing_picks = 30
    S = numpy.absolute(singular_value)

    plt.plot(numpy.arange(nr_sing_picks)+1, numpy.cumsum(S[:nr_sing_picks])/numpy.sum(S), 
             'b^-',linewidth=3, markersize=15)
    plt.xlabel('Principal Component')
    plt.ylabel('Cumulative Sum')
    plt.title('Accumulated PCA Coefficients')
    
    plt.savefig('Figure5B_MGRE-Coefficients.eps')
    
    
    # singular vector
    fig = plt.figure(figsize=[6.4*2,4.8*2])
    
    ax1 = plt.subplot(211)
    
    ax2 = plt.subplot(212, sharex=ax1)

    nr_svec_picks = 5
    U_mag = numpy.absolute(singular_vec)
    U_phi = numpy.angle(singular_vec)
    
    for idx in range(nr_svec_picks):
        ax1.plot(TE, (U_mag[:,idx]),linewidth=3, markersize=15,label="Comp. {}".format(idx+1))
        ax1.legend()
        
        ax2.plot(TE, (U_phi[:,idx]),linewidth=3, markersize=15)

        idx += 1

    ax1.set_ylabel('Magnitude')
    
    ax2.set_xlabel('Time / ms')
    ax2.set_ylabel('Phase')
    
    
    
    
    
    ax1.set_title('Temporal Subspace Curves')
    
    plt.savefig('Figure5B_MGRE-Subspace.eps')
    

# %%
signal = cfl.readcfl("mgre_signal_sr")

mag, phi = get_signal(signal)

print(mag.shape)


singular_value = cfl.readcfl("mgre_S")

singular_vec = cfl.readcfl("mgre_U")

TE = numpy.squeeze(numpy.absolute(cfl.readcfl("TE")))

plot_signal(mag, phi, singular_value, singular_vec, TE)

