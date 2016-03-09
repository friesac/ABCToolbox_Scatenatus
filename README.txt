README FOR ABC ANALYSIS - developed for the microsatellite data for Sistrurus STEPS:
1. Perform n simulations with parameters randomly drawn from their priors, and each time compute their associated set of summary statistics S.

	- You're running a standard ABCsampler run that is setup in "template_calibration.input". 
	- No distance is calculated here because the exploration of state space is not influenced by distance in a "standard" run. 
	
	HOW TO CALL:
	./ABCToolbox_calib.sh [population] [model] [sample size] [# of simulations to run] [walltime - format:HH:MM:SS]
	
	* This will create the bash script based on parameters in the ABCToolbox_calibration.sh that will then be sent to qsub on the OSC.
	* Make sure that sample size is the number of alleles! Not individuals.
	
2. Compute the PLS components from the calibration simulations
	HOW TO CALL:
	./Prep_for_mcmc.sh [PATH_TO_RESULTS] [population] [model] [components] [parameters (e.g. 3:6)] [stats (e.g. 5:18)]
	
	You're going to replace the PLS script from ABCToolbox with the values of interest for PLS analysis.
	
	- 
