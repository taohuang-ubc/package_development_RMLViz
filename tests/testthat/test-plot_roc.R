# generate sample data
set.seed(420)
num.samples <- 100
weight <- sort(rnorm(n=num.samples, mean=172, sd=29))
obese <- ifelse(test=(runif(n=num.samples) < (rank(weight)/num.samples)),
                yes=1, no=0)

glm.fit=glm(obese ~ weight, family=binomial)
obese_proba <- glm.fit$fitted.values

# test for error if input is of a wrong type

test_that("y_label should be a vector.", {

  expect_error(plot_roc(matrix(c(1, 2, 3, 4), nrow=1, ncol=4), obese_proba), "Sorry, y_label should be a vector.")

})

test_that("predict_proba should be a vector.", {

  expect_error(plot_roc(obese, matrix(c(1, 2, 3, 4), nrow=1, ncol=4)), "Sorry, predict_proba should be a vector.")

})

# y_label should be numeric

test_that("All elements in y_label should be numeric.", {

  expect_error(plot_roc(c(1,2,'3'), obese_proba),
               "Sorry, all elements in y_label should be numeric.")
})

# predict_proba should be numeric

test_that("All elements in y_label should be numeric.", {

  expect_error(plot_roc(obese,c(1,2,'3')),
               "Sorry, all elements in predict_proba should be numeric.")
})

# y_label should be either 0 or 1

test_that("All elements in y_label should be 0 or 1", {

  expect_error(plot_roc(c(1,2,3),obese_proba),
               "Sorry, all elements of y_label should be either 0 or 1.")
})

# predict_proba should be in (0,1)

test_that("All elements in predict_proba should be in range(0,1)", {
  expect_error(plot_roc(obese, c(0.5,0.5,0.7,0.8,999)))
})

# same length

test_that("the length of y_label and predict_proba should be equal", {
  expect_equal(length(obese), length(obese_proba))
})

# test that the output is a ggplot2 plot

test_that("The return type is ggplot2 plot.", {
  expect_true(ggplot2::is.ggplot(plot_roc(obese, obese_proba)))
})


