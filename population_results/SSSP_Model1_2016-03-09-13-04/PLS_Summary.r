#open File
numComp<-9;	# Has to be less than the number of stats
directory<-"";
filename<-"SSSP_output_sampling1.txt";	# Main simulation output from calibration run.

#read that file
a<-read.table(paste(directory, filename, sep=""), header=T, nrows=50000, skip=0);	# Make sure to pay attention to how many simulations are in your calibration run... if greater than 50000 than you need to change this number.

########### Checking your file and printing things so you can make sure you are grabbing the right things ################
print("------------- These are the names of your variables in the calibration simulation file -----------------")
print(names(a)); # Just a check to make sure you read the file correctly.

paramnames<-names(a[3]);	
print("Your parameters are:")
for (i in 1:length(paramnames)){
	print(paramnames[i]);
}

statsnames<-names(a[6:14]);
print("Your summary statistics are:")
for (i in 1:length(statsnames)){
	print(statsnames[i]);
}

stats<-as.data.frame(a[,6:14]); 
params<-as.data.frame(a[,3]); 
rm(a);

#standardize the params basic 
stdparams<-params
print("------- Standardizing the PARAMETERS ----------------")
for(i in 1:length(params)){
	stdparams[,i]<-(params[,i]-mean(params[,i]))/sd(params[,i]);
}

#force stats in [1,2]
rangestats<-stats
myMax<-c(); 
myMin<-c(); 
lambda<-c(); 
myGM<-c();
for(i in 1:length(stats)){
	myMax<-c(myMax, max(stats[,i]));
	myMin<-c(myMin, min(stats[,i]));
	rangestats[,i]<-1+(stats[,i]-myMin[i])/(myMax[i]-myMin[i]);
}

#transform statistics via boxcox  
library("MASS");	
for(i in 1:length(rangestats)){		
	d<-cbind(rangestats[,i], stdparams); # Join a stat with all parameters
	mylm<-lm(as.formula(d), data=d) # Your essentially doing lm(stat~param1+param2+param...)		
	myboxcox<-boxcox(mylm, lambda=seq(-50, 80, 1/10), plotit=T, interp=T, eps=1/50);	
	lambda<-c(lambda, myboxcox$x[myboxcox$y==max(myboxcox$y)]);			
	print(paste(names(rangestats)[i], myboxcox$x[myboxcox$y==max(myboxcox$y)]));
	myGM<-c(myGM, exp(mean(log(rangestats[,i]))));			
}

#standardize the BC-stats
BCstats<-rangestats;
myBCMeans<-c(); myBCSDs<-c();
for(i in 1:length(rangestats)){
	BCstats[,i]<-(rangestats[,i]^lambda[i] - 1)/(lambda[i]*myGM[i]^(lambda[i]-1));	
	myBCSDs<-c(myBCSDs, sd(BCstats[,i]));
	myBCMeans<-c(myBCMeans, mean(BCstats[,i]));		
	BCstats[,i]<-(BCstats[,i]-myBCMeans[i])/myBCSDs[i];
}

#perform pls
library("pls");
#myPlsr<-plsr(as.matrix(params) ~ as.matrix(stats), scale=F, ncomp=numComp, validation="LOO");
myPlsr<-plsr(as.matrix(stdparams) ~ as.matrix(BCstats), scale=F, ncomp=numComp);

#write pls to a file
myPlsrDataFrame<-data.frame(comp1=myPlsr$loadings[,1]);
for(i in 2:numComp) { myPlsrDataFrame<-cbind(myPlsrDataFrame, myPlsr$loadings[,i]); } 
write.table(cbind(names(BCstats), myMax, myMin, lambda, myGM, myBCMeans, myBCSDs, myPlsrDataFrame), file=paste(directory, "Routput_", filename, sep=""), col.names=F, row.names=F, sep="\t", quote=F);

#make RMSE plot
pdf(paste(directory, "RMSE_", filename, ".pdf", sep=""));
plot(RMSEP(myPlsr));
dev.off();









# Print the distribution of the stats and parameters
print("------- Writing calibration summary pdf -------------")

pdf("calibration_summary.pdf")
par(mfrow=c(3,3))
for (i in 1:length(params)){
	hist(params[,i], xlab=paramnames[i], main="PARAMETER");
}
for (i in 1:length(stdparams)){
	hist(stdparams[,i], xlab=paramnames[i], main="STD_PARAMETER");
	}	
for (i in 1:length(stats)){
	hist(stats[,i], xlab=statsnames[i], main="STATISTIC");
}
for (i in 1:length(BCstats)){
	hist(BCstats[,i], xlab=statsnames[i], main="BC_STATISTIC");
}
dev.off()



