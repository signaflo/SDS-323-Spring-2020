

library(mosaic)
library(tidyverse)
library(ggthemes)
library(ggplot2)

greenb = read.csv("~/Desktop/SDS 323/Exercises/Exercises 1/data/greenbuildings.csv")
names(greenb)

# Creat a new variable totalrent
greenb$totalrent <- greenb$Rent * greenb$size * greenb$leasing_rate



# change the totalrent's unit

greenb$totalrent <- greenb$totalrent / 1000


mod1 = lm(totalrent ~ stories + age + renovated + class_a + green_rating, data= greenb)
summary(mod1)
 
# Check the multicollinearity
library(car)
vif(mod1)


# Draw a Scatter pot to explore the relationship between rent & green_rating
#Question: 
ggplot(data = greenb, aes(green_rating,Rent)) + 
  geom_point(aes(color = totalrent))

mod2 = lm(Rent ~ size + leasing_rate + stories + age + renovated + class_a + green_rating, data = greenb)
summary(mod2)

names(greenb)

ggplot(data = greenb) +
  geom_point(aes(x = stories, y = Rent, color = green_rating ))



favstats(greenb$Rent)
favstats(greenb$age)

# I can't get any useful info from this chart, but I will leave at here right now
ggplot(data = greenb) +
  geom_point(aes(x = leasing_rate, y = empl_gr, color = green_rating ))


favstats(greenb$leasing_rate)

ggplot(greenb, aes(x = leasing_rate)) +
  geom_histogram(binwidth = 5, breaks = seq(0,100, 10) )


ggplot(data = greenb) +
  geom_point(aes(x = leasing_rate, y = Rent, color = green_rating ))
 

         
install.packages(ggthemes)
library(ggthemes)
ggplot(greenb, aes(x = leasing_rate, y = Rent, color = green_rating)) + 
  geom_point() + 
  theme_classic()



 

# Add references. For example, if you show what it typical, it helps viewers interpret how unusual outliers are.
library(ggplot2)
# Relationship between leasing_rate and Rent - Green Building

ggplot(filter(greenb, green_rating == "1"), aes(x = leasing_rate, y = Rent)) + 
  geom_point(size = 1.5) + 
  theme_few()  + 
  geom_smooth()
# Relationship between leasing_rate and Rent - Non green Building

ggplot(filter(greenb, green_rating == "0"), aes(x = leasing_rate, y = Rent)) + 
  geom_point(size = 1.5) + 
  theme_few()  + 
  geom_smooth()

# I fund that the when the Non green building with lower leasing_rate have bigger morket then green building with lower leasing_rate


# Small multiples

greenb <- greenb %>% 
  mutate(Build = factor(green_rating, levels = c(1,0),
                        labels = c("Green Building", "Nongreen Building")))

# We can choose which chart we want. Scatter plot or Line chart
ggplot(greenb, aes(x = leasing_rate, y = Rent)) + 
  geom_point() + 
  facet_grid(. ~ Build)


ggplot(greenb, aes(x = leasing_rate, y = Rent)) + 
  geom_line() + 
  facet_grid(. ~ Build)



