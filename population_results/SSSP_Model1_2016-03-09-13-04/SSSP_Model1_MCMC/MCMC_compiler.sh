head -n1 /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc_1/*mcmc_output* > Concatenated_mcmc_output.txt
for fol in /nfs/12/osu0378/Scate_msat/population_results/SSSP_Model1_2016-03-09-13-04/SSSP_Model1_MCMC/Model1_mcmc_*
do tail -n+2 ${fol}/*mcmc_output* >> Concatenated_mcmc_output.txt
done
