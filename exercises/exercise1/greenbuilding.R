
library(mosaic)
library(tidyverse)
library(ggthemes)
library(ggplot2)
library(RColorBrewer)

greenb = read.csv("~/Desktop/SDS 323/Exercises/Exercises 1/data/greenbuildings.csv")
names(greenb)

# Creat a new variable totalrent
greenb$totalrent <- greenb$Rent * greenb$size * greenb$leasing_rate



# change the totalrent's unit

#greenb$totalrent <- greenb$totalrent / 1000
#mod1 = lm(totalrent ~ stories + age + renovated + class_a + green_rating, data= greenb)
#summary(mod1)
 
# Check the multicollinearity
#library(car)
#vif(mod1)


# Draw a Scatter pot to explore the relationship between rent & green_rating
#Question: 
ggplot(data = greenb, aes(green_rating,Rent)) + 
  geom_point(aes(color = totalrent))

#mod2 = lm(Rent ~ size + leasing_rate + stories + age + renovated + class_a + green_rating, data = greenb)
#summary(mod2)

ggplot(greenb, aes(x = leasing_rate)) +
  geom_histogram(binwidth = 5, breaks = seq(0,100, 10) )


install.packages(ggthemes)
library(ggthemes)

# Add references. For example, if you show what it typical, it helps viewers interpret how unusual outliers are.
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

# I fund that the when the Non green building with lower leasing_rate have bigger market then green building with lower leasing_rate


# Small multiples

greenb <- greenb %>% 
  mutate(Build = factor(green_rating, levels = c(1,0),
                        labels = c("Green Building", "Nongreen Building")))

# Scatter plot 
ggplot(greenb, aes(x = leasing_rate, y = Rent)) + 
  geom_point(size = 1.5) +
  facet_grid(. ~ Build) +
  theme_few() 
 
# Calculate the revenue
greenb$total_r <- (greenb$leasing_rate * greenb$Rent)/100


 
ggplot(greenb, aes(x = leasing_rate, y = total_r)) + 
  geom_point() + 
  facet_grid(. ~ Build) +
  theme_few()


ggplot(greenb, aes(x = age, y = total_r)) + 
  geom_point() + 
  facet_grid(. ~ Build) +
  theme_few()

names(greenb)

# Factor the class_a and class_b
greenb <- greenb %>% 
  mutate(class = factor(class_a, levels = c(1,0),
                        labels = c("Class_a", "Class_b")))


ggplot(data = greenb) +
  geom_bar(mapping = aes(x = Build, fill = class),position = "fill") +
  scale_fill_brewer( palette = "Blues")

names(greenb)
# Control many variables to see how the G & NG affect the total_r
mod3 = lm(Rent ~ cluster + empl_gr + stories + age + class_a + leasing_rate + green_rating, data = greenb)
summary(mod3)

ggplot(data=greenb) + 
  geom_histogram(aes(x=age))



ggplot(greenb, aes(x = leasing_rate, y = total_r)) + 
  geom_point() + 
  facet_grid(. ~ Build) +
  theme_few()



greenb <- greenb %>% 
  mutate(leasing_catg = cut(leasing_rate, c(0,20, 40, 60, 80, 100)))
summary(greenb)


ggplot(data = greenb) +
  geom_bar(mapping = aes(x = leasing_catg, y = total_r, 
  fill = Build),
  stat='identity', position ='dodge') +
  theme_few() +
  scale_fill_brewer( palette = "Blues")
  labs(title = "xxxxx",
       y = "Total Revenue /Square foot",
       x = "Leasing.rate",
       fill = "Building")  

 





