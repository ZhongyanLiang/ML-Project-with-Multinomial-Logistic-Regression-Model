---
title: "ML Final Project"
author: "Zhongyan Liang"
date: "3/30/2019"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(MASS)
library(nnet)
library(leaps)
library(HH)
library(glmnet)
library(pls)
library(class)
library(e1071)
library(randomForest)
```

```{r}
wine<-read.csv2("white_wine.csv",header = F, skip = 1)
colnames(wine)<-c("fixed","volatile","citric","sugar","chlor","fsd","tsd","density","pH","sulphates","alcohol","quality")
# fit logistic regression model because quality is a categorical response variabel.
attach(wine)
# data cleaning, change variable type to numeric.
glimpse(wine)
for(i in 1:(ncol(wine)-1)){
  wine[,i] <- as.numeric(wine[,i])
}
  
#ordinal multinomial model
unique(wine$quality)

library(nnet)
# 3-9 as different level of quality.
wine$Ordered_quality <- ordered(wine$quality, c("3","4","5","6","7","8","9"))
wine.polr<-polr(Ordered_quality~.-quality,data=wine,Hess=T)
summary(wine.polr)

library(MASS)
# stepwise
null=polr(Ordered_quality~1,data=wine,Hess=T)
step(null,scope = list(lower=null,upper=wine.polr),direction = "both")
# model:Ordered_quality ~ density + volatile + chlor + sugar + sulphates + tsd + pH + citric + fsd
new_w=polr(Ordered_quality ~ density + volatile + chlor + 
    sugar + sulphates + tsd + pH + citric + fsd, data = wine, 
    Hess = T) # removed two variables, fixed,alcohol

#VIF(Variance Inflation Factor)
library(car)
#vif(new_w)
# tsd, ph has VIF higher than 10.
#Corelation between the rest predictors
GGally::ggcorr(wine[,-c(1,11,12,13)], label = TRUE)

#Cross-validation
set.seed(1)
n=length(quality)
Z=sample(n,n/2)
Data_training=wine[Z,]
Data_testing=wine[-Z,]

#Ordinal logistic regression
Predicted_probability=predict(new_w, type="class", newdata = Data_testing)
mean(Data_testing$quality==Predicted_probability) # classification rate:0.4953042

#LDA
lda.fit=lda(quality ~ density + volatile + chlor + 
    sugar + sulphates + tsd + pH + citric + fsd, data = Data_training)
Yhat_lda=predict(lda.fit,data.frame(Data_testing))$class
mean(Data_testing$quality==Yhat_lda) # classification rate:0.5014292

#QDA
#Because rating 3 and 9 have too few observations, so we group 3 to 4 adn 9 to 8.
# 3 -> 4
# 9 -> 8
Data_training_mod <- Data_training
Data_training_mod[Data_training_mod$quality == 3,12] <- 4
Data_training_mod[Data_training_mod$quality == 9,12] <- 8
qda.fit=qda(quality ~ density + volatile + chlor + 
    sugar + sulphates + tsd + pH + citric + fsd, data = Data_training_mod)
Yhat_qda=predict(qda.fit,data.frame(Data_testing))$class
mean(Data_testing$quality==Yhat_qda) #classification rate:0.483871



#KNN
library(class)
Data_training=wine[Z,]
Data_testing=wine[-Z,]
X.train=Data_training[,c(1:11)]
X.test=Data_testing[,c(1:11)]
Y.train=Data_training$quality
Y.test=Data_testing$quality
 knn.rate = rep(0,50)
 for (k in 1:50){
knn.fit = knn( X.train, X.test, Y.train, k )
knn.rate[k] = mean( Y.test == knn.fit )
 }
 which.max(knn.rate) #K=1
knn.rate[1] # classification rate =0.5827


#random forest
library(MASS)
rf=randomForest(quality~.-Ordered_quality,data=wine)
rf
varImpPlot(rf)
rf_training=randomForest(factor(quality)~.-Ordered_quality,data=Data_training)
Yhat = predict(rf_training, newdata=Data_testing, type =  'class')
mean(Data_testing$quality==Yhat) # classification rate= 0.66067

# We can optimize both m and number of trees, by cross-validation.
cv.err = rep(0,9)
n.trees = rep(0,9)
for (m in 1:9) {
  rf.m = randomForest( quality~.-Ordered_quality, data=Data_training, mtry=m )
  opt.trees = which.min(rf.m$mse)
  rf.m = randomForest( quality~.-Ordered_quality, data=Data_training, mtry=m, ntree=opt.trees )
  Yhat = predict( rf.m, newdata=Data_testing )
  mse = mean( (Yhat - quality[-Z])^2 )
  cv.err[m] = mse
  n.trees[m] = opt.trees
}
which.min(cv.err) # bagging (m=p=3) was the best choice among random forests.
plot(cv.err); lines(cv.err)
n.trees
rf.optimal = randomForest( quality~.-Ordered_quality, data=wine, mtry=3, ntree=484 )
#optimal random forest with m=3 and number of trees=484， which did not reduce bagging in our case.
rf.optimal
par(mfrow=c(1,2))
varImpPlot(rf.optimal)
varImpPlot(rf)
```


