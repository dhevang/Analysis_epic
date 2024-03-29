# Introduction

- This folder contains a bunch of scripts that can be utilised on the JLab farm to process large numbers of files quickly
- The scripts are, broadly speaking, split into two categories
  - Scripts that create and submit jobs
  - Scripts that are actually run in these jobs

# Warnings/Notes - Please read before trying to run anything!

- As of 27/06/23, some of the options for the scripts below require some updates to the main EICrecon directory and the epic detector directory
  - The epic detector directory has Aranya's WSciFi design included and corresponding new .xml files
  - EICrecon has a modified clustering module for the lumi cal
    - Number of elements for the homogeneous calorimeter is now changeable at run time, see comment in script, default is the regular 10x10 elements
      - EICrecon/src/detectors/LUMISPECCAL/ProtoCluster_factory_EcalLumiSpecIslandProtoClusters.h
    - New flag for SpagCal, off by default. If set to True (which can be done at run time), will use a different clustering routine
      - This is currently a work in progress, parameters for this have NOT been set correctly yet
- Note that you do NOT need to be in EIC_Shell to run these scripts, but it must be available
- The expected path is 
  - /group/eic/users/${USER}/ePIC/eic-shell
- Note that the scripts also make use of "Init_Env.sh"
  - Copy this script to /group/eic/users/${USER}/ePIC/ or your equivalent!
- My (SKay) repository is named slightly differently
  - To switch it back to "Analysis_epic", just run (from this directory)
    - sed -i "s%ePIC_PairSpec_Sim%Analysis_epic%" *.sh 

# Script Descriptions

- Please pay attention to the printouts from the scripts themselves!
- Pair_Spec_Sim.sh
	- Produce and run a set of simulations, 5 inputs
	  - Number of files
	  - Number of events per file
	  - Egamma_start
	  - Egamma_end
	  - Spag_Cal - True or false - WARNING, requires some extra files in EICRecon and the epic detector directory

- Pair_Spec_Sim_Job.sh
  - Script executed as a farm job, can run interactively
  - Generates events
  - Afterburns events
  - Processes event through simulation
  - Runs simulation output through reconstruction
  - 5 arguments
    	  - File number
	  - Number of events to process
	  - Egamma_start
	  - Egamma_end
	  - Spag_Cal - True or false - WARNING, requires some extra files in EICRecon and the epic detector directory
- Combine_Results_PairSpec_Sim.sh
  - Script to combine output after it has run into a single EICRecon file
  - Run this from the directory containing all of your output folders
  - The output is named based upon input arguments
  - 5 arguments
    	  - Number of files
	  - Number of events per file
	  - Egamma_start
	  - Egamma_end
	  - Spag_Cal - True or false - WARNING, requires some extra files in EICRecon and the epic detector directory

- Note that the Spag_Cal option is HIGHLY dated at this point and should not be used, will delete in future.

# Outdated Scripts

- Note that as of 14/02/24, the following scripts are slightly dated and not in regular use. Check before usage.


- Pair_Spec_Sim_Job_Gun.sh
  - Script executed as a farm job, can run interactively
  - Creates a steering file with a particle gun, settings depend upon input args
  - Generates events
  - Processes event through simulation
  - Runs simulation output through reconstruction
  - 4 arguments
    	  - File number
	  - Number of events to process
	  - Egamma_start

- Pair_Spec_Sim_v2.sh
  - Similar to the previous version, but with a subtle difference
    - Produces X files of Y event PER BEAM ENERGY in range from Egamma_start to Egamma_end (incremented in steps of Egamma_step)
  - Now has 7 arguments
    	  - Number of files per beam energy
	  - Number of events per file
	  - Egamma_start
	  - Egamma_end
	  - Egamma_step - Defaults to 0.5, can only go as low as 0.01
	  - Gun - True or False, run with a particle gun steering file or not
	  - Spag_Cal - True or false - WARNING, requires some extra files in EICRecon and the epic detector directory
- Combine_Results_PairSpec_Sim_v2.sh
  - Script to combine output after it has run into a single EICRecon file
  - Run this from the directory containing all of your output folders
  - 6 arguments
    	  - Number of files per beam energy
	  - Number of events per file
	  - Egamma_start
	  - Egamma_end
	  - Egamma_step
	  - Gun - True or false

