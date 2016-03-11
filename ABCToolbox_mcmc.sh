#!/bin/bash

# ABC shell script to control the submission of a job array for mcmc without likelihood analysis.

# Call it this way: ./ABCToolbox_mcmc.sh [path to results directory] [population] [model] [sample size] [# of simulations to run] [tolerance] [walltime - format HH:MM:SS]

#------ Specify the parameters of the run in the command line submission -----
pathToResults=$1
population=$2
model=$3
sampleSize=$4
simulations=$5
tolerance=$6
walltime=$7

#------ Specify the parameters for the OSC -----
nodes=1
ppn=1
memory=4gb # For ABCToolbox you probably don't need more than 4mb
approx_run_date=$(date +%F-%k-%M) # Capture the date and time variables for naming directories.
typeOfArlequinFileToUse="single_pop" # [single_pop/pairwise_pop] to specify how the calculations are processed.
messageCode="a" #"b"egin,"e"nd,"a"borted,"s"uspended,"n"one - example ="bae"
jobarrays=1 # How many iterations of that exact run do you want... i.e. this is relevant to the mcmc search/indicates multiple starting chains.

#------ Just some formatting for the script -----
bold=$(tput bold)
normal=$(tput sgr0)

# Go to the main results directory
cd $pathToResults

echo ""
echo "##################################################################################################################"
echo "##################################################################################################################"
echo "##################################################################################################################"
echo ""
echo "Current Directory: ${bold}$PWD${normal}"
currDir=$PWD
echo ""
echo "Details of Run"
echo "-----------------"
echo "Model = ${model}"
echo "Population = ${population}"
echo "Independent Chains = ${jobarrays}"
echo "Simulations = ${simulations}"
echo "2N individuals = ${sampleSize}"
echo ""
mkdir $currDir/${population}_${model}_MCMC 2>/dev/null
cd $currDir/${population}_${model}_MCMC
echo ""
echo "Results will be sent to ${bold}${PWD}${normal}"
echo ""
currDir=$PWD

# Edit the mcmc input file to contain information from your command line inputs
echo "... updating ABC mcmc_input file with run parameters"
echo ""
cp $HOME/Scate_msat/template_mcmc.input ${model}_mcmc.input # Copy and rename the template mcmc input file.
sed "s/dummy_model/$model/g" -i ${model}_mcmc.input
sed "s/dummy_pop/$population/g" -i ${model}_mcmc.input
sed "s/dummy_sims/$simulations/g" -i ${model}_mcmc.input
sed "s/dummy_tolerance/$tolerance/g" -i ${model}_mcmc.input

echo "... updating the par file with correct sample size"
echo ""
cp $HOME/Scate_msat/models/est/${model}.est .
cp $HOME/Scate_msat/models/par/${model}.par .
sed "s/dummy_pop_size/$sampleSize/g" -i ${model}.par

jobName=${population}_${model}_mcmc.sh

echo "... making the bash file on the fly"
echo ""
(
echo "#!/bin/bash" 
echo ""
echo "# Specify the resources needed"
echo "#PBS -A PAS0656"
echo "#PBS -l walltime=${walltime}"
echo "#PBS -l nodes=${nodes}:ppn=${ppn}"
echo "#PBS -N ABC_${population}_${model}_${approx_run_date}"
echo "#PBS -l mem=${memory}"
echo "#PBS -m ${messageCode}"
echo ""
echo "set -x"

echo "mkdir ${model}_mcmc_${PBS_ARRAYID} 2>/dev/null"

echo "cp $HOME/Scate_msat/obs/Scate_17micro_${population}.obs \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.ars \$TMPDIR" 
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.txt \$TMPDIR" 
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/ssdefs.txt \$TMPDIR" 
echo "cp $HOME/Scate_msat/arl/arlsumstat \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/simcoal2 \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/ABCsampler \$TMPDIR"
echo "cp ${model}_mcmc.input \$TMPDIR"
echo "cp ${model}.par \$TMPDIR"
echo "cp ${model}.est \$TMPDIR"
echo "cp ../${population}_output_sampling1.txt \$TMPDIR"
echo "cp ../Routput_${model}_output_sampling1.txt \$TMPDIR"
echo "cp ${model}.par \$TMPDIR"

echo "cd $TMPDIR"

echo "chmod +x ABCsampler simcoal2 arlsumstat"
echo "echo Running: ./ABCsampler ${model}_mcmc.input addToSeed=$PBS_ARRAYID"
echo "./ABCsampler ${model}_mcmc.input addToSeed=${PBS_ARRAYID}"
echo ""
echo "cp -R * $currDir/${model}_mcmc_${PBS_ARRAYID}"

echo "cd $HOME/Scate_msat/${pathToResults/${model}_mcmc_${PBS_ARRAYID}"
echo "rm simcoal2"
echo "rm ABCsampler"
echo "rm arlsumstat"
echo "rm arl_run.ars"
echo "rm arl_run.txt"
echo "rm ssdefs.txt"
)> ${jobName}
chmod +x ${jobName}
echo ""
echo "Bash file ${bold}${jobName}${normal} created"
echo ""
echo ""
# qsub ./$jobName
