##################################################
## Project: Workshop
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

# given the data we might be interested in two questions

# 1) is there a relationship between the mean amount owed and whether a person will default?
#       (t-test for independent samples)
# 2) is the mean amount owed between months the same?
#       (t-test for paired/dependent samples)

# first load in the data

## << ------------------------------------------- >> ##
##    Insert code here to load in the data set
## << ------------------------------------------- >> ##

## << ------------------------------------------- >> ##
##    Insert code here to examine data 
## << ------------------------------------------- >> ##

## << ------------------------------------------- >> ##
##    Insert code here to recast default as a factor
## << ------------------------------------------- >> ##

# 1) what to test for a difference in total bill total amount for those who default
# and those who dont

## << ------------------------------------------- >> ##
##    
##    Insert code here to plot default and total_bill_amt
##    and perform a t-test for difference in population means
##    
## << ------------------------------------------- >> ##

# 2) is there is a difference between mean amount owed between months


## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    create a new varaible called paired_diff which is the difference
##    between bill_amt 1 and bill_amt2.
##    
##    create a box plot of paired_diff.
##
##    Perform a paired sample t-test and interpret the results.
##    
## << ------------------------------------------- >> ##


# what next? ---------------------------------------------------------------

# Given that there is a difference between the months, can we predict how 
# much people will owe us this month using last month spending history?
# In the next section we will fit a linear regression model to the bill
# amount data.

# simple linear regression example ----------------------------------------
credit_slr_df <- read_csv(file = './data/credit_slr_train.csv')


# create some descriptive of the data
## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    Read in the data that we will use to build the model.
##    
##    Plot the distribution of bill_amt1 and bill_amt2 and comment on the 
##    distribution.
##    
##    Create a scatter plot of bill_amt1 and bill_amt2 with a trend line.
##
##    Calculate the correlation between bill_amt1 and bill_amt2 using cor()
##    and comment on the strength of the linear relationship.
##
## << ------------------------------------------- >> ##

# Estimate the line of best fit to the data

## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    Fit a simple linear regression model where bill_amt1 is the output 
##    and bill_amt2 is the input.
##
##    Investigate the function 'augment' from the broom package and use it to superimpose the 
##    the estimated linear regression model on the bill amount data.
##
##    Examine the summary of the linear regression model commenting on
##    the signifance of parameters (intercept and slope).
##
##    Examine the confidence interval for the slope and interpret it.
##
##    What is the interpretation of the model coefficents?
##
##    How well does the regression capture the varaiblity in bill_amt1
##    Hint: Using the R2 (R-squared) values.
##    
## << ------------------------------------------- >> ##

# Create diagnostic plots

## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    Create diagnostic plots using plot(regression_model_object).
##
##    Comment on:
##    residules vs fitted values.
##    Departaures from normality.
##    Outliers, or points of high leverages.
##    
## << ------------------------------------------- >> ##

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


## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    predict bill_amt_1 using the function predict().
##
##    Append the prediction to credit_slr_test_df and save.
##    
## << ------------------------------------------- >> ##

# Now let's assume that a month has passed since our predictions so that we now have
# observed the bill_amt1 values.
credit_slr_test_f_df <- read_csv(file = './data/credit_slr_test_full.csv')

## << ------------------------------------------- >> ##
##    
##    Insert code here to:
##    add the predicted values to the tibble.
##
##    Plot the actual values for bill_amt1 vs bill_amt2, and add the regression
##    line used to predict the points. 
##    
##    Add the data points used in the model fitting (i.e., the training set)
##    as reference. Comment on what you see.
##
##    
## << ------------------------------------------- >> ##



# tidy works space when finished -----------------

# rm(list = ls()) # tidy work space
# gc()
