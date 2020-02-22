library(mosaic)
library(tidyverse)

# Read the data file
milk = read.csv("~/Desktop/SDS 323/Exercises/Exercises 1/data/milk.csv")
names(milk)

# Find the relationship between and f(p) = Q. (Q = aP^b)  (P is x)


ggplot(data = milk) +
  geom_point(aes(x = price, y = sales)) +
  geom_smooth(mapping = aes(x = price, y = sales) )
# Recognize this in not a linear regression. This is a demand function. Therefore, we use Power law 

mod1 = lm(log(sales) ~ log(price), data = milk)
coef(mod1)
#log(Q) = 4.7 - 1.62 * log(P)
# bate 0 is log(alpha)
#Q = e ^ 4.7 * P ^ -1.62 = 110 * P ^ -1.62

plot(log(sales) ~ log(price), data = milk)
abline(mod1, col = "red")

# Now: N = (P - C) * 110 * P ^ -1.62
# to find the optimal profit
curve((x-1)*110*x^(-1.62), from = 1, to = 9)
#Zoom in 
curve((x-1)*110*x^(-1.62), from = 2.5, to = 2.7)




