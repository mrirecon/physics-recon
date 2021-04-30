#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
# 
# Copyright 2020-2021. Uecker Lab, University Medical Center Goettingen.
#
# Author: xiaoqing.wang@med.uni-goettingen.de

"""

import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

import sys
import os
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))
import cfl
from matplotlib.ticker import FormatStrFormatter


class Plot(object):
   
        
    def __init__(self, data, ref, para, outfile):        
               
        dark = 0 #dark layout?
        
        if(dark):
            plt.style.use(['dark_background'])
        else:
            plt.style.use(['default'])
        
        mean = np.nanmean(np.where(data!=0,data,np.nan),axis=(0,1))
        std = np.nanstd(np.where(data!=0,data,np.nan),axis=(0,1))
                
        fig = plt.figure(num = 1, figsize=(6, 5.6))
        plt.rcParams.update({'font.size': 19})
        ax1 = fig.add_subplot(1,1,1)
                
        if (para == "T1"):
            k = 1            
            ax1.plot([0, 3], [0, 3], color='black')
            ticks = np.arange(0, 3.5, step=0.5)
            
        elif (para == "T2"):
            k = 2
            ax1.plot([0, 0.2], [0, 0.2], color='black')
            ticks = np.arange(0, 0.2 + 1./30, step=1./30)
            ref = ref[1:11]
            mean = mean[1:11]
            std = std[1:11]
            
        ax1.errorbar(ref, mean, std, 
        uplims=True, lolims=True,
        fmt='bx',linewidth=4, markersize=8)

        xlabel = 'Ground Truth $T_{' + str(k)+'}$ / s'
        ylabel = 'Estimated $T_{' + str(k) + '}$ / s'
        plt.legend(loc='upper left')
        ax1.set_xlabel(xlabel, fontsize=22)
        ax1.set_ylabel(ylabel, fontsize=22)
        ax1.grid()
        
        if (para == "T2"):
            ax1.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
            ax1.xaxis.set_major_formatter(FormatStrFormatter('%.2f'))
        
        plt.xticks(ticks)
        plt.yticks(ticks)
                
        plt.tight_layout()
        plt.show(block = True)
        
        fig.savefig(outfile + ".eps", format='eps', bbox_inches='tight', transparent=True)
  
if __name__ == "__main__":
    
    #Error if wrong number of parameters
    if( len(sys.argv) != 5):
        print( "Function for ploting estimated quantitative values against references." )
        print( "Usage: plot_T1T2_reference.py <infile data> <infile ref> <maptype(T1 or T2)> <outfile>" )
        exit()
        
    data = np.abs(cfl.readcfl(sys.argv[1]).squeeze())
    ref = np.abs(cfl.readcfl(sys.argv[2]).squeeze())

    data[np.isnan(data)] = 0
    ref[np.isnan(ref)] = 0
     
    Plot(data, ref, sys.argv[3], sys.argv[4])
