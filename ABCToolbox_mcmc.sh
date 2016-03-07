#!/bin/bash
# specify resources needed
#PBS -l walltime=00:60:00
#PBS -l nodes=1:ppn=1,mem=4GB
#PBS -N KLDR_mcmc
#PBS -m bae

# could have an argument asking about what is the population you want to know about. 
# could have an argument about which model you want to test.

set -x
cd Scate_msat/msat_KLDR
#create a unique folder and store folders
mkdir KLDR_mcmc_$PBS_ARRAYID 2>/dev/null
currDir=$PWD
#copy files
cp Model1_mcmc.input Model1.par Model1.est Scate_17micr_KLDR.obs $TMPDIR
cp ABCsampler simcoal2 arlsumstat arl_run.ars arl_run.txt ssdefs.txt Model1_output_sampling1.txt Routput_Model1_output_sampling1.txt $TMPDIR
#go on the node and launch ABCsampler1.0
cd $TMPDIR
chmod +x ABCsampler simcoal2 arlsumstat
./ABCsampler Model1_mcmc.input addToSeed=$PBS_ARRAYID
#copy results back
cp *output*.txt *.log $currDir/KLDR_mcmc_$PBS_ARRAYID
