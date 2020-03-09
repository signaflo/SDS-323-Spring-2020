library(mosaic)
library(tidyverse)
library(FNN)
library(ggplot2)
library(caret)

arti = read.csv("online_news.csv")
names(arti)
summary(arti)

arti <- arti %>% 
  mutate(viral = ifelse(shares > 1400, 1, 0))


# Make a train - test split 
N = nrow(arti)
N_train = floor(0.8 * N)
N_test = N - N_train

train_ind = sample.int(N, N_train, replace=FALSE)

D_train = arti[train_ind,]
D_test = arti[-train_ind,]

D_test = arrange(D_test, n_tokens_content)
head(D_test)

X_train = model.matrix(shares ~ n_tokens_title + 
                         num_hrefs + num_self_hrefs + num_imgs + average_token_length +
                         num_keywords + data_channel_is_lifestyle + data_channel_is_entertainment +
                         data_channel_is_bus + data_channel_is_socmed +
                         data_channel_is_tech + data_channel_is_world +
                         self_reference_min_shares  + avg_negative_polarity, data=D_train)

y_train = select(D_train, shares)

X_test = model.matrix(shares ~ n_tokens_title + 
                        num_hrefs + num_self_hrefs + num_imgs + average_token_length +
                        num_keywords + data_channel_is_lifestyle + data_channel_is_entertainment +
                        data_channel_is_bus + data_channel_is_socmed +
                        data_channel_is_tech + data_channel_is_world +
                        self_reference_min_shares  + avg_negative_polarity, data=D_test)

y_test = select(D_test, shares)

# scale the training set features
scale_factors = apply(X_train, 2, sd)
X_train = scale(X_train, scale=scale_factors)

# scale the test set features using the same scale factors
X_test = scale(X_test, scale=scale_factors)


# KNN 
knn3 = knn.reg(train = X_train, 
               test = X_test, y = y_train, k=3)
names(knn3)

#####
# Compare the models by RMSE_out
#####
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}


ypred_knn3 = knn3$pred

# Calculate the root mean square error 
# Compare predictions with test articles
rmse(y_test, ypred_knn3)


#Plot the fit 

D_test$ypred_knn3 = ypred_knn3

p_test = ggplot(data = D_test) + 
  geom_point(aes(x = n_tokens_content , y = ypred_knn3), color='black') +
  theme_bw(base_size=18) 

p_test

p_test + geom_point(aes(x = n_tokens_content, y = ypred_knn3), color='red')
p_test + geom_path(aes(x = n_tokens_content, y = ypred_knn3), color='red')

# confusion matrix - make a table of KNN (regular, not classification) errors
# first use the binary responses to get a confusion matrix of probabilities


confusion_valse = 
  do(20) * {
    # re-split into train and test cases with the same sample sizes
    train_ind = sample.int(N, N_train, replace=FALSE)
    
    D_train = arti[train_ind,]
    D_test = arti[-train_ind,]
    
    D_test = arrange(D_test, n_tokens_content)
    
    X_train = model.matrix(shares ~ 
                             n_tokens_title + 
                             num_hrefs + num_self_hrefs + num_imgs + average_token_length +
                             num_keywords + data_channel_is_lifestyle + data_channel_is_entertainment +
                             data_channel_is_bus + data_channel_is_socmed +
                             data_channel_is_tech + data_channel_is_world +
                             self_reference_min_shares  + avg_negative_polarity - 1, data=D_train)
    
    y_train = select(D_train, shares, num_hrefs, average_token_length, viral)
    
    X_test = model.matrix(shares ~  n_tokens_title + 
                            num_hrefs + num_self_hrefs + num_imgs + average_token_length +
                            num_keywords + data_channel_is_lifestyle + data_channel_is_entertainment +
                            data_channel_is_bus + data_channel_is_socmed +
                            data_channel_is_tech + data_channel_is_world +
                            self_reference_min_shares  + avg_negative_polarity - 1, data=D_test)
    
    y_test = select(D_test, shares,num_hrefs, average_token_length, viral)
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train = scale(X_train, scale=scale_factors)
    
    # scale the test set features using the same scale factors
    X_test = scale(X_test, scale=scale_factors)
    
    # KNN 
    knn3 = knn.reg(train = X_train, 
                   test = X_test, y = y_train, k=31)
    
    ##debug NOT SURE IF WE NEED TO MAKE A CONFUSION MATRIX FOR IN SAMPLE ALSO
    
    # out of sample confusion matrix
    viral_prediction = ifelse(ypred_knn3 > 1400, 1, 0)
    confusion_out = table(y = D_test$viral, yhat = viral_prediction)
    confusion_out
    
    sum(diag(confusion_out))/sum(confusion_out) # out-of-sample accuracy
    
    # overall error rate
    
    # true positive rate
    
    # false positive rate 
    
    #across multiple train/test splits!!!!!
  }

confusion_valse
colMeans(confusion_valse)


# got 0.500454  (do 20x), as opposed to guessing "not viral" which got 0.5065584

# compare this to a null model that always predicts "not viral"
# lm_lame = lm(!viral ~ 1, data = arti)
# coef(lm_lame)
# summary(lm_lame)

## Classification Approach
# do viral status as a target variable



