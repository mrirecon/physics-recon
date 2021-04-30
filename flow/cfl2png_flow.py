#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
# Authors: 
# 2021 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
"""

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.cm as cm
import matplotlib.pyplot as plt
mpl.rcParams['savefig.pad_inches'] = 0

import os
import os.path
import sys

sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))

import cfl

import numpy as np
import pathlib

# %%
def full_frame(width=None, height=None):

    figsize = None if width is None else (width, height)
    fig = plt.figure(figsize=figsize)
    ax = plt.axes([0,0,1,1], frameon=False)
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)
    plt.autoscale(tight=True)

# %%
def save_pc_img(R, cmap_str, vmin, vmax, png_file, width=None, height=None):

    full_frame(width,height)

    plt.imshow(R, interpolation='none', cmap=cmap_str, vmin=vmin,vmax=vmax, aspect='auto')
    plt.savefig(png_file, bbox_inches='tight', dpi=100, pad_inches=0)
    plt.close()


# %%
orig_dir = os.getcwd()

# %%
MAG = np.flipud(np.squeeze(cfl.readcfl('MAG')))
VEL = np.flipud(np.squeeze(cfl.readcfl('VEL')))

saved_dir='png_moba_flow'
pathlib.Path(saved_dir).mkdir(parents=True, exist_ok=True) 
os.chdir(saved_dir)

for n in np.arange(MAG.shape[2]):
    
    mag_file = 'MAG_' + str(n).zfill(3)
    save_pc_img(np.absolute(MAG[:,:,n]), 'gray', 0, 700, mag_file, 4, 4)
    
    vel_file = 'VEL_' + str(n).zfill(3)
    save_pc_img(-VEL[:,:,n].real, 'RdBu_r', -150, 150, vel_file, 4, 4)

os.chdir(orig_dir)

# %%
R = np.flipud(np.squeeze(cfl.readcfl('R_PHASE_DIFFERENCE')))

saved_dir='png_phasediff_flow'
pathlib.Path(saved_dir).mkdir(parents=True, exist_ok=True) 
os.chdir(saved_dir)

MAG = np.sqrt(np.absolute(R))
VEL = np.multiply(np.angle(R), 150 / np.pi)

for n in np.arange(MAG.shape[2]):
    
    mag_file = 'MAG_' + str(n).zfill(3)
    save_pc_img(np.absolute(MAG[:,:,n]), 'gray', 0, 0.0003, mag_file, 4, 4)
    
    vel_file = 'VEL_' + str(n).zfill(3)
    save_pc_img(VEL[:,:,n].real, 'RdBu_r', -150, 150, vel_file, 4, 4)

os.chdir(orig_dir)
