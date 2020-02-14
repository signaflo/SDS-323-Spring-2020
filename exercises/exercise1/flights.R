library(mosaic)
library(tidyverse)

# Read in the Austin 2008 flights data

abia <- read.csv("data/ABIA.csv", header = TRUE)

# Investigate median departure delays by month.

departure_delays_by_month <- abia %>% 
  group_by(Month) %>% 
  filter(DepDelay > 0) %>% 
  # Take the median since the distribution is highly skewed.
  summarize(delay = median(DepDelay, na.rm = TRUE)) %>%
  select(delay) %>% 
  mutate(month = month.name)

ggplot(data = departure_delays_by_month) +
  geom_point(
    mapping = aes(x = delay, y = month),
    color = "red",
    size = 3,
    alpha = 0.6
  ) +
  geom_vline(xintercept = 0, size = .25) +
  xlim(c(0, 20)) +
  scale_y_discrete(limits = rev(month.name)) +
  labs(title = "Median Departure Delay by Month", y = "", x = "Delay in Minutes")

arrival_delays_by_month <- abia %>% 
  group_by(Month) %>% 
  filter(ArrDelay > 0) %>% 
  # Take the median since the distribution is highly skewed.
  summarize(delay = median(ArrDelay, na.rm = TRUE)) %>%
  select(delay) %>% 
  mutate(month = month.name)

ggplot(data = arrival_delays_by_month) +
  geom_point(
    mapping = aes(x = delay, y = month),
    color = "red",
    size = 3,
    alpha = 0.6
  ) +
  geom_vline(xintercept = 0, size = .25) +
  xlim(c(0, 20)) +
  scale_y_discrete(limits = rev(month.name)) +
  labs(title = "Median Arrival Delay by Month", y = "", x = "Delay in Minutes")



