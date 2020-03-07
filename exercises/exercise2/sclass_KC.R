library(tidyverse)
library(FNN)
library(mosaic)
library(foreach)

sclass = read.csv("data/sclass.csv")

#Subset into 65 and 65 AMG trim
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
lm1_350 = lm(price ~ mileage, data=D_350train)
lm2_350 = lm(price ~ poly(mileage, 2), data=D_350train)

# KNN 250
knn250 = knn.reg(train = x_350train, test = x_350test, y = y_350train, k=250)

# define RMSE function
rmse = function(actual, predicted) {
  sqrt(mean((actual - predicted) ^ 2))
}


# find best K for the 350 subset
x350=dplyr::select(sclass350, mileage)
y350=sclass350$price
n350=length(y350)

n350_train=round(0.8*n350)
n350_test=n350-n350_train
k_grid = seq(1, 100, by=1)
rmse_grid_out350 = foreach(k = k_grid,  .combine='c') %do% {
  out350 = do(300)*{
    train_ind = sample.int(n350, n350_train)
    X_train350 = x350[train_ind,]
    X_test350 = x350[-train_ind,]
    y_train350 = y350[train_ind]
    y_test350 = y350[-train_ind]
    
    knn_mod350 = FNN::knn.reg(as.data.frame(X_train350), as.data.frame(X_test350), y_train350, k=k)
    
    rmse(y_test350, knn_mod350$pred)
  } 
  mean(out350$result)
}


plot(k_grid, rmse_grid_out350)
which.min(rmse_grid_out350)


#khou predicting coast --> mileage predicting price
y_pred350_1 = predict(lm1_350, D_350test)
lm1_350rmse = rmse(D_350test$price, y_pred350_1)
y_pred350_2 = predict(lm2_350, D_350test)
lm2_350rmse = rmse(D_350test$price, y_pred350_2)

rmse_grid_out350 = data.frame(K = k_grid, RMSE = rmse_grid_out350)

ind_best350 = which.min(rmse_grid_out350$RMSE)
k_best350 = k_grid[ind_best350]

g1 <- data.frame(k_best350, minrmse350=min(rmse_grid_out350$RMSE))
g1
p_out = ggplot(data=rmse_grid_out65) + 
  geom_path(aes(x=K, y=RMSE), color="violet", size=1.5) + 
  geom_hline(yintercept=lm2_350rmse, color='blue', size=1) +
  geom_hline(yintercept=lm1_350rmse, color='red', size=1) +
  geom_point(data=g1, aes(k_best350, y=minrmse350), color="black", size=3) +
  geom_text(data=g1, aes(x=k_best350, y=minrmse350, label=k_best350), vjust=0.5, hjust=-0.5, size=4)

p_out



### Do the same for the 65 Trim
#split into training and testing sets using an 80/20 split
#train-test split for sclass 65
N_65 = nrow(sclass65)
N_65train = floor(0.8*N_65)
N_65test = N_65 - N_65train


train_65ind = sample.int(N_65, N_65train, replace=FALSE)

# Define the training and testing set
D_65train = sclass65[train_65ind,]
D_65test = sclass65[-train_65ind,]

D_65test = arrange(D_65test, mileage)
head(D_65test)

# Now separate the training and testing sets into features (X) and outcome (y)
x_65train = data.frame(mileage=D_65train$mileage)
y_65train = D_65train$price
x_65test = data.frame(mileage=D_65test$mileage)
y_65test = D_65test$price


#####
# Fit a few models
#####

# linear and quadratic models
lm1_65 = lm(price ~ mileage, data=D_65train)
lm2_65 = lm(price ~ poly(mileage, 2), data=D_65train)

# define RMSE function
rmse = function(actual, predicted) {
  sqrt(mean((actual - predicted) ^ 2))
}


# find best K for the 65 subset
x65=dplyr::select(sclass65, mileage)
y65=sclass65$price
n65=length(y65)

n65_train=round(0.8*n65)
n65_test=n65-n65_train
k_grid = seq(1, 100, by=1)
rmse_grid_out65 = foreach(k = k_grid,  .combine='c') %do% {
  out65 = do(300)*{
    train_ind = sample.int(n65, n65_train)
    X_train65 = x65[train_ind,]
    X_test65 = x65[-train_ind,]
    y_train65 = y65[train_ind]
    y_test65 = y65[-train_ind]
    
    knn_mod65 = FNN::knn.reg(as.data.frame(X_train65), as.data.frame(X_test65), y_train65, k=k)
    
    rmse(y_test65, knn_mod65$pred)
  } 
  mean(out65$result)
}


plot(k_grid, rmse_grid_out65)
which.min(rmse_grid_out65)


#khou predicting coast --> mileage predicting price
y_pred65_1 = predict(lm1_65, D_65test)
lm1_65rmse = rmse(D_65test$price, y_pred65_1)
y_pred65_2 = predict(lm2_65, D_65test)
lm2_65rmse = rmse(D_65test$price, y_pred65_2)

rmse_grid_out65 = data.frame(K = k_grid, RMSE = rmse_grid_out65)

ind_best65 = which.min(rmse_grid_out65$RMSE)
k_best65 = k_grid[ind_best65]

g2 <- data.frame(k_best65, minrmse65=min(rmse_grid_out65$RMSE))
g2
g_out = ggplot(data=rmse_grid_out65) + 
  geom_path(aes(x=K, y=RMSE), color="violet", size=1.5) + 
  geom_hline(yintercept=lm2_65rmse, color='blue', size=1) +
  geom_hline(yintercept=lm1_65rmse, color='red', size=1) +
  geom_point(data=g2, aes(k_best65, y=minrmse65), color="black", size=3) +
  geom_text(data=g2, aes(x=k_best65, y=minrmse65, label=k_best65), vjust=0.5, hjust=-0.5, size=4)

g_out


### Why do the optimal Ks differ for each trim?
sub65vs350 = sclass[sclass$trim %in% c("65 AMG", "350"),]
favstats(~price, data=sclass65)
favstats(~price, data=sclass350)
ggplot(data=sub65vs350, aes(x=trim, y=price)) +
  geom_boxplot()

# It seems that the 65 trim has a much wider range, so KNN must be averaged over more points to avoid being 
# affected by outliers. The KNN model thus "smooths" over the more erratic 65 trim dataset. In contrast, the 350 trim,
# although its mean is being pulled downwards from low values, is more normally distributed than the 65 trim.

