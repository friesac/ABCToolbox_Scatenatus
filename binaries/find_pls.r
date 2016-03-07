#open File
numComp<-dummy_components;

directory<-"";
filename<-"dummy_model_output_sampling1.txt";


#read file
a<-read.table(paste(directory, filename, sep=""), header=T, nrows=10000, skip=0);
print(names(a));
stats<-a[,c(dummy_statS:dummy_statE)]; params<-a[,c(dummy_paramS:dummy_paramE)]; rm(a);
 
#standardize the params
for(i in 1:length(params)){params[,i]<-(params[,i]-mean(params[,i]))/sd(params[,i]);}

#force stats in [1,2]
myMax<-c(); myMin<-c(); lambda<-c(); myGM<-c();
for(i in 1:length(stats)){
	myMax<-c(myMax, max(stats[,i]));
	myMin<-c(myMin, min(stats[,i]));
	stats[,i]<-1+(stats[,i]-myMin[i])/(myMax[i]-myMin[i]);
}

#transform statistics via boxcox  
library("MASS");	
for(i in 1:length(stats)){		
	d<-cbind(stats[,i], params);
	mylm<-lm(as.formula(d), data=d)			
	myboxcox<-boxcox(mylm, lambda=seq(-50, 80, 1/10), plotit=T, interp=T, eps=1/50);	
	lambda<-c(lambda, myboxcox$x[myboxcox$y==max(myboxcox$y)]);			
	print(paste(names(stats)[i], myboxcox$x[myboxcox$y==max(myboxcox$y)]));
	myGM<-c(myGM, exp(mean(log(stats[,i]))));			
}

#standardize the BC-stats
myBCMeans<-c(); myBCSDs<-c();
for(i in 1:length(stats)){
	stats[,i]<-(stats[,i]^lambda[i] - 1)/(lambda[i]*myGM[i]^(lambda[i]-1));	
	myBCSDs<-c(myBCSDs, sd(stats[,i]));
	myBCMeans<-c(myBCMeans, mean(stats[,i]));		
	stats[,i]<-(stats[,i]-myBCMeans[i])/myBCSDs[i];
}

#perform pls
library("pls");
#myPlsr<-plsr(as.matrix(params) ~ as.matrix(stats), scale=F, ncomp=numComp, validation="LOO");
myPlsr<-plsr(as.matrix(params) ~ as.matrix(stats), scale=F, ncomp=numComp);

#write pls to a file
myPlsrDataFrame<-data.frame(comp1=myPlsr$loadings[,1]);
for(i in 2:numComp) { myPlsrDataFrame<-cbind(myPlsrDataFrame, myPlsr$loadings[,i]); } 
write.table(cbind(names(stats), myMax, myMin, lambda, myGM, myBCMeans, myBCSDs, myPlsrDataFrame), file=paste(directory, "Routput_", filename, sep=""), col.names=F, row.names=F, sep="\t", quote=F);

#make RMSE plot
pdf(paste(directory, "RMSE_", filename, ".pdf", sep=""));
plot(RMSEP(myPlsr));
dev.off();

