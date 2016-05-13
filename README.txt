README FOR ABC ANALYSIS - developed for the microsatellite data for Sistrurus 

The directory structure for the ABC analysis

	Scate_msat
		|
		|
		Observed File
		Binaries
		Arlequin Analyses
			|
			Single population
			Pairwise population

		Demographic Models
			|
			Par files
			Est file

		population_results
			|
			Population_Model_Date - Calibration Results file
					|
					Population_Model_MCMC - MCMC Results file from the above calibration run
							|
							Estimation_Results_Date - from the GLM on the above MCMC run
							Model_RunX - Each of the independent chains from the MCMC sampling step
		estimation_outputs
			|
			Population_Model_Date
					|
					Duplicate final results file




1. Perform n simulations with parameters randomly drawn from their priors, and each time compute their associated set of summary statistics (ss).

	- You're running a standard ABCsampler run that is setup in "template_calibration.input". - make any specific changes to things like standardizing in this.
	- No distance is calculated here because the exploration of state space is not influenced by distance in a "standard" run. 
	

	HOW TO CALL:
	./ABCToolbox_calib.sh [population] [model] [sample size] [# of simulations to run] [walltime - format:HH:MM:SS]
	

	* This will create the bash script based on parameters in the ABCToolbox_calibration.sh that will then be sent to qsub on the OSC.
	!!!  Make sure that sample size is the number of alleles! Not individuals.
	

2. Compute the PLS components from the calibration simulations


	HOW TO CALL:
	./Prep_for_mcmc.sh [PATH_TO_RESULTS] [population] [model] [components] [parameters (e.g. 3:6)] [stats (e.g. 5:18)]

	
	You're going to replace the PLS script from ABCToolbox with the values of interest for PLS analysis.

	
3. Perform n simulations in i independent chains using an mcmc likelihood/distance based MCMC walk.

	
	HOW TO CALL
	./ABCToolbox_mcmc.sh [PATH_TO_RESULTS] [population] [model] [sample size] [sims/chain] [tolerance] [walltime - format HH:MM:SS]


4. Concatenate the results from the independent mcmc chains

	
	HOW TO CALL
	
	A. Go into the directory above the independent MCMC run folders
	B. Run ~/Scate_msat/MCMC_compiler.sh --------


5. Run the ABC Estimator to calculate the ABC_GLM standard estimation from Wegmann
	
	
	HOW TO CALL
	./ABCToolbox_estimation.sh [population] [model] [parameters columns "1,3,5-7,9"] [# to retain for estimation] [# to import] [PATH_TO_RESULTS] 
