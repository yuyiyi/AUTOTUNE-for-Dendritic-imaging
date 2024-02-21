# AUTOTUNE_GUIdevelopment                <img src = "https://github.com/yuyiyi/AUTOTUNE_GUIdevelopment/blob/1d73f8f0a6c8f2c092351ce8c045e4caf5805253/generalfun/Dendrite%20logo.png" width = "300" align = "right">

A Matlab GUI for dendritic and spine imaging analysis AUTOTUNE was developed at the University of California, Santa Barbara as an open-source research tool. 

AUTOTUNE implements essential methods to analyze functional imaging data of neuronal dendrites and spines, including but not limited to calcium imaging, voltage imaging, and glutamate imaging. It provides efficient algorithms for motion correction, feature extraction, and registering spines across multiple sessions. It is suitable for offline analysis of stimulus- and behavioral-selectivity, spine plasticity, and active dendritic compartments. 

![workflow](https://github.com/yuyiyi/AUTOTUNE-for-Dendritic-imaging/blob/main/util/githubpostfigure.jpg)

## Quick start 
Follow these three steps to get started quickly, from installation to working through a demo. 

### Step 1: Install AUTOTUNE
AUTOTUNE requires installation of MATLAB R2019a or higher, including the following toolboxes: Image Processing Toolbox, Curve Fitting Toolbox, Signal Processing Toolbox, Statistics and Machine Learning Toolbox, and Parallel Computing Toolbox. Download the GitHub repository of AUTOTUNE and place it in your local MATLAB path. To start the software, type AUTOTUNE in the MATLAB command window. To achieve smooth data processing, operating systems equipped with sufficient Random Access Memory (RAM) and a multicore Central Processing Unit (CPU) are recommended, but not required. 

### Step 2: Try out AUTOTUNE using demo data
A detailed user guide is provided in the main repository ([url](https://github.com/yuyiyi/AUTOTUNE_GUIdevelopment/blob/main/AUTOTUNE%20User%20Guide.pdf)). Follow the guide to experience all the functional modules AUTOTUNE has to offer (/DemoData/). 

### Step 3: Inspect saved results
Results are automatically graphed in popups and saved on local disk for user inspection
1.	Registration: registered movie in .bin or .tiff, a subsample of a registered movie in .tiff (optional), and *_RegParameter.mat/RegPara contains metadata and results of registration. RegPara contains pre- and post-registration z-projections (meanImg_PreReg and meanImg_PostReg), xy translation (dsall), registration correction (CorrAll), and meta information of registered movie (savename, binfilelength, Imagesize, Imagelength and so on). 

2.	Feature Detection: features are saved in a *_roi.mat file, which contains the location and time course of each feature grouped by spine, shaft (subregions on dendrites), and dendrites. If dendrites are available, the association between spines and dendrites is also saved. A set of parameters for feature detection (Feature_parameters) and the normalized average z-projection of the movie (im_norm) is available. 

3.	Spine Turnover analysis: SpineEvolveAnalysis_*.mat contains a table of cross-session aligned spine evolution data (spine_evolve), the number of spines that lost, retained and gain in each session, a table of cross-session aligned dendrites (Dendrite_CrossSess) is dendrites are available, file list for cross-session spine turnover analysis (filelist), target session for the cross-session analysis (crossSessAlign_target), and 

4.	Input mapping: trace after back propagated action potential (bAP) removal and trace after filtering are append to the feature structure (_bAPremoval, and _filt). If tuning analysis or behavioral relevant analysis were carried out, a StampResp* matrix or a BehavResp* matrix will be appended to the feature structure, as well as corresponding meta information.  
   
### Step 4: Edit default parameters
AUTOTUNE is set with robust default parameters that were empirically determined to suit typical in vivo imaging data. Some parameters are programmed as editable inputs in popup windows that appear during Feature Detection and Input Mapping modules. However, occasionally users may wish to edit these parameters to accommodate their unique applications. A list of editable parameters is provided in (/util/defaultparameter.m). Users can edit parameters for each module according to the commented instructions. 


## How to contribute
AUTOTUNE is an open-source software designed for systems neuroscientists performing in vivo experiments. Users from all over the world can help improve the work. Please provide feedback to the author.  
Contact: yiyiy@ucsb.edu for questions and requests about the program

## Citing AUTOTUNE and related papers
Yiyi Yu, Liam M. Adsit, Ikuko T. Smith, Comprehensive software suite for functional analysis and synaptic input mapping of dendritic spines imaged in vivo (Publication details will be updated)

## License
This project is licensed under the terms of GNU GENERAL PUBLIC LICENSE. 
