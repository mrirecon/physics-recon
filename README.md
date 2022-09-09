##

This repository provides the scripts to reproduce the results presented in:

Xiaoqing Wang, Zhengguo Tan, Nick Scholand, Volkert Roeloffs, Martin Uecker.
Physics-based Reconstruction Methods for Magnetic Resonance Imaging.
Phil. Trans. R. Soc. A 379:20200196 (2021) DOI:10.1098/rsta.2020.0196

# Data

Data is available at DOI: 10.5281/zenodo.4060286. The script `load-all.sh`
will download all data from this address into the subfolder `data`.

# Reconstruction

The script `all.sh` can be used to run all reconstructions.

Total runtime of these scripts should around 30 min to 1.5 h.

# BART version

All reconstructions are based on the Berkeley Advanced Reconstruction Toolbox
(BART) (commit e199148). GPU support is required.

# Additional Scripts and Figure Generation

Apart from BART, some analysis scripts use the `cfl2png` tool from the BART viewer,
available at https://github.com/mrirecon/view
Further, some analysis scripts use Python 3 and the `numpy`, `scipy`, and `matplotlib`
packages.
