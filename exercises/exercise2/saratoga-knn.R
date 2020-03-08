# Saratoga House Prices Exercise 2

rmse <- function(y, yhat) {
  sqrt(mean((y - yhat)^2))
}

library(tidyverse)
library(mosaic)
data(SaratogaHouses)

SaratogaHouses <- mutate(SaratogaHouses, oil = as.factor(ifelse(fuel == 'oil', 'Yes', 'No')))
SaratogaHouses <- mutate(SaratogaHouses, gas = as.factor(ifelse(fuel == 'gas', 'Yes', 'No')))
SaratogaHouses <- mutate(SaratogaHouses, electric = as.factor(
  ifelse(fuel == 'electric', 'Yes', 'No')))

n <- nrow(SaratogaHouses)
n_train <- round(0.8*n)  # round to nearest integer
n_test <- n - n_train
train_cases <- sample.int(n, n_train, replace=FALSE)
test_cases <- setdiff(1:n, train_cases)
saratoga_train <- SaratogaHouses[train_cases,]
saratoga_test <- SaratogaHouses[test_cases,]

model <- lm(price ~ bathrooms * livingArea, data = saratoga_train)

summary(model)

yhat_test <- predict(model, saratoga_test)

rmse(saratoga_test$price, yhat_test)

not.factor <- function(x) !is.factor(x)
cor(select_if(SaratogaHouses, not.factor))

ggplot(data = SaratogaHouses) +
  geom_point(aes(x = age, y = price, color = centralAir))
ggplot(data = SaratogaHouses) +
  geom_boxplot(aes(x = heating, y = price, color = centralAir))
ggplot(data = SaratogaHouses, aes(waterfront, price, color = centralAir)) +
  geom_boxplot()

rmse_vals <- do(200) * {
  train_cases <- sample.int(n, n_train, replace=FALSE)
  test_cases <- setdiff(1:n, train_cases)
  saratoga_train <- SaratogaHouses[train_cases,]
  saratoga_test <- SaratogaHouses[test_cases,]
  
  model <- lm(price ~  age * pctCollege + livingArea * rooms * bathrooms +
                livingArea * bedrooms * rooms +
                centralAir * livingArea + newConstruction + 
                fuel + waterfront + log(pctCollege), data = saratoga_train)
  
  yhat_test <- predict(model, saratoga_test)
  
  rmse(saratoga_test$price, yhat_test)
  
}

mean(rmse_vals$result)

