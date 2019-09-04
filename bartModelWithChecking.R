#' BART modeling for prediction
#'
#' This is a test function
bart_modeling <- function(design_matrix, response_variable, prior_hyperparameters, num_of_trees){

    mcmc_convergence_diagnostic <- list("num_burn_in" = 1000, "num_iterations_after_burn_in" = 2000, "converged" = TRUE)
    
    if (mcmc_convergence_diagnostic$converged == FALSE) {
        return_object <- list("warning_message" = "prediction model not generated", "reason" = "MCMC convergence criterion not met.")
        return(return_object)
    }

    bart_machine <- bartMachine(design_matrix, response_variable, num_burn_in = mcmc_convergence_diagnostic$num_burn_in, 
        num_iterations_after_burn_in = mcmc_convergence_diagnostic$num_iterations_after_burn_in,
        num_trees = num_of_trees, k = prior_hyperparameters$k, q = prior_hyperparameters$q, nu = prior_hyperparameters$nu,
        mem_cache_for_speed = FALSE, serialize = FALSE, verbose = FALSE, run_in_sample = TRUE)

    residual_diagnostic <- list("normality_p_value" = 0.2, "zero_mean_pvalue" = 0.12, "significance_level" = 0.05)

    if (residual_diagnostic$normality_p_value < residual_diagnostic$significance_level){
        return_object <- list("warning_message" = "prediction model not generated", "reason" = "data supports rejection of normality assumption hypothesis")
        return(return_object)
    } else if (residual_diagnostic$zero_mean_pvalue < residual_diagnostic$significance_level) {
        return_object <- list("warning_message" = "prediction model not generated", "reason" = "data supports rejection of zero mean hypothesis")
        return(return_object)
    }

    return_object <- list("prediction_model" = bart_machine,
        "burn_in_samples" = bart_machine$num_burn_in, "post_burn_in_samples" = bart_machine$num_iterations_after_burn_in)
    return(return_object)

}