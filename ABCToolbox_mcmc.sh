#!/bin/bash

# ABC shell script to control the submission of a job array for mcmc without likelihood analysis.

# Call it this way: ./ABCToolbox_mcmc.sh [path to results directory] [population] [model] [sample size] [# of simulations to run] [tolerance] [walltime - format HH:MM:SS]

#------ Specify the parameters of the run in the command line submission -----
pathToResults=$1	# Path to results files from Calibration run.
population=$2		# The population that you're working on.
model=$3		# The demographic model being used.
sampleSize=$4		# The haploid size of the dataset.
simulations=$5		# The number of simulations that you'd like to try.
tolerance=$6		# The tolerance value you'd like to use for MCMC searching.
walltime=$7		# The walltime for a qsub submission.

#------ Specify the parameters for the OSC -----
nodes=1					# Total nodes that you'd use --- should not need more than 1 for simcoal.
ppn=1					# Total processors to use on that node.
memory=4gb 				# For ABCToolbox you probably don't need more than 4mb
approx_run_date=$(date +%F-%k-%M) 	# Capture the date and time variables for naming directories.
typeOfArlequinFileToUse="single_pop" 	# [single_pop/pairwise_pop] to specify how the calculations are processed.
messageCode="a" 			#"b"egin,"e"nd,"a"borted,"s"uspended,"n"one - example ="bae"
jobarrays=2 				# How many iterations of that exact run do you want... i.e. this is relevant to the mcmc search/indicates multiple starting chains.

#------ Just some formatting for the script output -----
bold=$(tput bold)
normal=$(tput sgr0)

# Go to the main results directory
cd $HOME/Scate_msat/$pathToResults	# This is the main calibration outout directory.

# Start printing to the screen - Youre checking some of the details.
echo ""
echo "##################################################################################################################"
echo "##################################################################################################################"
echo "##################################################################################################################"
echo ""
echo "Current Directory: ${bold}$PWD${normal}"
echo ""
echo "Details of Run"
echo "-----------------"
echo "Model = ${model}"
echo "Population = ${population}"
echo "Independent Chains = ${jobarrays}"
echo "Simulations = ${simulations}"
echo "2N individuals = ${sampleSize}"
echo "Calibration directory used = ${pathToResults}"
echo "-----------------"
echo ""

# Make a directory to hold all of the MCMC results.
mkdir $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC 2>/dev/null	# Youre creating a directory within the calibration directory to start placing output.
cd $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC			# change into that new directory.
echo ""
echo "Results will be sent to ${bold}${PWD}${normal}"	# This better be the file you just created.
echo ""

# Edit the ABCsampler mcmc input file to contain information from your command line inputs
echo "... updating ABC mcmc_input file with run parameters"
echo ""
cp $HOME/Scate_msat/template_mcmc.input ${model}_mcmc.input 	# Copy and rename the template mcmc input file into that just made directory
sed "s/dummy_model/$model/g" -i ${model}_mcmc.input		# Replace the model name in the input file.
sed "s/dummy_pop/$population/g" -i ${model}_mcmc.input		# Replace the population name in the input file.
sed "s/dummy_sims/$simulations/g" -i ${model}_mcmc.input	# Replace the # of simulations in the input file.
sed "s/dummy_tolerance/$tolerance/g" -i ${model}_mcmc.input	# Replace the tolerance limit in the input file.

# Edit the par file with the sample size.
echo "... updating the par file with correct sample size"
echo ""
cp $HOME/Scate_msat/models/est/${model}.est .			# Copy the .est file with the priors to the created directory.
cp $HOME/Scate_msat/models/par/${model}.par .			# Copy the .par file to the created directory.
sed "s/dummy_pop_size/$sampleSize/g" -i ${model}.par		# Replace the sample size in the .par file.

jobName=${population}_${model}_mcmc.sh		# This is going to hold the name of the shell script that is going to be created.

echo "... making the bash file on the fly"
echo ""
(
echo "#!/bin/bash"
echo ""
# Resources needed for the HPC
echo "# Specify the resources needed"
echo "#PBS -A PAS0656"
echo "#PBS -l walltime=${walltime}"
echo "#PBS -l nodes=${nodes}:ppn=${ppn}"
echo "#PBS -N ABC_${population}_${model}_${approx_run_date}"
echo "#PBS -l mem=${memory}"
echo "#PBS -m ${messageCode}"
echo ""
echo "set -x"
# Make sure the right files are in the newly created directory.
echo "mkdir $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc_PBS_ARRAYID 2>/dev/null"
echo "cp $HOME/Scate_msat/obs/Scate_17micro_${population}.obs \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.ars \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/arl_run.txt \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/${typeOfArlequinFileToUse}/ssdefs.txt \$TMPDIR"
echo "cp $HOME/Scate_msat/arl/arlsumstat \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/simcoal2 \$TMPDIR"
echo "cp $HOME/Scate_msat/binaries/ABCsampler \$TMPDIR"
echo "cp $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc.input \$TMPDIR"
echo "cp $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}.par \$TMPDIR"
echo "cp $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}.est \$TMPDIR"
echo "cp $HOME/Scate_msat/${pathToResults}${population}_output_sampling1.txt \$TMPDIR"
#echo "cp $HOME/Scate_msat/${pathToResults}Routput_${model}_output_sampling1.txt \$TMPDIR"
echo "cd \$TMPDIR"

echo "chmod +x ABCsampler simcoal2 arlsumstat"
echo "./ABCsampler ${model}_mcmc.input addToSeed=PBS_ARRAYID"	# You're adding to the seed so that the random start point is different between the jobs on the array.
echo ""
echo "cp -R * $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc_PBS_ARRAYID"
echo "cd $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc_PBS_ARRAYID"
echo "rm simcoal2"
echo "rm ABCsampler"
echo "rm arlsumstat"
echo "rm arl_run.ars"
echo "rm arl_run.txt"
echo "rm ssdefs.txt"
)> ${jobName}

sed "s/PBS_ARRAYID/\$PBS_ARRAYID/g" -i ${jobName}
chmod +x ${jobName}
echo ""
echo "Bash file ${bold}${jobName}${normal} created"
echo ""
echo ""

# Make a compiler script to concatenate the result files... Just go to the main script and run the .sh
echo "Defining the compiler"
echo ""
cd $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/
(
echo "head -n1 $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc_1/*mcmc_output* > Concatenated_mcmc_output.txt"
echo "for fol in $HOME/Scate_msat/${pathToResults}${population}_${model}_MCMC/${model}_mcmc_*"
echo "do tail -n+2 \${fol}/*mcmc_output* >> Concatenated_mcmc_output.txt"
echo "done"
)> MCMC_compiler.sh

qsub -t 1-${jobarrays} ${jobName}

