#' creates a ROC plot
#'
#' Takes in a vector of prediction labels and a vector of prediction probabilities.
#'
#' @param y_label a numeric vector contains the validation set label, all elements should be either 0 or 1
#' @param predict_proba a numberic vector contains the prediction probabilities
#'
#' @return A plot
#' @examples
#' \dontrun{
#' library(RMLViz)
#' set.seed(420)
#'
#' num.samples <- 100
#' weight <- sort(rnorm(n=num.samples, mean=172, sd=29))
#' bese <- ifelse(test=(runif(n=num.samples) < (rank(weight)/num.samples)),
#'                yes=1, no=0)
#'
#' glm.fit=glm(obese ~ weight, family=binomial)
#' obese_proba <- glm.fit$fitted.values
#'
#' plot_roc(obese, obese_proba)
#' }
#' @export
plot_roc <- function(y_label,predict_proba) {

  if (!is.vector(y_label) ){
    stop("Sorry, y_label should be a vector.")
  }

  if (!is.vector(predict_proba) ){
    stop("Sorry, predict_proba should be a vector.")
  }

  if (!is.numeric(y_label)){
    stop("Sorry, all elements in y_label should be numeric.")
  }

  if (!is.numeric(predict_proba)){
    stop("Sorry, all elements in predict_proba should be numeric.")
  }

  if (!all(is.element(y_label, c(0,1)))){
    stop("Sorry, all elements of y_label should be either 0 or 1.")
  }

  if (!(all(predict_proba>0) && all(predict_proba<1))){
    stop("Sorry, all elements of predict_proba should be in range(0,1).")
  }

  if (length(y_label) != length(predict_proba)){
    stop("Sorry, y_label and predict_proba should have the same length.")
  }

  df <- tibble::tibble(label = y_label,
                       predict_prob = predict_proba)

  roc_obj <- pROC::roc(y_label, predict_proba)
  auc_value = round(pROC::auc(roc_obj),3)

  ggplot2::ggplot() +
    plotROC::geom_roc(ggplot2::aes(d = label, m = predict_prob, color="roc"), df) +
    plotROC::style_roc()+
    ggplot2::annotate("text", x = 0.75, y = 0.5, label = paste('AUC:',auc_value))

}
