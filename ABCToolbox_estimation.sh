#!/bin/bash

# ABC shell script to run estimation on models and populations

# Call it this way: ./ABCToolbox_estimation.sh [population] [model] [params ex:1-3,5] [# retained sims] [# of max total sims to read] [path_to_results] [tolerance]

#------ Specify the parameters of the run -----
population=$1
model=$2
parameters=$3
retainedSims=$4
maxSimsToConsider=$5
pathToResults=$6
tolerance=$7
approx_run_date=$(date +%F-%s) # Date variable for naming directories.

#------ Just some formatting for the script -----
bold=$(tput bold)
normal=$(tput sgr0)


echo ""
echo "Estimating the parameters for the ${bold}${population}${normal} population in ${bold}${model}${normal}: using ${bold}${retainedSims}${normal} from a total of ${bold}${maxSimsToConsider}${normal} simulations"
echo ""
# This will be in the $Population_$Model_MCMC directory.
cd $HOME/Scate_msat/${pathToResults}
echo "Current Directory: ${bold}$PWD${normal}"
echo ""
echo ""

./MCMC_compiler.sh

cp $HOME/Scate_msat/grepper_checker.sh .
sed "s/dummy_model/$model/g" -i grepper_checker.sh

# Create a unique folder to store results then go into it and start making the files for the run.
mkdir $HOME/Scate_msat/${pathToResults}/Estimation_Results_${approx_run_date} 2>/dev/null
cp ../PLS.txt $HOME/Scate_msat/${pathToResults}/Estimation_Results_${approx_run_date}
cd $HOME/Scate_msat/${pathToResults}/Estimation_Results_${approx_run_date}
outDir=$PWD

echo "Results from this estimation will go to ${bold}${outDir}${normal}"
echo ""

# Edit the estimation input file to contain information from your command line inputs
echo "... updating ABC estimation file with run parameters"
echo ""
cp $HOME/Scate_msat/$pathToResults\Concatenated_mcmc_output.txt .
cp $HOME/Scate_msat/template_estimator.input ${model}_estimator.input
sed "s/dummy_model/$model/g" -i ${model}_estimator.input
sed "s/dummy_pop/$population/g" -i ${model}_estimator.input
sed "s/dummy_retain/$retainedSims/g" -i ${model}_estimator.input
sed "s/dummy_max_read/$maxSimsToConsider/g" -i ${model}_estimator.input
sed "s/dummy_param/$parameters/g" -i ${model}_estimator.input
sed "s/dummy_tolerance/$tolerance/g" -i ${model}_estimator.input

#copy files to run directory
cp $HOME/Scate_msat/obs/Scate_17micro_${population}.obs .
cp $HOME/Scate_msat/binaries/transformer .
chmod +x transformer
echo "Transforming the observed summary stats using the PLS.txt transformation file"
./transformer PLS.txt Scate_17micro_${population}.obs Scate_17micro_${population}_new.obs boxcox
rm transformer
cp $HOME/Scate_msat/binaries/ABCestimator .

chmod +x ABCestimator

./ABCestimator ${model}_estimator.input
rm ABCestimator

cp $HOME/Scate_msat/binaries/plotPosteriorsGLM.r .
R --vanilla ${model}_estimator.input <plotPosteriorsGLM.r
