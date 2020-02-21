#' Combination forecast based on fforms
#'
#' Compute combination forecast based on the vote matrix probabilities
#' @param fforms.ensemble a list output from fforms_ensemble function
#' @param tslist list of new time series
#' @param database whethe the time series is from mcom or other
#' @param h length of the forecast horizon
#' @param parallel If TRUE, multiple cores (or multiple sessions) will be used. This only speeds things up
#' when there are a large number of time series.
#' @param holdout if holdout=TRUE take a holdout sample from your data to caldulate forecast accuracy measure, if FALSE all of the data will be used for forecasting. Default is TRUE
#' @return a list containing, point forecast, confidence interval, accuracy measure
#' @importFrom purrr map2
#' @importFrom furrr future_map2
#' @importFrom future plan
#' @author Thiyanga Talagala
#' @export
fforms_combinationforecast <- function(fforms.ensemble, tslist, database, h, holdout=TRUE, parallel=FALSE){

  ## tslist
  if (database == "other") {
    if (holdout==FALSE) {
    train_test <- lapply(tslist, function(temp){list(training=temp)})
    } else {
    train_test <- lapply(tslist, function(temp){list(training=head(temp,(length(temp)-h)), test=tail(temp, h))})
    }
  } else {
    train_test <- lapply(tslist, function(temp){list(training=temp$x, test=temp$xx)})
  }
  ## fforms.ensemble, normalize the weights
  ensemble <- lapply(fforms.ensemble, function(temp){round(temp/sum(temp),2)})

  possible_forecast <- purrr::possibly(combination_forecast_inside, otherwise = NA_real_)

  #accuracyFun <- match.fun(function_name)
  if (parallel==TRUE) {
    future::plan(future::multiprocess)
    furrr::future_map2(ensemble, train_test, possible_forecast, h=h)
  } else {
    purrr::map2(ensemble, train_test, possible_forecast, h=h)
  }




}
#'@example
#'fforms_votematrix <- matrix(c(0.1, 0.2, 0.7, 0.3, 0.3, 0.4), byrow=TRUE, ncol=3)
#'colnames(fforms_votematrix) <- c("wn", "rw", "rwd")
#'wmat <- fforms_ensemble(fforms_votematrix)
#'library(Mcomp)
#'data(M1)
#'m1y <- subset(M1, "yearly")
#'tslist <- m1y[1:2]
#'fforms_combinationforecast(wmat, tslist, database="M1", h=6)
#'@example
#'fforms_votematrix <- matrix(c(0.1, 0.2, 0.7, 0.3, 0.3, 0.4), byrow=TRUE, ncol=3)
#'colnames(fforms_votematrix) <- c("wn", "rw", "rwd")
#'wmat <- fforms_ensemble(fforms_votematrix)
#'set.seed(21022020)
#'a <- ts(cumsum(rnorm(11))) # Example for without keeping a holdout set
#'b <- ts(cumsum(rnorm(11)))
#'tsexample_list <- list(a, b)
#'fforms_combinationforecast(wmat, tsexample_list, database="other", h=6, holdout=FALSE)


