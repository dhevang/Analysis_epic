#! /bin/bash

### Stephen Kay, University of York
### 26/05/23
### stephen.kay@york.ac.uk
### A script to execute a series of simulations for the far backward pair spectrometer
### Input args are - NumFiles NumEventsPerFile Egamma_start (optional) Egamma_end (optional) Egamma_step (optional) Gun (optional)
### This file creates and submits the jobs
### 06/05/23 - This version is slightly different, it runs NumFiles of NumEvents PER BEAM ENERGY, in steps between Egamma_start/end. This is in steps of 0.5 GeV by default, can be specified in arg 5
### I.e. if you had 10 1000 5 8, you would get 10 files of 1000 events for 5, 5.5, 6, 6.5, 7, 7.5 and 8 GeV for a total of 70 files

# There's a lot of preamble including inputs and checks, the actual job creation and submission loop starts later, lines 146 - 197

SimDir="/group/eic/users/${USER}/ePIC"
echo "Running as ${USER}"
echo "Assuming simulation directory - ${SimDir}"
if [ ! -d $SimDir ]; then   
    echo "!!! WARNING !!!"
    echo "!!! $SimDir - Does not exist - Double check pathing and try again !!!"
    echo "!!! WARNNING !!!"
    exit 1
fi
 
NumFiles=$1 # First arg is the number of files to run - This is the number of files per energy!
if [[ -z "$1" ]]; then
    echo "I need a number of files to run per energy!"
    echo "Please provide a number of files to run as the first argument"
    exit 2
fi
NumEvents=$2 # Second argument is an output file name
if [[ -z "$2" ]]; then
    echo "I need a number of events to generate per file!"
    echo "Please provide a number of event to generate per file as the second argument"
    exit 3
fi

# Check if an argument was provided for Egamma_start, if not, set 10
re='^[0-9]+$'
if [[ -z "$3" ]]; then
    Egamma_start=10
    echo "Egamma_start not specified, defaulting to 10"
else
    Egamma_start=$3
    if ! [[ $Egamma_start =~ $re ]] ; then # Check it's an integer
	echo "!!! EGamma_start is not an integer !!!" >&2; exit 4
    fi
    if (( $Egamma_start > 25 )); then # If Egamma start is too high, set it to 25
	Egamma_start=25
    fi	
fi

# Check if an argument was provided for Egamma_end, if not, set 10
if [[ -z "$4" ]]; then
    Egamma_end=10
    echo "Egamma_end not specified, defaulting to 10"
else
    Egamma_end=$4
    if ! [[ $Egamma_end =~ $re ]] ; then # Check it's an integer
	echo "!!! EGamma_end is not an integer !!!" >&2; exit 5
    fi
    if (( $Egamma_end > 25 )); then # If Egamma end is too high, set it to 25
	Egamma_end=25
    fi	
fi

if [[ -z "$5" ]]; then
    Egamma_step="0.5"
    echo "Egamma step size not specified, defaulting to 0.5"
else
    Egamma_step=$5
fi
# Round the step size to 2 dp, if 0.00, set to 0.01 and warn
printf -v Egamma_step "%.2f" $Egamma_step
if [[ $Egamma_step == "0.00" ]];then
    echo; echo "!!!!!";echo "Warning, Egamma step size too low, setting to 0.01 by default"; echo "!!!!"; echo;
    Egamma_step="0.01"
fi

if [[ -z "$6" ]]; then
    Gun="False"
    echo "Gun argument not specified, assuming false and running lumi_particles.cxx"
else
    Gun=$6
fi

# Standardise capitlisation of true/false statement, catch any expected/relevant cases and standardise them
if [[ $Gun == "TRUE" || $Gun == "True" || $Gun == "true" ]]; then
    Gun="True"
elif [[ $Gun == "FALSE" || $Gun == "False" || $Gun == "false" ]]; then
    Gun="False"
