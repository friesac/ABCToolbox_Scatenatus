#!/bin/bash

# ABC shell script to control submission of all calibration analyses
# The script will launch either a calibration 

# Call it this way: ./ABCToolbox_calib.sh [population] [model] [sample size] [# of simulations to run] [walltime - format:HH:MM:SS]

#------ Specify the parameters of the run -----
population=$1
model=$2
sampleSize=$3
simulations=$4
approx_run_date=$(date +%F-%s) # Date variable for naming directories.
typeOfArlequinFileToUse="single_pop" # [single_pop/pairwise_pop]

#------ Specify the parameters for the OSC -----
nodes=1
ppn=1
walltime=$5
memory=4gb # For ABCToolbox you probably don't need more than 4mb
messageCode="a" #"b"egin,"e"nd,"a"borted,"s"uspended,"n"one - example ="bae"
jobarrays=1 # How many iterations of that exact run do you want... i.e. this is relevant to the mcmc search/indicates multiple starting chains.

#------ Just some formatting for the script -----
bold=$(tput bold)
normal=$(tput sgr0)

echo ""
echo ""
echo "Current Directory: ${bold}$PWD${normal}"
echo ""
echo "Shell and OSC variables loaded -- check"
echo ""
echo "Using the ${bold}${population}${normal} population in ${bold}${model}${normal}: Running ${bold}${simulations}${normal} and sampling ${bold}${sampleSize}${normal} individuals"
echo ""

# Create a unique folder to store results then go into it and start making the files for the run.
mkdir $HOME/Scate_msat/population_results/${population}_${model}_${approx_run_date} 2>/dev/null
cd $HOME/Scate_msat/population_results/${population}_${model}_${approx_run_date} 
outDir=$PWD

echo "Results from this run will go to ${bold}${outDir}${normal}"
echo ""

# Edit the calibration input file to contain information from your command line inputs
echo "... updating ABC input file with run parameters"
echo ""
cp $HOME/Scate_msat/template_calibration.input ${model}_calibration.input
sed "s/dummy_model/$model/g" -i ${model}_calibration.input
sed "s/dummy_pop/$population/g" -i ${model}_calibration.input
sed "s/dummy_sims/$simulations/g" -i ${model}_calibration.input

# Replace the sample size for the population in the par file.
echo "... updating the par file with correct sample size"
echo ""
cp $HOME/Scate_msat/models/est/${model}.est .
cp $HOME/Scate_msat/models/par/${model}.par .
sed "s/dummy_pop_size/$sampleSize/g" -i ${model}.par

jobName=${population}_${model}.sh

# Creating the bash file on the fly.
echo "... making the bash file"
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
#copy files to Temporary directory
echo "cp $HOME/Scate_msat/obs/Scate_17micro_${population}.obs \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.ars \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.txt \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/ssdefs.txt \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/arlsumstat \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/simcoal2 \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/ABCsampler \$TMPDIR"
echo "mv $outDir/${model}_calibration.input \$TMPDIR"
echo "mv $outDir/${model}.par \$TMPDIR"
echo "mv $outDir/${model}.est \$TMPDIR " 
# Go on the node and launch ABCsampler1.0 if you are on OSC
echo "cd \$TMPDIR"
echo "chmod +x ABCsampler simcoal2 arlsumstat"
echo ""
echo "echo \"./ABCsampler ${model}_calibration.input\""
echo "./ABCsampler ${model}_calibration.input"
echo "rm simcoal2"
echo "rm arl_run.ars"
echo "rm arl_run.txt"
echo "rm ssdefs.txt"
echo "rm ABCsampler"
echo "rm arlsumstat"
# Copy results back
echo "cp -R * $HOME/Scate_msat/population_results/${population}_${model}_${approx_run_date}"
echo "cd $HOME/Scate_msat/population_results/${population}_${model}_${approx_run_date}"
) > ${jobName}

chmod +x ${jobName}
echo ""
echo "Bash file ${bold}${jobName}${normal} created"
echo ""
echo ""
qsub ./$jobName






