# Saratoga House Prices Exercise 2

rmse <- function(y, yhat) {
  sqrt(mean((y - yhat)^2))
}

library(tidyverse)
library(mosaic)
data(SaratogaHouses)

n <- nrow(SaratogaHouses)
n_train <- round(0.8*n)  # round to nearest integer
n_test <- n - n_train
train_cases <- sample.int(n, n_train, replace=FALSE)
test_cases <- setdiff(1:n, train_cases)
saratoga_train <- SaratogaHouses[train_cases,]
saratoga_test <- SaratogaHouses[test_cases,]

model <- lm(price ~ rooms * livingArea + centralAir * heating, data = saratoga_train)

summary(model)

yhat_test <- predict(model, saratoga_test)

rmse(saratoga_test$price, yhat_test)
