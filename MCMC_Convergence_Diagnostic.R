# assess the convergence of MCMC algorithm by analyzing the sigma square posterior distribution samples.
# calculates the standard deviation of the samples of average sigma square in 'num_rep' runs for 'num_config' combinations of
# burn_in and post burn_in sampling sizes.
# chose the config for which the standard deviation gets below a certain threshold, which depends on the application.

# number of repetitions for sampling the standard deviation from
num_rep = 20

# the burn_in and post burn_in sampling sizes to be used in MCMC algorithm
config_burn_in <- c(50, 100, 150, 200, 400, 800, 1000, 2000, 3000, 4000, 5000, 10000)
config_after_burn_in <- c(100, 200, 300, 400, 800, 1600, 2000, 4000, 6000, 8000, 10000, 20000)
num_config <- length(config_burn_in)

# build data.frame 'posteriori_average_sigsq'
posteriori_average_sigsq <- data.frame(config_1 = double())
if (num_config > 1) {
  for ( config in c(2:num_config)) {
    posteriori_average_sigsq <- data.frame(posteriori_average_sigsq, double())
    names(posteriori_average_sigsq)[config] <- paste("config", config, sep = "_")
  }
}

# iterate through the repetitions and the number of configs.
for ( iteration in c(1:num_rep) ) {

  after_burn_in_average_sigSq <- c(rep(0, times = num_config))
  
  cat("iteration ", iteration, " out of ", num_rep, "\n")
  
  for ( config in c(1:num_config) ) {

    cat("burn_in / post_burn_in sampling sizes :", config_burn_in[config], " / ", config_after_burn_in[config],  "\n")

    # disables mem_cache_for_speed when sampling size is greater or equal to 2000 to avoid memory issues. 
    if (config_burn_in[config] >= 2000) {
      bart_machine <- bartMachine(X_transformed, log_y, num_burn_in = config_burn_in[config], num_iterations_after_burn_in = config_after_burn_in[config], verbose = FALSE, run_in_sample = FALSE, mem_cache_for_speed = FALSE)
    } else {
      bart_machine <- bartMachine(X_transformed, log_y, num_burn_in = config_burn_in[config], num_iterations_after_burn_in = config_after_burn_in[config], verbose = FALSE, run_in_sample = FALSE)
    }
  
    # calculate estimation of after burn-in average sigma square based on gibbs samples
    gibbs_posterior_sigsSq_samples <- bart_machine$java_bart_machine$getGibbsSamplesSigsqs()
    
    startIndex <- config_burn_in[config] + 1
    after_burn_in_sigsSq_samples <- gibbs_posterior_sigsSq_samples[startIndex : length(gibbs_posterior_sigsSq_samples)]

    after_burn_in_average_sigSq[config] <- mean(after_burn_in_sigsSq_samples)
    
    cat("mean sigma square estimate: ", after_burn_in_average_sigSq[config] , "\n")
    hist(after_burn_in_sigsSq_samples)

  }
  
  posteriori_average_sigsq[nrow(posteriori_average_sigsq) + 1, ] <- after_burn_in_average_sigSq

}

# printing results
for (i in c(1:num_config)) {
  standard_deviation <- sd(posteriori_average_sigsq[ , i])
  cat("standard deviation for config", i, "over", num_rep, "measures: ", standard_deviation, "\n")
  cat("averaged posterior sigma square estimation for config", i, "over", num_rep, "measures: ", mean(posteriori_average_sigsq[ , i]), "\n")
}

# cleaning enviroment
rm(num_rep, config_burn_in, config_after_burn_in, num_config, iteration, config, gibbs_posterior_sigsSq_samples, bart_machine, startIndex, after_burn_in_sigsSq_samples, after_burn_in_average_sigSq, i, standard_deviation)