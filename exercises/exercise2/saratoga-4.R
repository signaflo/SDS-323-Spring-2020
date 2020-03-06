library(tidyverse)
library(mosaic)
library(dplyr)
data(SaratogaHouses)

summary(SaratogaHouses)

## debug NOT SURE WHY, BUT FOR SOME REASON ADDING THE LAND AND HOUSE MODELS CHANGES THE RMSE
# OUT OF SAMPLE FOR THE MEDIUM MODEL FROM 60K TO 30K...

# 11 main effects
lm_medium = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=SaratogaHouses)

# Sometimes it's easier to name the variables we want to leave out
# The command below yields exactly the same model.
# the dot (.) means "all variables not named"
# the minus (-) means "exclude this variable"
lm_medium2 = lm(price ~ . - sewer - waterfront - landValue - newConstruction, data=SaratogaHouses)

# separate the fuel variable into the different types
SaratogaHouses = mutate(SaratogaHouses, oil = ifelse(fuel == 'oil', 'Yes', 'No'))
SaratogaHouses = mutate(SaratogaHouses, gas = ifelse(fuel == 'gas', 'Yes', 'No'))
## debug need to make electric? Or is everything evaluated relative to electric

# Crystal's linear model, trying to improve lm_medium
lm_mine_og = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
               fireplaces + bathrooms + rooms + centralAir + waterfront + 
               sewer + newConstruction + oil + gas +
               bedrooms*rooms + bathrooms*rooms, data=SaratogaHouses)

# create landvalue model to compare with improvement of house (price) model
lm_land_og = lm(landValue ~ lotSize + pctCollege +  waterfront + sewer, data = SaratogaHouses)

# generate new variable called houseValue
# SaratogaHouses = mutate(SaratogaHouses, houseValue = (price - landValue))


# create a regression where the dependent variable is houseValue, rather than price
# house improvement solely
lm_house_og = lm(houseValue ~ age + livingArea + pctCollege + bedrooms +
                fireplaces + bathrooms + rooms + centralAir + newConstruction +
                bedrooms*rooms + bathrooms*rooms, data=SaratogaHouses)

####
# Compare out-of-sample predictive performance
####

# Split into training and testing sets
n = nrow(SaratogaHouses)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
saratoga_train = SaratogaHouses[train_cases,]
saratoga_test = SaratogaHouses[test_cases,]

# Fit to the training data
lm2 = lm(price ~ . - sewer - waterfront - landValue - newConstruction, data=saratoga_train)
lm_mine = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                   fireplaces + bathrooms + rooms + centralAir + waterfront + 
                   sewer + newConstruction + oil + gas +
                   bedrooms*rooms + bathrooms*rooms, data=saratoga_train)
# try to separate the different effects or signals
lm_land = lm(landValue ~ lotSize + pctCollege +  waterfront + sewer, data = saratoga_train)
lm_house = lm(houseValue ~ age + livingArea + pctCollege + bedrooms +
                fireplaces + bathrooms + rooms + centralAir + newConstruction +
                bedrooms*rooms + bathrooms*rooms, data=saratoga_train)

# Predictions out of sample
yhat_test2 = predict(lm2, saratoga_test)
yhat_testmine = predict(lm_mine, saratoga_test)
yhat_testland = predict(lm_land, saratoga_test)
yhat_testhouse = predict(lm_house, saratoga_test)



rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )
}

# Root mean-squared prediction error

rmse(saratoga_test$price, yhat_test2)
rmse(saratoga_test$price, yhat_testmine)
rmse(saratoga_test$landValue, yhat_testland)
rmse(saratoga_test$houseValue, yhat_testhouse)



# easy averaging over train/test splits
library(mosaic)

n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train

rmse_vals = do(100)*{
  
  # re-split into train and test cases with the same sample sizes
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]
  
  # Fit to the training data
  
  lm2 = lm(price ~ . - sewer - waterfront - landValue - newConstruction, data=saratoga_train)
  lm_mine =  lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                  fireplaces + bathrooms + rooms + centralAir + waterfront + 
                  sewer + newConstruction + oil + gas +
                  bedrooms*rooms + bathrooms*rooms, data=saratoga_train)
  
  # lm_land = lm(landValue ~ lotSize + pctCollege +  waterfront + sewer, data = saratoga_train)
  # lm_house = lm(houseValue ~ age + livingArea + pctCollege + bedrooms +
  #                 fireplaces + bathrooms + rooms + centralAir + newConstruction +
  #                 bedrooms*rooms + bathrooms*rooms, data=saratoga_train)
  
  # Predictions out of sample
  yhat_test2 = predict(lm2, saratoga_test)
  yhat_testmine = predict(lm_mine, saratoga_test)
  # yhat_testhouse = predict(lm_house, saratoga_test)
  # yhat_testhouse = predict(lm_house, saratoga_test)
  
  c(
    rmse(saratoga_test$price, yhat_test2),
    rmse(saratoga_test$price, yhat_testmine)
    # ,
    # rmse(saratoga_test$landValue, yhat_testland),
    # rmse(saratoga_test$houseValue, yhat_testhouse)
    )
}

rmse_vals
colMeans(rmse_vals)
boxplot(rmse_vals)

# try to create a KNN model
