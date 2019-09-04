# package: http://web.mit.edu/insong/www/pdf/rpackage_instructions.pdf

# importing dependencies and setting initial config
options(java.parameters = "-Xmx4g")     # assign 2GB max of heap memory size
library("bartMachine")                  # import package "bartMachine", which provides an implementation of the BART algorithm
set_bart_machine_num_cores(2)           # assign 2 cores to be used by the implementation of Gibbs sampler of "bartMachine"

# importing a design matrix X and a predicted variable y from a training dataset.
# X and y are expected to have already been cleaned and transformed.

X <- something # from another script/function
y <- something # from another script/function

# grid-searching for the BART model with best out-of-sample via cross-validation on the hyperparameters k, nu, q, and number of trees.
# we use a 1000 burn-in sample for the Gibbs sampler and 10 folds for cross-validation.
# we enable serialization and disable mem_cache_for_speed given memory size constraint.

cv_bart_machine_posConv <- bartMachineCV(X_transformed, log_y, k_folds = 10, num_burn_in = 10000, num_iterations_after_burn_in = 20000, mem_cache_for_speed = FALSE, serialize = FALSE)
# bartMachine(X_transformed, log_y, num_trees = 200, num_burn_in = 10000, num_iterations_after_burn_in = 20000, mem_cache_for_speed = FALSE, serialize = FALSE)

# using Shapiro-Wilk test and QQ plot to assess hypothesis of normality of residuals

normality_pvalue <- shapiro.test(cv_bart_machine$residuals)$p.value
qqp(cv_bart_machine$residuals)

# using One Sample T-test to assess hypothesis of a zero-mean residual distribution

zero_mean_pvalue <- t.test(cv_bart_machine$residuals)$p.value

# using residuals vs predicted plot to assess hypothesis of heteroscedasticity/homoscedasticity

plot(cv_bart_machine$y_hat_train, cv_bart_machine$residuals)
abline(h = 0, col = "black")
par(mfrow = c(1, 1))

# sigsq estimation convergence
# ***********TODO***********

# using method 'plot_convergence_diagnostics' from 'bartMachine' to assess Gibbs sampler convergence
plot_convergence_diagnostics(cv_bart_machine)

# recording out-of-sample performance of the BART 'winning model' returned by bartMachineCV
# we use 10 folds for the cross-validation and 1000 burn-in samples.

k_fold_cv(X, y, k_folds = 10, num_burn_in = 1000, k = cv_bart_machine$k, nu = cv_bart_machine$nu, q = cv_bart_machine$q, num_trees = cv_bart_machine$num_trees)

# using method 'plot_y_vs_yhat' from 'bartMachine' to plot credible intervals and prediciton intervals coverage along with converage percentage.
plot_y_vs_yhat(cv_bart_machine, credible_intervals = TRUE)
plot_y_vs_yhat(cv_bart_machine, prediction_intervals = TRUE)

# investigating the most important variables in the model

# grid-searching a new BART model with an Informed Prior vector for those most important variables
