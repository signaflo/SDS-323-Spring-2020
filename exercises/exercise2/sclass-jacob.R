library(mosaic)
library(tidyverse)
library(FNN)

sclass = read.csv('./data/sclass.csv')

# The variables involved
summary(sclass)

# Focus on 2 trim levels: 350 and 65 AMG
sclass350 = subset(sclass, trim == '350')
dim(sclass350)

sclass65AMG = subset(sclass, trim == '65 AMG')
summary(sclass65AMG)

# Look at price vs mileage for each trim level
plot(price ~ mileage, data = sclass350)
plot(price ~ mileage, data = sclass65AMG)

# train-test split for sclass 350
N_350 = nrow(sclass350)
N_350train = floor(0.8*N_350)
N_350test = N_350 - N_350train

# randomly sample a set of data points to include in the training set
train_350ind = sample.int(N_350, N_350train, replace=FALSE)

# Define the training and testing set
D_350train = sclass350[train_350ind,]
D_350test = sclass350[-train_350ind,]

# filter out NA's
D_350train = D_350train %>% filter(!is.na(mileage)) %>% filter(!is.na(price))
D_350test = D_350test %>% filter(!is.na(mileage)) %>% filter(!is.na(price))

# optional book-keeping step:
# reorder the rows of the testing set by the mileage variable
# this isn't necessary, but it will allow us to make a pretty plot later
D_350test = arrange(D_350test, mileage)
head(D_350test)

# Now separate the training and testing sets into features (X) and outcome (y)
X_350train = select(D_350train, mileage)
y_350train = select(D_350train, price)
X_350test = select(D_350test, mileage)
y_350test = select(D_350test, price)


#####
# Fit a few models
#####

# linear and quadratic models

lm1 = lm(price ~ mileage, data=D_350train)
lm2 = lm(price ~ poly(mileage, 2), data=D_350train)

# KNN
knn = knn.reg(train = X_350train, test = X_350test, y = y_350train, k = 5)
names(knn)

ypred_knn = knn$pred
D_350test$ypred_knn = ypred_knn

p_test = ggplot(data = D_350test) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18)
p_test

p_test + geom_point(aes(x = mileage, y = ypred_knn), color='red')
p_test + geom_path(aes(x = mileage, y = ypred_knn), color='red')

