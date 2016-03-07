#arguments: if the last argument is an existing filename, use it. Else try to find abc_glm.input
filename<-commandArgs()[length(commandArgs())];
if(!file.exists(filename)){ filename<-"abc_glm.input"; }
if(!file.exists(filename)){
	print("ABCestimator1.0 inputfile not found!");
} else {
	directory<-"";		
	if(length(grep("/", filename))>1){
		temp<-strsplit(filename, "/");
		temp<-temp[[1]];
		filename<-temp[length(temp)];
		directory<-paste(temp[1:(length(temp)-1)], sep="/");				
		directory<-paste(directory, "/", sep="");
	}
			
	#read input file	
	settings<-scan(paste(directory, filename, sep=""), what=list("character", "character"), flush=T, quiet=T);
	settingNames<-settings[[1]];
	settings<-settings[[2]];	
	
	#read observed file
	filename<-paste(directory, settings[settingNames=="obsName"], sep="");
	if(!file.exists(filename)){ print(paste("File with observed statistics '", filename, "' not found!", sep=""));
	} else {
		obs<-read.table(filename, header=T);
		#read true file
		trueParamsRead=F;
		if(sum(settingNames=="trueParamName")==1){
			filename<-paste(directory, settings[settingNames=="trueParamName"], sep="");
			if(file.exists(filename)){
				trueParams<-read.table(filename, header=T);
				trueParamsRead<-T;
			}
		}
		#read sim data to get prior distributions. Just read the first 20000 values
		filename<-paste(directory, settings[settingNames=="simName"], sep="");
		if(!file.exists(filename)){
			print(paste("File with simulations '", filename, "' not found!", sep=""));
		} else {
			sims<-read.table(filename, header=T, nrows=20000);
			#read parameter columns that were estimated
			p<-settings[settingNames=="params"];
			p<-strsplit(p,",")[[1]];			
			params<-c();
			for(i in 1:length(p)){
				if(length(grep("-", p[i]))>0){					
					temp<-strsplit(p[i], "-")[[1]];
					params<-c(params, as.numeric(temp[1]):as.numeric(temp[2]));
				} else {
					params<-c(params, as.numeric(p[i]));		
				}
			}
			params<-sort(params);			
			
			#get output prefix			
			if(sum(settingNames=="outputPrefix")==1){
				outputPrefix<-settings[settingNames=="outputPrefix"];
			} else {
				outputPrefix<-"ABC_GLM_";
			}
			
			#go through all obs data sets and produce pdf	
			for(i in 1:length(obs[,1])){		
				#open posterior file
				filename<-paste(directory, outputPrefix, "PosteriorEstimates_Obs", (i-1), ".txt", sep="");
				if(!file.exists(filename)){ print(paste("File with osterior estimates '", filename, "' not found!", sep=""));
				} else {
					post<-read.table(filename, header=T);
					pdf(paste(directory, "ABC_GLM_PosteriorPlots_Obs", (i-1), ".pdf", sep=""), width=12, height=9);
					par(mfrow=c(3,4));
					for(j in 1:length(params)){
						p<-density(sims[,params[j]]);
						xmax<-max(p$x);
						xmin<-min(p$x); 
						ymax<-max(p$y);					
						ymax<-max(max(p$y), max(post[,2*j+1]))*1.1;
						plot(post[,2*j], post[,2*j+1], main=names(sims)[params[j]], xlab=paste(names(sims)[params[j]], ", mode at ", post[post[,2*j+1]==max(post[,2*j+1]),2*j]), ylab="Density", type='l', col="red", xlim=c(xmin, xmax), ylim=c(0,ymax));
						lines(p, col="black");
						#plot retained if possible
						filename<-paste(directory, outputPrefix, "BestSimsParamStats_Obs", (i-1), ".txt", sep="");
						if(file.exists(filename)){ 
							ret<-read.table(filename, header=T);
							print(ret[1:2,]);
							lines(density(ret[,j+2]), col="blue");
						}
						#plot true value
						if(trueParamsRead){
							abline(v=trueParams[i, params[j]], col="black");
						}
					}
					dev.off();	
				}
			}
		}
	}
		

	
	
}
