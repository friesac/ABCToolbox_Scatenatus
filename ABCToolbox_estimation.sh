#!/bin/bash

# ABC shell script to run estimation on models and populations

# Call it this way: ./ABCToolbox_estimation.sh [population] [model] [params] [# retained sims] [# of max total sims to read] [path_to_results] 

#------ Specify the parameters of the run -----
population=$1
model=$2
parameters=$3
retainedSims=$4
maxSimsToConsider=$5
pathToResults=$6
approx_run_date=$(date +%F-%k-%M) # Date variable for naming directories.

#------ Just some formatting for the script -----
bold=$(tput bold)
normal=$(tput sgr0)


echo ""
echo "Estimating the parameters for the ${bold}${population}${normal} population in ${bold}${model}${normal}: using ${bold}${retainedSims}${normal} from a total of ${bold}${maxSimsToConsider}${normal} simulations"
echo ""
# This will be in the $Population_$Model_MCMC directory.
cd $HOME/Scate_msat${pathToResults}
echo "Current Directory: ${bold}$PWD${normal}"
echo ""
echo ""

# Create a unique folder to store results then go into it and start making the files for the run.
mkdir $HOME/Scate_msat${pathToResults}/Estimation_Results_${approx_run_date} 2>/dev/null
cd $HOME/Scate_msat${pathToResults}/Estimation_Results_${approx_run_date}
outDir=$PWD

echo "Results from this estimation will go to ${bold}${outDir}${normal}"
echo ""

# Edit the estimation input file to contain information from your command line inputs
echo "... updating ABC estimation file with run parameters"
echo ""
cp $HOME/Scate_msat/template_estimation.input ${model}_estimation.input
sed "s/dummy_model/$model/g" -i ${model}_estimation.input
sed "s/dummy_pop/$population/g" -i ${model}_estimation.input
sed "s/dummy_retain/$retainedSims/g" -i ${model}_estimation.input
sed "s/dummy_max_read/$maxSimsToConsider/g" -i ${model}_estimation.input
sed "s/dummy_param/$parameters/g" -i ${model}_estimation.input

#copy files to run directory
cp $HOME/Scate_msat/obs/Scate_17micro_${population}.obs .
cp $HOME/Scate_msat/binaries/ABCestimator .

chmod +x ABCsampler

##./ABCsampler ${model}_estimation.input
rm ABCestimator
