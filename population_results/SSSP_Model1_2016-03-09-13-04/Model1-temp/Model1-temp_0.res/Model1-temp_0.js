
USETEXTLINKS = 1
STARTALLOPEN = 0
WRAPTEXT = 1
PRESERVESTATE = 0
HIGHLIGHT = 1
ICONPATH = 'file:////tmp/pbstmp.6140154/'    //change if the gif's folder is a subfolder, for example: 'images/'

foldersTree = gFld("<i>ARLEQUIN RESULTS (Model1-temp_0.arp)</i>", "")
insDoc(foldersTree, gLnk("R", "Arlequin log file", "Arlequin_log.txt"))
	aux1 = insFld(foldersTree, gFld("Run of 09/03/16 at 13:22:19", "Model1-temp_0.htm#09_03_16at13_22_19"))
	insDoc(aux1, gLnk("R", "Settings", "Model1-temp_0.htm#09_03_16at13_22_19_run_information"))
		aux2 = insFld(aux1, gFld("Samples", ""))
		insDoc(aux2, gLnk("R", "Sample 1", "Model1-temp_0.htm#09_03_16at13_22_19_group0"))
		aux2 = insFld(aux1, gFld("Within-samples summary", ""))
		insDoc(aux2, gLnk("R", "Basic indices", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_Basic"))
		insDoc(aux2, gLnk("R", "Heterozygosity", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_het"))
		insDoc(aux2, gLnk("R", "Theta(H)", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_thetaH"))
		insDoc(aux2, gLnk("R", "No. of alleles", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_numAll"))
		insDoc(aux2, gLnk("R", "Allelic range", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_allRange"))
		insDoc(aux2, gLnk("R", "Garza-Williamson index", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_GW"))
		insDoc(aux2, gLnk("R", "Garza-Williamson modified index", "Model1-temp_0.htm#09_03_16at13_22_19_comp_sum_GWN"))
		aux2 = insFld(aux1, gFld("Genetic structure (samp=pop)", "Model1-temp_0.htm#09_03_16at13_22_19_pop_gen_struct"))
		insDoc(aux2, gLnk("R", "AMOVA", "Model1-temp_0.htm#09_03_16at13_22_19_pop_amova"))
		insDoc(aux2, gLnk("R", "FIS per pop", "Model1-temp_0.htm#09_03_16at13_22_19_amova_POP_AMOVA_FIS"))