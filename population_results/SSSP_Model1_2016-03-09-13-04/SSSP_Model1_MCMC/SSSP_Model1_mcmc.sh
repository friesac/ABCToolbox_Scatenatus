#!/bin/bash

# Specify the resources needed
#PBS -A PAS0656
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -N ABC_SSSP_Model1_2016-03-11-15-41
#PBS -l mem=4gb
#PBS -m a

set -x
mkdir /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc_$PBS_ARRAYID 2>/dev/null
cp /nfs/12/osu0378/Scate_msat/obs/Scate_17micro_SSSP.obs $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/arl_run.ars $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/arl_run.txt $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/ssdefs.txt $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/arlsumstat $TMPDIR
cp /nfs/12/osu0378/Scate_msat/binaries/simcoal2 $TMPDIR
cp /nfs/12/osu0378/Scate_msat/binaries/ABCsampler $TMPDIR
cp /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc.input $TMPDIR
cp /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1.par $TMPDIR
cp /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1.est $TMPDIR
cp /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_output_sampling1.txt $TMPDIR
cd $TMPDIR
chmod +x ABCsampler simcoal2 arlsumstat
./ABCsampler Model1_mcmc.input addToSeed=$PBS_ARRAYID

cp -R * /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc_$PBS_ARRAYID
cd /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc_$PBS_ARRAYID
rm simcoal2
rm ABCsampler
rm arlsumstat
rm arl_run.ars
rm arl_run.txt
rm ssdefs.txt
