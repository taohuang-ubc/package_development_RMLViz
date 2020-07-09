#' model_comparison_table
#' Takes in training data, testing data,
#' with the target as the last column and
#' fitted models with meaningful names,
#' then generates a model comparison
#' table.
#' @import dplyr
#' @import caret
#' @import mlbench
#' @import tibble
#'
#' @param train_data tibble of training data with target as last column
#' @param test_data tibble of testing data with target as last column
#' @param ... fitted models assigned to meaningful model names
#'
#' @return tibble of results, allowing you to compare models
#' @export
#'
#' @examples
#' \dontrun{
#' library(RMLViz)
#' library(mlbench)
#' data(Sonar)
#'
#' toy_classification_data <- dplyr::select(dplyr::as_tibble(Sonar), V1, V2, V3, V4, V5, Class)
#'
#' train_ind <- caret::createDataPartition(toy_classification_data$Class, p=0.9, list=F)
#' train_set_cf <- toy_classification_data[train_ind, ]
#' test_set_cf <- toy_classification_data[-train_ind, ]
#'
#' gbm <- caret::train(Class~., train_set_cf, method="gbm", verbose=F)
#' lm_cf <- caret::train(Class~., train_set_cf, method="LogitBoost", verbose=F)
#'
#' model_comparison_table(train_set_cf, test_set_cf,
#'                        gbm_mod=gbm, log_mod = lm_cf)
#' }
model_comparison_table <- function(train_data, test_data, ...) {
  if (!is_tibble(train_data)){
    stop("train_data should be tibble")
  }
  if (!is_tibble(test_data)){
    stop("test_data should be tibble")
  }

  dots <- list(...)
  mod_names <- names(dots)

  count <- 1
  for (mod in dots){
    if (count == 1){
      df_res <- tibble("model" = mod_names[count])

      # training results
      train_pred_res <- make_result_row(mod, train_data)
      colnames(train_pred_res) <- paste("train", colnames(train_pred_res), sep = "_")

      # test results
      test_pred_res <- make_result_row(mod, test_data)
      colnames(test_pred_res) <- paste("test", colnames(test_pred_res), sep = "_")

      # cbind to df_res
      df_res <- cbind(df_res, train_pred_res, test_pred_res)

    } else {
      df_res_dummy <- tibble("model" = mod_names[count])

      # training results
      train_pred_res <- make_result_row(mod, train_data)
      colnames(train_pred_res) <- paste("train", colnames(train_pred_res), sep = "_")

      # test results
      test_pred_res <- make_result_row(mod, test_data)
      colnames(test_pred_res) <- paste("test", colnames(test_pred_res), sep = "_")

      # cbind to df_res_dummy
      df_res_dummy <- cbind(df_res_dummy, train_pred_res, test_pred_res)

      # rbind to df_res
      df_res <- rbind(df_res, df_res_dummy)
    }

    count <- count + 1
  }
  as_tibble(df_res)
}


make_result_row <- function(model, df){

  pred_vals <- stats::predict(model, df)
  true_vals <- pull(select(df, length(colnames(df))))
  res <- postResample(pred_vals, true_vals)
  res_row_table <- as_tibble(t(res))
  res_row_table
}
