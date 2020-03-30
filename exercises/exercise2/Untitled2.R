library(tidyverse)
library(mosaic)
library(class)
library(foreach)
library(doMC)

arti=read.csv("data/online_news.csv")

X = select(arti, n_tokens_title, 
               num_hrefs, num_self_hrefs, num_imgs, average_token_length,
               num_keywords, data_channel_is_lifestyle, data_channel_is_entertainment,
               data_channel_is_bus, data_channel_is_socmed,
               data_channel_is_tech, data_channel_is_world,
               self_reference_min_shares , avg_negative_polarity)
y = arti$shares
n = length(y)
n_train = round(0.8*n)
n_test = n - n_train

k_grid <- exp(seq(log(1), log(100), length=33)) %>% round %>% unique
k_grid <- k_grid[k_grid != 2]
k_grid

rmse_grid_out1 = foreach(k = k_grid,  .combine='c') %do% {
  out = do(1)*{
    train_ind = sample.int(n, n_train)
    X_train = X[train_ind,]
    X_test = X[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train_sc = scale(X_train, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    X_test_sc = scale(X_test, scale=scale_factors)
    
    knn_mod1 = FNN::knn.reg(as.data.frame(X_train_sc), as.data.frame(X_test_sc), y_train, k=k)
    
    rmse(y_test, knn_mod1$pred)
  } 
  mean(out$result)
}

rmse_grid_out1 = data.frame(K = k_grid, RMSE = rmse_grid_out1)
ind_best = which.min(rmse_grid_out1$RMSE)
k_best = k_grid[ind_best]
k_best

