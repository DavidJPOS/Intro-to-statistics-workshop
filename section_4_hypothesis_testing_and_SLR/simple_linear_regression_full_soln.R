##################################################
## Project: Indusry Workshop
## Script purpose: SLR for credit data
## Date: 24-2-2020
## Author: David JPO'Sullivan, Kevin Burke & Norma Bargary
##################################################

rm(list = ls()) # tidy work space
gc()

# libraries, source files and data ---------------

# what packages are we using
library(knitr)
library(tidyverse)
library(broom)
library(cowplot)
library(esquisse)

theme_set(theme_cowplot())

# hypothesis testing ------------------------------------------------------

# Given the credit data, we are interested in two questions:

# 1) is there a relationship between the mean amount owed and whether a person will default?
#       (t-test for independent samples)
# 2) is the mean amount owed between months the same?
#       (t-test for paired/dependent samples)

# first load in the data
credit_hyo_df <- read_csv(file = './data/credit_hyp.csv')

# have a peek at the data (do we need to do any cleaning?)
glimpse(credit_hyo_df)

# clean the data: 
credit_hyo_df <- credit_hyo_df %>% 
  mutate(default = factor(default, levels = c(0, 1), labels = c('not-default', 'default')))

# 1) what to test for a difference in total bill total amount for those who default
# and those who dont

# first, visulise the distributions
esquisse::esquisser(credit_hyo_df)

ggplot(credit_hyo_df) +
  aes(x = default, y = total_bill_amt, fill = default) +
  geom_boxplot() +
  labs(x = "Default", y = "Bill Amount", title = "Box plot of defaults")

t_test_results <- t.test(credit_hyo_df$total_bill_amt ~ credit_hyo_df$default)
t_test_results

# what values are stored in t_test_results?
names(t_test_results)

t_test_results$p.value

# p < 0.05. At a 5% level of significance, there is a difference between the average amount owed
# between the default and non-defualt groups

# what about the confidence intervals? 
t_test_results$conf.int

# so we can be 95% confident that the true difference between population means lies between
# 754 and 14853.

# 2) is there is a difference between mean amount owed between months

# first, we can visulise the distribution
credit_hyo_df <- credit_hyo_df %>% mutate(paired_diff = bill_amt1 - bill_amt2)
esquisse::esquisser(credit_hyo_df)

ggplot(credit_hyo_df) +
  aes(x = paired_diff) +
  geom_histogram(bins = 30L, fill = 'steelblue', color = 'black') +
  labs(x = "Paired difference", y = "Count", title = "Difference in amount owed") +
  theme_minimal()

# For a paired sample we need to set paired to TRUE
t.test(credit_hyo_df$bill_amt1, credit_hyo_df$bill_amt2, paired = TRUE)

# p < 0.05. Therefore there is a difference between the bill amount between months
# we are 95% confident that the true population mean difference between
# months lies between 1592 and 2234.
# Therefore people, on average, are spending more this month than in the previous
# month

# what next? ---------------------------------------------------------------

# Given that there is a difference between the months, can we predict how 
# much people will owe us this month using last month spending history?
# In the next section, we will fit a linear regression model to bill
# amount data.

# simple linear regression example ----------------------------------------
credit_slr_df <- read_csv(file = './data/credit_slr_train.csv')

# code to examine data --------------------------------------------------

esquisse::esquisser(credit_slr_df)

# examine each of the varaibles first.
p1 <- ggplot(credit_slr_df, aes(x = bill_amt1)) +
  geom_histogram(aes(y=..density..), # Histogram with density instead of count on y-axis
                 colour="black", fill="grey") + 
  geom_density(fill = 'steelblue', color = 'black', alpha = 0.6) +
  xlab('Bill amount') +
  ylab('Density') +
  ggtitle('Distribution of bill amounts (this month)')
p1  

p2 <- ggplot(credit_slr_df, aes(x = bill_amt2)) +
  geom_histogram(aes(y=..density..), # Histogram with density instead of count on y-axis
                 colour="black", fill="grey") + 
  geom_density(fill = 'steelblue', color = 'black', alpha = 0.3) +
  xlab('Bill amount') +
  ylab('Density') +
  ggtitle('Distribution of bill amounts (last month)')
p2

# scatterplot
ggplot(credit_slr_df, aes(x = bill_amt2, y = bill_amt1)) +
  geom_point() +
  geom_smooth() + # add a trend line
  xlab('Last month') +
  ylab('This month')

# There is a clear relationship between this month's bill and
# last month's bill. The more a person used their credit card 
# last month, the more they are likely to spend this month
# this month.

# But how strong is the linear relationship between these variables?
cor(credit_slr_df$bill_amt1, credit_slr_df$bill_amt2)


# Fit linear regression model to this data.
credit_lm <- lm(formula = bill_amt1 ~ bill_amt2, data = credit_slr_df)
credit_lm # examine the model coefficents

# We would like to add the linear model to our ggplot
# ggplot is build around plotting tibbles. We can turn 
# the model into a tibble and add it to the plot.
# Fit linear regression model to this data.

