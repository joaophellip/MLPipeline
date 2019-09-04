# MLPipeline

Cozo Machine Learning Pipeline.

This repository contains routines to assess convergence, test assumptions, and grid-search a regression model with the best prediction performance. Performance is assessed via the root mean square error calculated using out-of-sample predictions. These
predictions are generated from a k-fold cross validation process.

The scripts run in R and they're not ready to be integrated to the Cozo platform. Current version isn't fully automated to generate model either - it requires researcher to validate hypothesis and convergence based on scripts outputs.

Scripts:

bartMachineWithChecking.R : implements a BART model using a package called bartMachine; it also runs more automated MCMC convergence diagnostics and residual checking tests as compared to those in bartMachine.

bartMachineWithChecking.R : implements a search for best model over a set of hyperparameters and tree size. Uses a K-fold cross validation process to search for model with smallest out-of-sample RMSE. It builds on the function defined in bartMachineWithChecking.

How to use:

Import the function 'cross_validation_bart_modeling' into your workspace running:

    source("bartMachineWithChecking.R")

Then call the function suplying a design matrix X and a response vector y:

    cross_validation_bart_modeling(X, y)

Work in progress:
    automation of convergence and assumption testing criteria.
    integration with the variable selection process