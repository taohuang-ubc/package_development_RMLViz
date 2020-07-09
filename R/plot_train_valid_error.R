
#' plot train/validation errors vs. parameter values
#'
#' Takes in a model name, train/validation data sets,
#' a parameter name and a vector of parameter values
#' to try and then plots train/validation errors vs.
#' parameter values.
#'
#' @param model_name a string of the machine learning model name.
#' Only 'knn', 'decision tree', 'svm', and 'random forests' are allowed.
#' @param X_train a numeric data frame of the training dataset without labels.
#' @param y_train a numeric vector or factor of the training labels.
#' @param X_valid a numeric data frame of the validation dataset without labels.
#' @param y_valid a numeric vector or factor of the validation labels.
#' @param param_name a string of the parameter name.
#' Please choose this parameter based on the following information:
#' 'knn': 'k',
#' 'decision tree': 'maxdepth',
#' 'svm': 'cost' or 'gamma',
#' 'random forests': 'ntree'.
#' @param param_vec a numeric vector of the parameter values.
#'
#' @return A plot
#' @export
#' @examples
#' \dontrun{
#' library(RMLViz)
#' data(iris)
#' set.seed(123)
#'
#' split <- caTools::sample.split(iris$Species, SplitRatio = 0.75)
#' training_set <- subset(iris, split == TRUE)
#' valid_set <- subset(iris, split == FALSE)
#'
#' X_train <- training_set[, -5]
#' y_train <- training_set[, 5]
#' X_valid <- valid_set[, -5]
#' y_valid <- valid_set[, 5]
#'
#' plot_train_valid_error('knn',
#'                        X_train, y_train,
#'                        X_valid, y_valid,
#'                        'k', seq(50))
#' }
plot_train_valid_error <- function(model_name, X_train, y_train, X_valid, y_valid, param_name, param_vec) {

  # check input data types
  if (!is.data.frame(X_train)){
    stop("Sorry, X_train should be a data frame.")
  }

  if (!is.vector(y_train) && !is.factor(y_train)){
    stop("Sorry, y_train should be a vector or factor.")
  }

  if (!is.data.frame(X_valid)){
    stop("Sorry, X_valid should be a data frame.")
  }
  if (!is.vector(y_valid) && !is.factor(y_valid)){
    stop("Sorry, y_valid should be a vector or factor.")
  }

  if (!all(purrr::map_lgl(X_train, is.numeric))){
    stop("Sorry, all elements in X_train should be numeric.")
  }

  if (!is.numeric(y_train) && !is.factor(y_train)){
    stop("Sorry, all elements in y_train should be numeric or factor.")
  }

  if (!all(purrr::map_lgl(X_valid, is.numeric))){
    stop("Sorry, all elements in X_valid should be numeric.")
  }

  if (!is.numeric(y_valid) && !is.factor(y_valid)){
    stop("Sorry, all elements in y_valid should be numeric or factor.")
  }

  if (!is.numeric(param_vec)){
    stop("Sorry, all elements in para_vec should be numeric.")
  }

  if (any(param_vec < 0)){
    stop("Sorry, all elements in para_vec should be non-negative.")
  }

  # check data shapes
  if (length(y_train) != nrow(X_train)){
    stop("Sorry, X_train and y_train should have the same number of rows.")
  }

  if (length(y_valid) != nrow(X_valid)){
    stop("Sorry, X_valid and y_valid should have the same number of rows.")
  }

  if (ncol(X_train) != ncol(X_valid)){
    stop("Sorry, X_train and X_valid should have the same number of columns.")
  }


  data <- X_train
  data$Target = y_train
  df <- tibble::tibble(para = param_vec,
                       train = rep(0, length(param_vec)),
                       valid = rep(0, length(param_vec)))

  model_name <- tolower(model_name)
  param_name <- tolower(param_name)

  for (i in seq(length(param_vec))){

    if (model_name == 'knn'){

      if (param_name != 'k'){
        stop("Sorry, only the hyperparameter 'k' is allowed for a 'knn' model.")
      }
      y_train_pred <- class::knn(X_train, X_train, y_train, k = param_vec[i])
      y_valid_pred <- class::knn(X_train, X_valid, y_train, k = param_vec[i])

    } else if (model_name == 'decision tree'){

      if (param_name != 'maxdepth'){
        stop("Sorry, only the hyperparameter 'maxdepth' is allowed for a 'decision tree' model.")
      }
      classifier <- rpart::rpart(formula = Target ~ .,
                                 data = data,
                                 control = list(maxdepth = param_vec[i]))
      y_train_pred <- stats::predict(classifier, newdata = X_train, type = 'class')
      y_valid_pred <- stats::predict(classifier, newdata = X_valid, type = 'class')

    } else if (model_name == 'svm') {

      if (param_name == 'cost') {
        classifier <- e1071::svm(formula = Target ~.,
                                 data = data,
                                 type = 'C-classification',
                                 kernel = 'linear',
                                 cost = param_vec[i])

      } else if (param_name == 'gamma') {
        classifier <- e1071::svm(formula = Target ~.,
                                 data = data,
                                 type = 'C-classification',
                                 kernel = 'linear',
                                 gamma = param_vec[i])

      } else {
        stop("Sorry, only the hyperparameters, 'cost' and 'gamma', are allowed for a 'svm' model.")
      }

      y_train_pred <- stats::predict(classifier, newdata = X_train, type = 'class')
      y_valid_pred <- stats::predict(classifier, newdata = X_valid, type = 'class')

    } else if (model_name == 'random forests') {

      if (param_name != 'ntree') {
        stop("Sorry, only the hyperparameter 'ntree' is allowed for a 'random forests' model.")
      }

      classifier <- randomForest::randomForest(x = X_train,
                                               y = y_train,
                                               ntree = param_vec[i])
      y_train_pred <- stats::predict(classifier, newdata = X_train, type = 'class')
      y_valid_pred <- stats::predict(classifier, newdata = X_valid, type = 'class')

    } else {

      stop("Sorry, the model_name should be chosen from 'knn', 'decision tree', 'svc' and 'random forests'.")
    }

    df$train[i] = sum(y_train_pred != y_train)/length(y_train)
    df$valid[i] = sum(y_valid_pred != y_valid)/length(y_valid)
  }


  df <- tidyr::gather(df, dataset, error, - para)
  ggplot2::ggplot(df, ggplot2::aes(para, error, color = dataset)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = param_name,
                  y = "Error",
                  title = paste(model_name, "train and valid errors vs.", param_name)) +
    ggplot2::theme(plot.title = ggplot2::element_text(size=16),
                   axis.title = ggplot2::element_text(size=14),
                   text = ggplot2::element_text(size=13))
}