# 'augment' comes from the broom package. The broom packages supports
# tidying many standard models
?augment

augment(credit_lm)
model_df <- augment(credit_lm)

ggplot(credit_slr_df, aes(x = bill_amt2, y = bill_amt1)) +
  geom_point() +
  geom_line(data = model_df, aes(y = .fitted),
            size = 2, color = 'red', linetype = 2) +
  xlab('Last month') +
  ylab('This month')

summary(credit_lm)

# What are the confidence interval for the parameters
confint(credit_lm)

# The intercept is not statistically signifant (p > 0.05)
# but we normally dont remove the intercept parameter. 
# The slope is statistically significant (p < 0.05... by a long way!)

# we can be 95% confident that the population slope for this model lies between
# 1.03 and 1.10 
credit_lm$coefficients

# We expect for a 1 unit increase in the amount owed last month they will owe 1.06 this month.

# R^2 is 0.94. We can expain 94% of the variation in this month's bill amount using
# last month's bill amount

# next we can evaluate some model diagnositcs
par(mfrow = c(2,2))
plot(credit_lm)
par(mfrow = c(1,1))

# there is some evidence of departures from normality in the tails
# we also have evidence of a point of high leverage (sample 119), and it might be
# worth investigating what is different about that particular person. 

# Model diagnostics plots as shown in lecture slides
model_df
p1 <- ggplot(model_df, aes(x=.resid)) + 
  geom_histogram(fill="steelblue", colour="black") +
  xlab("Residuals") + theme_bw()

p2 <- ggplot(model_df, aes(sample=.resid)) + 
  geom_qq() + 
  geom_qq_line()+ theme_bw()

p3 <- ggplot(model_df, aes(x=.fitted, y=.resid)) + 
  geom_point() +
  xlab("Fitted") + ylab("Residuals") + 
  geom_hline(yintercept = 0) + theme_bw()

p4 <- model_df %>% arrange() %>% 
  ggplot(., aes(x=1:nrow(model_df), y=.resid)) + 
  geom_line() + 
  xlab("Order") + ylab("Residuals") + 
  geom_hline(yintercept=0, lty=2) + theme_bw()

cowplot::plot_grid(p1,p2,p3,p4, labels = c('A','B',"C","D"))

# predict next month's bill  -----------------------------------------------------

# we will now use the model to forecast bill_amt1 on some "unseen" test data.
# Typically predictions for test data will be worse than predictions for
# training data (since the model has been fitted to the training data and, therefore,
# tends to be closer to the training data).
# It is always important to assess model performance on unseen data as this
# is exactly what we want to achieve with such a model in practice: 
# to predict future, unseen values.


# here we load in a test data set. This contains a set of new observations which
# were not used in model fitting, i.e., we have unseen data.
credit_slr_test_df <- read_csv(file = './data/credit_slr_test.csv')

# note that we only have bill_amt2 (imagine this is the current month) and want to 
# make predictions about bill_amt1 (which is currently unknown).
credit_slr_test_df

# we can make predictions from our linear regression model
predict(credit_lm, newdata = credit_slr_test_df)

# can easily add them to the tibble and save. 
credit_slr_test_df$pred_bill_amt1 <- predict(credit_lm, newdata = credit_slr_test_df)
write_csv(x = credit_slr_test_df, path = './data/credit_slr_pred.csv')

# Now let's assume that a month has passed since our predictions so that we now have
# observed the bill_amt1 values.
credit_slr_test_f_df <- read_csv(file = './data/credit_slr_test_full.csv')
credit_slr_test_f_df

# add predicted values as before
credit_slr_test_f_df$pred_bill_amt1 <- predict(credit_lm, newdata = credit_slr_test_df)

# we can also visually inspect the fitted model using the new test data
ggplot(credit_slr_test_f_df, aes(x = bill_amt2, y = bill_amt1)) +
  geom_point() +
  geom_line(data = augment(credit_lm), aes(y = .fitted),
            size = 2, color = 'red', linetype = 2) +
  xlab('Last month') +
  ylab('This month')


# the fit to the scatter plot doesn't look nearly as impressive as before.
# to see what is going on, we can extract the data used for model fitting (the training data)
# and plot this along with the new data. 
ggplot(credit_slr_test_f_df, aes(x = bill_amt2, y = bill_amt1)) +
  geom_point() +
  geom_point(data = credit_slr_df, 
             aes(x = bill_amt2, bill_amt1), color = 'red', alpha = 0.5, shape = 1) + 
  geom_line(data = augment(credit_lm), aes(y = .fitted),
            size = 2, color = 'red', linetype = 2) +
  xlab('Last month') +
  ylab('This month')


# It looks like there still is a linear trend in the data but shifted.
# what could be the cause of this? 
# Model drift: there maybe some unforseen factor at play (like seasonal effects) resulting
# in different amounts spent at different times of year. 
# For example, you expect people, on average, to spend more during Christmas than at other times 
# of the year and our linear regression model does not account for this. 

# extension of this model to account for such temporal features in the data will be covered in later
# workshops

# tidy works space when finished -----------------
# 
# rm(list = ls()) # tidy work space
# gc()
