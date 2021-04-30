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
def save_img(R, cmap_str, vmin, vmax, png_file, width=None, height=None):

    full_frame(width,height)

    plt.imshow(R, interpolation='none', cmap=cmap_str, vmin=vmin,vmax=vmax, aspect='auto')
    plt.savefig(png_file, bbox_inches='tight', dpi=100, pad_inches=0)
    plt.close()


# %%
orig_dir = os.getcwd()

# %%
Water = np.flipud(np.squeeze(cfl.readcfl('RECON_WATER_mask')))
Fat = np.flipud(np.squeeze(cfl.readcfl('RECON_FAT_mask')))
R2S = np.flipud(np.squeeze(cfl.readcfl('RECON_R2S_mask')))
FIELD = np.flipud(np.squeeze(cfl.readcfl('RECON_B0FIELD_mask')))

saved_dir='png_moba_wf'
pathlib.Path(saved_dir).mkdir(parents=True, exist_ok=True) 
os.chdir(saved_dir)

for n in np.arange(Water.shape[2]):
    
    water_file = 'Water_' + str(n).zfill(3)
    save_img(np.absolute(Water[:,:,n]), 'gray', 0, 1000, water_file, 4, 4)
    
    fat_file = 'Fat_' + str(n).zfill(3)
    save_img(np.absolute(Fat[:,:,n]), 'gray', 0, 1000, fat_file, 4, 4)
    
    r2s_file = 'R2S_' + str(n).zfill(3)
    save_img(R2S[:,:,n].real, 'hot', 0, 400, r2s_file, 4, 4)
    
    b0_file = 'fB0_' + str(n).zfill(3)
    save_img(FIELD[:,:,n].real, 'RdBu_r', -200, 200, b0_file, 4, 4)

os.chdir(orig_dir)
