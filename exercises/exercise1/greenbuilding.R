install.packages(ggthemes)
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
#ggplot(data = greenb, aes(green_rating,Rent)) + 
#  geom_point(aes(color = totalrent))

#mod2 = lm(Rent ~ size + leasing_rate + stories + age + renovated + class_a + green_rating, data = greenb)
#summary(mod2)



ggplot(greenb, aes(x = size)) +
  geom_histogram(binwidth = 5, breaks = seq(0,100, 10) )


# #Add references. 
# Relationship between leasing_rate and Rent - Green Building

ggplot(filter(greenb, green_rating == "1"), aes(x = leasing_rate, y = Rent)) + 
  geom_point(size = 1.5, alpha = 0.25) + 
  theme_few()  + 
  geom_smooth()
# From the scatter plot, we can see there are few green building have learsing rate lower than 50%. Moderate number of green build have leasing rate greater than 50% and smaller than 75%. Majority number of green building's leasing rate greater than 75% and smaller than 100%. 




# Relationship between leasing_rate and Rent - Non green Building

ggplot(filter(greenb, green_rating == "0"), aes(x = leasing_rate, y = Rent)) + 
  geom_point(size = 1.5, alpha = 0.25) + 
  theme_few()  + 
  geom_smooth()

# The number of nongreen building increase as the leasing rate increase. There are fair amount of nongreen buildings have small leasing rate ( 0 < leasing rate < 25 ), but their average rent close to the total average rent. 

#The Non green building with lower leasing_rate have bigger market then green building with lower leasing_rate. 

 


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
  geom_point(size = 1.5, alpha = 0.25) + 
  facet_grid(. ~ Build) +
  theme_few()

# We use leasing rate * Rent to get total revenus per square foot the company can gain. We explored the relationship between leasing rate and total revenus. From the scatter plot, we can see that the nongreen building generate higher total revenue  than green building


#Summary: From the revenue prospective, the green building don't  advangates then nongreenbuild. And we know cost of built a green building is higher than nongreen building.


ggplot(greenb, aes(x = age, y = total_r)) + 
  geom_point() + 
  facet_grid(. ~ Build) +
  theme_few()

# We can see most of the green building are new, the age of most  greenbuil are less than 50 years. All of greenbuilding are less than 100 years.  
# The minimum age of nongreen building is 0 year, and the maximum is 187 year. The average age of nongreen building is 47.24 year. The medium age is 34 year. 
#For the small age of building, no matter they are greenbuilding and nongreenbuilding, the total revenue is similar. 



# Factor the class_a and class_b
greenb <- greenb %>% 
  mutate(class = factor(class_a, levels = c(1,0),
                        labels = c("Class_a", "Class_b")))


ggplot(data = greenb) +
  geom_bar(mapping = aes(x = Build, fill = class),position = "fill") +
  scale_fill_brewer( palette = "Blues")

n
# Control many variables to see how the G & NG  building affect the total_r
mod3 = lm(Rent ~ cluster + empl_gr + stories + age + class_a + leasing_rate + green_rating, data = greenb)
summary(mod3)

ggplot(data=greenb) + 
  geom_histogram(aes(x=size))



ggplot(greenb, aes(x = leasing_rate, y = total_r)) + 
  geom_point() + 
  facet_grid(. ~ Build) +
  theme_few()



greenb <- greenb %>% 
  mutate(leasing_catg = cut(leasing_rate, c(0,20, 40, 60, 80, 100)))
summary(greenb)

#Continue to dig in 
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

 