fi
# Check gun is either true or false, if not, just set it to false
if [[ $Gun != "True" && $Gun != "False" ]]; then
    Gun="False"
    echo "Gun (arg 6) not supplied as true or false, defaulting to False. Enter True/False to enable/disable gun based event generation."
fi

if [[ -z "$7" ]]; then
    SpagCal="False"
    echo "SpagCal argument not specified, assuming false and running homogeneous calorimeter simulation"
else
    SpagCal=$7
fi

# Standardise capitlisation of true/false statement, catch any expected/relevant cases and standardise them
if [[ $SpagCal == "TRUE" || $SpagCal == "True" || $SpagCal == "true" ]]; then
    SpagCal="True"
elif [[ $SpagCal == "FALSE" || $SpagCal == "False" || $SpagCal == "false" ]]; then
    SpagCal="False"
fi
# Check gun is either true or false, if not, just set it to false
if [[ $SpagCal != "True" && $SpagCal != "False" ]]; then
    SpagCal="False"
    echo "SpagCal (arg 7) not supplied as true or false, defaulting to False. Enter True/False to enable/disable gun based event generation."
fi

if (( $Egamma_end < $Egamma_start )); then
    Egamma_end=$Egamma_start
fi

# A series of checks and warnings follows, these ensure that you don't submit large number of jobs without realising and that relevant directories exist
NumFilesTot=$(echo "scale=0; ((($Egamma_end-$Egamma_start)/$Egamma_step)*$NumFiles)" | bc)
if [[ $NumFilesTot -ge 500 ]]; then
    read -p "Warning, with specified arguments, this script will create and submit $NumFilesTot jobs. This is over the default max concurrent jobs on the farm, continue? <Y/N> " prompt
    if [[ $prompt == "n" || $prompt == "N" || $prompt == "no" || $prompt == "No" || $prompt == "NO" ]]; then
	echo "Exiting without submitting jobs, adjust number of files per energy or run regardless next time :)"
	exit 4
    else
	echo; echo "!!!!!"; echo "Creating and submitting jobs anyway - ctrl+c if this was a mistake!"; echo "!!!!!"; echo;
    fi
fi

echo; echo; echo "!!!!! NOTICE !!!!!"; echo "For now, the outputs generated by jobs from this script will go to a directory under /volatile, change this if you want to keep the files for longer!"; echo "!!!!! NOTICE !!!!!"; echo; echo;
if [ ! -d "/volatile/eic/${USER}" ]; then
    read -p "It looks like you don't have a directory in /volatile/eic, make one? <Y/N> " prompt2
    if [[ $prompt2 == "y" || $prompt2 == "Y" || $prompt2 == "yes" || $prompt2 == "Yes" || $prompt2 == "YES" ]]; then
	echo "Making a directory for you in /volatile/eic"
	mkdir "/volatile/eic/${USER}"
    else
	echo "If I don't make the directory, I won't have anywhere to output files!"
	echo "Ending here, modify the script and change the directories/paths if you actually want to run this script!"
	exit 5
    fi
fi

OutputPath="/volatile/eic/${USER}/FarBackward_Det_Sim"
if [ ! -d $OutputPath ]; then
    echo "It looks like the output path doesn't exist."
    echo "The script thinks this should be - ${OutputPath}"
    read -p "Make this directory? <Y/N> " prompt3
    if [[ $prompt3 == "y" || $prompt3 == "Y" || $prompt3 == "yes" || $prompt3 == "Yes" || $prompt3 == "YES"  ]]; then
	echo "Making directory - ${OutputPath}"
	mkdir $OutputPath
    else
	echo "If I don't make the directory, I won't have anywhere to output files!"
	echo "Ending here, modify the script and change the directories/paths if you actually want to run this script!"
	exit 6
    fi
fi

Workflow="ePIC_PairSpecSim_${USER}" # Change this as desired
export EICSHELL=${SimDir}/eic-shell
Disk_Space=$(( (($NumEvents +(5000/2) ) /5000) +1 )) # Request disk space depending upon number of simulated events requested, always round up to nearest integer value of GB, add 1 GB at end for safety too

