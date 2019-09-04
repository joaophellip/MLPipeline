#' BART modeling for prediction
#'
#' This is a test function
cross_validation_bart_modeling <- function(design_matrix, response_variable){

    source("bartModelWithChecking.R")

    num_of_trees = c(50, 100)
    prior_hyperparameters <- list(list("k" = 2, "q" = 0.9, "nu" = 3), list("k" = 3, "q" = 0.9, "nu" = 3))
    number_of_folds = 10
    best_rmse_model_rmse = 9999

    for (trees in num_of_trees) {
        for (hyperparameters in prior_hyperparameters) {

          response <- bart_modeling(design_matrix, response_variable, hyperparameters, trees)

          if ("prediction_model" %in% names(response)){

            cat("this is a valid model. m:", trees, " k:", hyperparameters$k, " q:", hyperparameters$q, " nu:",
                hyperparameters$nu, ". Ready to generate out-of-sample predictions", "\n")

            out_of_sample_error_performance <- k_fold_cv(design_matrix, response_variable, k_folds = number_of_folds, 
                num_burn_in = response$burn_in_samples, num_iterations_after_burn_in = response$post_burn_in_samples,
                num_trees = trees, k = hyperparameters$k, q = hyperparameters$q, nu = hyperparameters$nu,
                mem_cache_for_speed = FALSE, verbose = FALSE)
            
            cat("oos_rmse from cross-validation:", out_of_sample_error_performance$rmse, "\n")
            if (out_of_sample_error_performance$rmse < best_rmse_model_rmse){
                best_rmse_model <- response$prediction_model
                best_rmse_model_rmse <- out_of_sample_error_performance$rmse
            }

          } else {
            cat(response$warning_message, " reason:", response$reason)
          }

        }
    }

    return_object <- list("best_model" = best_rmse_model, "out-of-sample_rmse" = best_rmse_model_rmse)
    return(return_object)

}