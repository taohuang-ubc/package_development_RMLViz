# Created on March 5, 2020
#
# @author: Fanli Zhou
#
# This script tests the plot_train_valid_error function
# in the RMLViz package.
#
# plot_train_valid_error function takes in a model name,
# train/validation data sets, a parameter name and a vector
# of parameter values to try and then plots train/validation
# errors vs. parameter values.

data(iris)

# use the iris data for unittest
set.seed(123)
split <-  caTools::sample.split(iris$Species, SplitRatio = 0.75)

training_set <-  subset(iris, split == TRUE)
valid_set <-  subset(iris, split == FALSE)

X_train <- training_set[, -5]
y_train <- training_set[, 5]
X_valid <- valid_set[, -5]
y_valid <- valid_set[, 5]

# test that output is a ggplot2 plot
test_that("The return type of knn is not correct.", {

  expect_true(ggplot2::is.ggplot(plot_train_valid_error('knn',
                                                        X_train, y_train,
                                                        X_valid, y_valid,
                                                        'k', seq(1, 50))))
})

test_that("The return type of decision tree is not correct.", {

  expect_true(ggplot2::is.ggplot(plot_train_valid_error('decision tree',
                                                        X_train, y_train,
                                                        X_valid, y_valid,
                                                        'maxdepth', c(5, 10, 15, 20))))
})

test_that("The return type of svm is not correct.", {

  expect_true(ggplot2::is.ggplot(plot_train_valid_error('svm',
                                                        X_train, y_train,
                                                        X_valid, y_valid,
                                                        'cost', c(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10))))
})

test_that("The return type of svm is not correct.", {

  expect_true(ggplot2::is.ggplot(plot_train_valid_error('svm',
                                                        X_train, y_train,
                                                        X_valid, y_valid,
                                                        'gamma', c(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10))))
})


test_that("The return type of random forests is not correct.", {

  expect_true(ggplot2::is.ggplot(plot_train_valid_error('random forests',
                                                        X_train, y_train,
                                                        X_valid, y_valid,
                                                        'ntree', c(5, 10, 15, 20))))
})

# test for error if input is of a wrong type
test_that("X_train should be a data frame.", {

  expect_error(plot_train_valid_error('knn',
                                      c(1, 2, 3), y_train,
                                      X_valid, y_valid,
                                      'k', seq(1, 50)),
               "Sorry, X_train should be a data frame.")
})

test_that("y_train should be a vector or factor.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, matrix(c(1, 2, 3, 4), nrow=1, ncol=4),
                                      X_valid, y_valid,
                                      'k', seq(1, 50)),
               "Sorry, y_train should be a vector or factor.")
})

test_that("X_valid should be a data frame.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      c(1, 2, 3), y_valid,
                                      'k', seq(1, 50)),
               "Sorry, X_valid should be a data frame.")
})

test_that("y_valid should be a vector or factor.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      X_valid, matrix(c(1, 2, 3, 4), nrow=1, ncol=4),
                                      'k', seq(1, 50)),
               "Sorry, y_valid should be a vector or factor.")
})

test_that("All elements in X_train should be numeric.", {

  expect_error(plot_train_valid_error('knn',
                                      tibble::tibble(a = c(1, 2, '3')), y_train,
                                      X_valid, y_valid,
                                      'k', seq(1, 50)),
               "Sorry, all elements in X_train should be numeric.")
})

test_that("All elements in y_train should be numeric or factor.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, c(1, 2, '3'),
                                      X_valid, y_valid,
                                      'k', seq(1, 50)),
               "Sorry, all elements in y_train should be numeric or factor.")
})

test_that("All elements in X_valid should be numeric.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      tibble::tibble(a = c(1, 2, '3')), y_valid,
                                      'k', seq(1, 50)),
               "Sorry, all elements in X_valid should be numeric.")
})

test_that("All elements in y_valid should be numeric or factor.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      X_valid, c(1, 2, '3'),
                                      'k', seq(1, 50)),
               "Sorry, all elements in y_valid should be numeric or factor.")
})

test_that("All elements in para_vec should be numeric.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'k', c(1, 2, '3')),
               "Sorry, all elements in para_vec should be numeric.")
})


test_that("All elements in para_vec should be non-negative.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'k', c(1, 2, -3)),
               "Sorry, all elements in para_vec should be non-negative.")
})

test_that("X_train and y_train should have the same number of rows.", {

  expect_error(plot_train_valid_error('knn',
                                      tibble::tibble(a = c(1, 2, 3), b = c(1, 2, 3)), c(1, 2, 3, 4),
                                      tibble::tibble(a = c(1, 2, 3)), c(1, 2, 3),
                                      'k', seq(1, 50)),
               "Sorry, X_train and y_train should have the same number of rows.")
})

test_that("X_valid and y_valid should have the same number of rows.", {

  expect_error(plot_train_valid_error('knn',
                                      tibble::tibble(a = c(1, 2, 3)), c(1, 2, 3),
                                      tibble::tibble(a = c(1, 2, 3), b = c(1, 2, 3)), c(1, 2, 3, 4),
                                      'k', seq(1, 50)),
               "Sorry, X_valid and y_valid should have the same number of rows.")
})

test_that("X_train and X_valid should have the same number of columns.", {

  expect_error(plot_train_valid_error('knn',
                                      tibble::tibble(a = c(1, 2, 3), b = c(1, 2, 3)), c(1, 2, 3),
                                      tibble::tibble(a = c(1, 2, 3)), c(1, 2, 3),
                                      'k', seq(1, 50)),
               "Sorry, X_train and X_valid should have the same number of columns.")
})


# test for error if input is of a wrong value

test_that("Only the hyperparameter 'k' is allowed for a 'knn' model.", {

  expect_error(plot_train_valid_error('knn',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'n', seq(1, 50)),
               "Sorry, only the hyperparameter 'k' is allowed for a 'knn' model.")

})

test_that("Only the hyperparameter 'maxdepth' is allowed for a 'decision tree' model.", {

  expect_error(plot_train_valid_error('decision tree',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'm', c(5, 10, 15, 20)),
               "Sorry, only the hyperparameter 'maxdepth' is allowed for a 'decision tree' model.")

})

test_that("Only the hyperparameter, 'cost' and 'gamma', are allowed for a 'svm' model.", {

  expect_error(plot_train_valid_error('svm',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'c', c(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10)),
               "Sorry, only the hyperparameters, 'cost' and 'gamma', are allowed for a 'svm' model.")

})

test_that("Only the hyperparameter 'ntree' is allowed for a 'random forests' model.", {

  expect_error(plot_train_valid_error('random forests',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'cv', c(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10)),
               "Sorry, only the hyperparameter 'ntree' is allowed for a 'random forests' model.")

})

test_that("The model_name should be chosen from 'knn', 'decision tree', 'svc' and 'random forests'.", {

  expect_error(plot_train_valid_error('r',
                                      X_train, y_train,
                                      X_valid, y_valid,
                                      'cv', c(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10)),
               "Sorry, the model_name should be chosen from 'knn', 'decision tree', 'svc' and 'random forests'.")

})
