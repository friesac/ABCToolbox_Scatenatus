#!/bin/bash

# Specify the resources needed
#PBS -A PAS0656
#PBS -l walltime=00:05:00
#PBS -l nodes=1:ppn=1
#PBS -N ABC_KLDR_Model1_2016-03-04-15-53
#PBS -l mem=4gb
#PBS -m a

set -x
cp /nfs/12/osu0378/Scate_msat/obs/Scate_17micro_KLDR.obs $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/arl_run.ars $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/arl_run.txt $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/single_pop/ssdefs.txt $TMPDIR
cp /nfs/12/osu0378/Scate_msat/arl/arlsumstat $TMPDIR
cp /nfs/12/osu0378/Scate_msat/binaries/simcoal2 $TMPDIR
cp /nfs/12/osu0378/Scate_msat/binaries/ABCsampler $TMPDIR
mv /nfs/12/osu0378/Scate_msat/population_results/KLDR_Model1_2016-03-04-15-53/Model1_calibration.input $TMPDIR
mv /nfs/12/osu0378/Scate_msat/population_results/KLDR_Model1_2016-03-04-15-53/Model1.par $TMPDIR
mv /nfs/12/osu0378/Scate_msat/population_results/KLDR_Model1_2016-03-04-15-53/Model1.est $TMPDIR 
cd $TMPDIR
chmod +x ABCsampler simcoal2 arlsumstat

echo "./ABCsampler Model1_calibration.input"
./ABCsampler Model1_calibration.input
rm simcoal2
rm arl_run.ars
rm arl_run.txt
rm ssdefs.txt
rm ABCsampler
rm arlsumstat
cp -R * /nfs/12/osu0378/Scate_msat/population_results/KLDR_Model1_2016-03-04-15-53
cd /nfs/12/osu0378/Scate_msat/population_results/KLDR_Model1_2016-03-04-15-53
