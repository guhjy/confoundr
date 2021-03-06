#  glmnet

#data <- simulate_data_set()

cfdr_cv_elastic <- function(formula, data, x, no_shrink, alpha, exponentiate = FALSE, ...) {
  #  add option to not use formula, per usual?
  #  add option to be more flexible with what isn't shrunk
  independent_vars <- model.matrix(formula, data = data)[, -1]
  vars <- colnames(independent_vars)

  y_name <- as.character(formula)[2]
  dependent_vars <- data[[y_name]]
  # if (formula[2] == ".") {
  #   independent_vars <- as.matrix(data[, names(data) != formula[1]])
  #   vars <- colnames(independent_vars)
  # } else {
  #   vars <- formula[[2]] %>% stringr::str_split(" \\+ ") %>% purrr::pluck(1)
  #   independent_vars <- as.matrix(data[, vars])
  # }

  penalty.factor <- c(0, rep(1, length(vars) - 1))
  .cv_model <- glmnet::cv.glmnet(y = dependent_vars, x = independent_vars, alpha = alpha, penalty.factor = penalty.factor, ...)
  .model <- .cv_model$glmnet.fit %>% broom::tidy() %>% filter(lambda == .cv_model$lambda.min)

  if (exponentiate) {
    .model <- .model %>% dplyr::mutate(estimate = exp(estimate))
  }

  cfdr_glmnet <- list(model = .cv_model, results = .model)
  class(cfdr_glmnet) <- c("cfdr", "cfdr_glmnet")
  cfdr_glmnet
}

cfdr_cv_lasso <- function(formula, data, x = NULL, no_shrink = NULL, exponentiate = FALSE, ...) {
  cfdr_cv_elastic(formula = formula, data = data, x = x, no_shrink = no_shrink, alpha = 1, exponentiate = exponentiate, ...)
}

cfdr_cv_ridge <- function(formula, data, x, no_shrink, exponentiate = FALSE, ...) {
  cfdr_cv_elastic(formula = formula, data = data, x = x, no_shrink = no_shrink, alpha = 0, exponentiate = exponentiate, ...)
}

plot.cfdr_glmnet <- function(.cfdr_glmnet) {
  plot(.cfdr_glmnet$model)
}

