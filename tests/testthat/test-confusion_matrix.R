#library(confusion_matrix)

# Test to make sure our preventative "if statements" protect our function

# Should only pass in a factor vector
test_that("actual_y should be a vector.", {

  expect_error(confusion_matrix(tibble::tibble(""), c("1", "0")), "Sorry, actual_y should be a vector or factor.")

})

test_that("predict_y should be a vector.", {

  expect_error(confusion_matrix(c("1", "0"), tibble::tibble("")), "Sorry, predicted_y should be a vector or factor.")

})

# Inputs should be factors
test_that("actual_y should be a factor", {

  expect_error(confusion_matrix(c(1,2), as.factor(c(1, 2))), "`data` and `reference` should be factors with the same levels.")

})

test_that("predict_y should be a factor", {

  expect_error(confusion_matrix(as.factor(c(1, 2)), c(1,2)), "`data` and `reference` should be factors with the same levels.")

})

test_that("predict_y and actual_y should have the same number of rows.", {

  expect_error(confusion_matrix(as.factor(c(1,2,3)),
                                as.factor(c(1,2,3,4))),
               "Sorry, predicted_y and actual_y should have the same length.")
})

# CHECK THE OUTPUT OF FUNCTION
test_that("The return type is list of scores", {
  expect_true(is.list(confusion_matrix(as.factor(c(1,2,3)), as.factor(c(1,2,3)))))
})
