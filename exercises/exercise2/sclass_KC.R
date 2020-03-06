library(tidyverse)
library(FNN)
library(mosaic)
library(foreach)

sclass = read.csv("data/sclass.csv")

#Subset into 350 and 65 AMG trim
sclass350 <- subset(sclass, trim=="350")
sclass65 <- subset(sclass, trim=="65 AMG")
qplot(price, mileage, data=sclass350)
qplot(price, mileage, data=sclass65)

#split into training and testing sets using an 80/20 split
# train-test split for sclass 350
N_350 = nrow(sclass350)
N_350train = floor(0.8*N_350)
N_350test = N_350 - N_350train


train_350ind = sample.int(N_350, N_350train, replace=FALSE)

# Define the training and testing set
D_350train = sclass350[train_350ind,]
D_350test = sclass350[-train_350ind,]

D_350test = arrange(D_350test, mileage)
head(D_350test)

# Now separate the training and testing sets into features (X) and outcome (y)
x_350train = data.frame(mileage=D_350train$mileage)
y_350train = D_350train$price
x_350test = data.frame(mileage=D_350test$mileage)
y_350test = D_350test$price


#####
# Fit a few models
#####

# linear and quadratic models
lm1 = lm(price ~ mileage, data=D_350train)
lm2 = lm(price ~ poly(mileage, 2), data=D_350train)

# KNN 250
knn250 = knn.reg(train = X_350train, test = X_350test, y = y_350train, k=250)

# define RMSE function
rmse = function(actual, predicted) {
  sqrt(mean((actual - predicted) ^ 2))
}


# find best K
x=dplyr::select(sclass350, mileage)
y=sclass350$price
n350=length(y)

n350_train=round(0.8*n350)
n350_test=n350-n350_train
k_grid = seq(1, 100, by=1)
rmse_grid = foreach(k = k_grid,  .combine='c') %do% {
  out = do(500)*{
    train_ind = sample.int(n350, n350_train)
    X_train = x[train_ind,]
    X_test = x[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    
    knn_mod350 = FNN::knn.reg(as.data.frame(X_train), as.data.frame(X_test), y_train, k=k)
    
    rmse(y_test, knn_mod350$pred)
  } 
  mean(out$result)
}


plot(k_grid, rmse_grid)
which.min(rmse_grid)




