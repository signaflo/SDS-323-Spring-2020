# Saratoga House Prices Exercise 2

library(tidyverse)
library(mosaic)
library(splines)
data(SaratogaHouses)

rmse <- function(y, yhat) {
  sqrt(mean((y - yhat)^2))
}

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

# Simple wrapper function to test for features that aren't factors.
not.factor <- function(x) !is.factor(x)

# Show the correlation matrix to get an idea of price effects and interactions.
cor(select_if(SaratogaHouses, not.factor))

ggplot(data = SaratogaHouses) +
  geom_point(aes(x = livingArea, y = price, color = centralAir))
ggplot(data = SaratogaHouses) +
  geom_boxplot(aes(x = fuel, y = price, color = centralAir))

ggplot(data = SaratogaHouses, aes(waterfront, price, color = centralAir)) +
  geom_boxplot()

age_model <- lm(price ~ ns(age, df = 5), data = SaratogaHouses)
p <- ggplot(data = SaratogaHouses)
p + geom_point(aes(x = age, y = price), color = "gray", alpha = 0.5) +
  geom_line(aes(age, age_model$fitted.values), color = "red", alpha = 0.75, size = 0.5)

college_model <- lm(price ~ bs(pctCollege, df = 7), data = SaratogaHouses)
p + geom_point(aes(x = pctCollege, y = price), color = "gray", alpha = 0.5) +
  geom_line(aes(pctCollege, college_model$fitted.values), color = "red", alpha = 0.75, size = 0.5)

rmse_vals <- do(250) * {
  train_cases <- sample.int(n, n_train, replace=FALSE)
  test_cases <- setdiff(1:n, train_cases)
  saratoga_train <- SaratogaHouses[train_cases,]
  saratoga_test <- SaratogaHouses[test_cases,]
  
  model <- lm(price ~  bs(pctCollege, df = 7) + ns(age, df = 5) +
                livingArea * rooms * bathrooms +
                livingArea * rooms * bedrooms +
                livingArea * centralAir + newConstruction + 
                fuel + waterfront, data = saratoga_train)
  
  yhat_test <- predict(model, saratoga_test)
  
  rmse(saratoga_test$price, yhat_test)
  
}

mean(rmse_vals$result)


library(FNN)
library(foreach)

k_grid <- exp(seq(log(1), log(100), length=33)) %>% round %>% unique

rmse_grid <- foreach(K = k_grid, .combine='c') %do% {
  out <- do(100) * {
    
    train_cases <- sample.int(n, n_train, replace=FALSE)
    test_cases <- setdiff(1:n, train_cases)
    saratoga_train <- SaratogaHouses[train_cases,]
    saratoga_test <- SaratogaHouses[test_cases,]
    
    training_features <- model.matrix(~ pctCollege + age + livingArea +
                                        rooms + bathrooms + bedrooms +
                                        centralAir + newConstruction + 
                                        fuel + waterfront - 1, data = saratoga_train)
    test_features <- model.matrix(~ pctCollege + age + livingArea +
                                    rooms + bathrooms + bedrooms +
                                    centralAir + newConstruction + 
                                    fuel + waterfront - 1, data = saratoga_test)
    
    training_response <- saratoga_train$price
    test_response <- saratoga_test$price
    
    training_scale <- apply(training_features, 2, sd)
    
    training_features <- scale(training_features, scale = training_scale)
    test_features <- scale(test_features, scale = training_scale)
    
    knn_model <- knn.reg(training_features, test_features, training_response, k = K)
    rmse(test_response, knn_model$pred)
  }
  mean(out$result)
}

plot(k_grid, rmse_grid, log = 'x')
abline(h = mean(rmse_vals$result))