for i in $(seq $Egamma_start $Egamma_step $Egamma_end); 
do
    for (( j=1; j<=$NumFiles; j++ ))
    do
	# Need to create Egamma_tmp for file/job naming purposes
	if [[ $Gun == "False" ]];then # Run job version depending upon gun arg, if true, use gun version of job
		if [[ $SpagCal == "False" ]]; then
	    	    Output_tmp="$OutputPath/PairSpecSim_${j}_${NumEvents}_${i/./p}_${i/./p}"
		else
		    Output_tmp="$OutputPath/PairSpecSim_SpagCal_${j}_${NumEvents}_${i/./p}_${i/./p}"
		fi
	elif [[ $Gun == "True" ]]; then
	    Output_tmp="$OutputPath/PairSpecSim_${j}_${NumEvents}_Gun_${i/./p}_${i/./p}"
	fi    
	if [ ! -d "${Output_tmp}" ]; then
	    mkdir $Output_tmp
	else
	    if [ "$(ls -A $Output_tmp)" ]; then # If directory is NOT empty, prompt a warning
		echo "!!!!! Warning, ${Output_tmp} directory exists and is not empty! Files may be overwritten! !!!!!"
	    fi
	fi
	batch="${SimDir}/ePIC_PairSpec_Sim/Farm_Bash_Scripts/FBPairSpec_Sim_${j}_${NumEvents}_${i/./p}_${i/./p}.txt"
	echo "Running ${batch}"
	cp /dev/null ${batch}
	echo "PROJECT: eic" >> ${batch}
	echo "TRACK: analysis" >> ${batch}    
	#echo "TRACK: debug" >> ${batch}
	if [[ $Gun == "False" ]];then
	    echo "JOBNAME: FBPairSpec_Sim_${j}_${NumEvents}_${i/./p}_${i/./p}" >> ${batch}
	elif [[ $Gun == "True" ]]; then
	    echo "JOBNAME: FBPairSpec_Sim_${j}_${NumEvents}_Gun_${i/./p}_${i/./p}" >> ${batch}
	fi
	if  [[ $NumEvents -ge 15000 ]]; then # If over 15k events per file, request 6 GB per job
	    echo "MEMORY: 6000 MB" >> ${batch}
	else
	    echo "MEMORY: 4000 MB" >> ${batch}
	fi
	echo "DISK_SPACE: ${Disk_Space} GB" >> ${batch} # Simulation output is the largest hog for this, request 1GB for 5k events simulated - See calculation before the for loop
	echo "CPU: 1" >> ${batch}
	echo "TIME: 1440" >> ${batch} # 1440 minutes -> 1 day
	if [[ $Gun == "False" ]];then # Run job version depending upon gun arg, if true, use gun version of job
		if [[ $SpagCal == "False" ]]; then
echo "COMMAND:${SimDir}/ePIC_PairSpec_Sim/Farm_Bash_Scripts/PairSpec_Sim_Job.sh ${j} ${NumEvents} ${i} ${i}" >> ${batch}	
		else
echo "COMMAND:${SimDir}/ePIC_PairSpec_Sim/Farm_Bash_Scripts/PairSpec_Sim_Job.sh ${j} ${NumEvents} ${i} ${i} ${SpagCal}" >> ${batch}		
		fi
	elif [[ $Gun == "True" ]]; then
	    echo "COMMAND:${SimDir}/ePIC_PairSpec_Sim/Farm_Bash_Scripts/PairSpec_Sim_Job_Gun.sh ${j} ${NumEvents} ${i} ${i}" >> ${batch}
	fi    
	echo "MAIL: ${USER}@jlab.org" >> ${batch}
	echo "Submitting batch"
	eval "swif2 add-jsub ${Workflow} -script ${batch} 2>/dev/null"
	echo " "
	sleep 2
	rm ${batch}
    done
done

eval 'swif2 run ${Workflow}'

exit 0
