#' Takes in a trained model with X and y values to produce a confusion matrix
#' visual. If predicted_y array is passed in,other evaluation scoring metrics such as
#' Recall, and precision will also be produced
#'
#' Implementation based on https://stackoverflow.com/a/59119854
#'
#' @param actual_y a data frame of the validation labels
#' @param predicted_y a data frame of predicted values with model
#' @param labels a list of string of confusion matrix labels
#' @param title a string of the confusion matrix label
#'
#' @return A plot and a dataframe with scoring metrics
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{
#' library(RMLViz)
#' data(iris)
#'
#' set.seed(123)
#'
#' split <- caTools::sample.split(iris$Species, SplitRatio = 0.75)
#' training_set <- subset(iris, split == TRUE)
#' valid_set <- subset(iris, split == FALSE)
#' X_train <- training_set[, -5]
#' y_train <- training_set[, 5]
#' X_valid <- valid_set[, -5]
#' y_valid <- valid_set[, 5]
#'
#' predict <- class::knn(X_train, X_train, y_train, k = 5)
#' confusion_matrix(y_train, predict)
#' }
confusion_matrix <- function(actual_y, predicted_y, labels = NULL, title = NULL){

  if (!is.vector(predicted_y) && !is.factor(predicted_y)){
    stop("Sorry, predicted_y should be a vector or factor.")
  }

  if (!is.vector(actual_y) && !is.factor(actual_y)){
    stop("Sorry, actual_y should be a vector or factor.")
  }

  if (length(actual_y) != length(predicted_y)){
    stop("Sorry, predicted_y and actual_y should have the same length.")
  }

  if (is.null(title)) {
    title = "Confusion Matrix"
  }

  confusion_matrix <- caret::confusionMatrix(predicted_y, actual_y)

  table <- data.frame(confusion_matrix$table)




  plot_table <- table %>%
    dplyr::mutate(goodbad = ifelse(table$Prediction == table$Reference, "good", "bad")) %>%
    dplyr::group_by_(~Reference) %>%
    dplyr::mutate_(prop = ~Freq/sum(Freq))





  confusion_plot <- ggplot2::ggplot(data = plot_table, mapping = ggplot2::aes_string(x = 'Reference', y = 'Prediction', fill = 'goodbad', alpha = 'prop')) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(ggplot2::aes_string(label = 'Freq'), vjust = .5, fontface  = "bold", alpha = 1) +
    ggplot2::scale_fill_manual(values = c(good = "green", bad = "red")) +
    ggplot2::theme_bw() +
    ggplot2::xlim(rev(levels(table$Reference))) +
    ggplot2::theme(legend.position = "none") +
    ggplot2::labs(title = title)

  metric_score <- as.data.frame(confusion_matrix$byClass)

  print(confusion_plot)
  return(metric_score)
}



