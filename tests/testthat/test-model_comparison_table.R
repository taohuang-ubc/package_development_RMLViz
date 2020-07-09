require(dplyr)
require(testthat)
require(caret)
require(mlbench)
require(stats)
require(e1071)
require(caTools)
require(tibble)
require(purrr)
## Regression data, train test split setup
toy_reg_data <- tibble("x" = rnorm(200)*100,
                       "y" = rnorm(200) *10,
                       "target" = rnorm(200)*30)

train_size <- floor(0.80 * nrow(toy_reg_data))

train_set_reg <- toy_reg_data[1:train_size, ]
test_set_reg <- toy_reg_data[(train_size+1):nrow(toy_reg_data), ]

## regression models setup
model_1_reg <- train(target~x+y, data=train_set_reg, method='lm')
model_2_reg <- train(target~x+y, data=train_set_reg, method='pcr')

## classification data, train test split setup
data(Sonar)
toy_classification_data <- select(as_tibble(Sonar), V1, V2, V3, V4, V5, Class)

train_ind <- createDataPartition(toy_classification_data$Class, p=0.9, list=F)

train_set_cf <- toy_classification_data[train_ind, ]
test_set_cf <- toy_classification_data[-train_ind, ]

## classification models setup
gbm <- train(Class~., train_set_cf, method="gbm", verbose=F)
lm_cf <- train(Class~., train_set_cf, method="LogitBoost", verbose=F)


## tests
output_reg <- model_comparison_table(train_set_reg, test_set_reg,
                                     lm_mod = model_1_reg, pcr_mod = model_2_reg)
num_calls_reg <- sum(unlist(lapply(output_reg, is.numeric)))

output_cf <- model_comparison_table(train_set_cf, test_set_cf,
                                    gbm_mod=gbm, log_mod = lm_cf)
num_calls_cf <- sum(unlist(lapply(output_cf, is.numeric)))

test_that("function output tables work", {
  expect_true(is_tibble(output_cf))
  expect_true(is_tibble(output_reg))
})

# expect 5 columns for classification tasks
test_that("5 columns for classification model", {
  expect_equal(length(colnames(output_cf)), 5)
})

# expect 7 columns for regression tasks
test_that("7 columns for regression model", {
  expect_equal(length(colnames(output_reg)), 7)
})

# expect all numeric columns except first
test_that("4 numeric columns for classification model", {
  expect_equal(num_calls_cf, 4)
})

test_that("6 numeric columns for regression model", {
  expect_equal(num_calls_reg, 6)
})

test_that("Input set should be a tibble", {
  expect_error(model_comparison_table("hello", "hi", model_1_reg))
})
